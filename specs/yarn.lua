-- @envy schema "1"
IDENTITY = "envy.yarn@r0"
EXPORTABLE = true

local platform = require("lib.platform")
local versions = require("lib.versions")

local hashes -- version -> sha256, populated at the bottom of this file

-- Yarn runs on whichever node the project provides: list envy.node (or any spec
-- with a `node` product) beside it. The edge is also what hands a dependent of this
-- package node's ENV, so its build finds `node` on PATH as well as `yarn`.
DEPENDENCIES = { { product = "node", needed_by = "install" } }

OPTIONS = function() versions.validate(hashes) end

-- Each release is one self-contained script, the same file corepack fetches. It is
-- CommonJS, so it is saved as `.cjs`: the nearest package.json decides how node
-- reads a `.js`, and a project-local cache can sit under one that says "module".
FETCH = function(tmp_dir, opts)
  return {
    source = "https://repo.yarnpkg.com/" .. opts.version .. "/packages/yarnpkg-cli/bin/yarn.js",
    sha256 = hashes[opts.version],
    dest = "yarn.cjs",
  }
end

-- The launcher is written in tmp_dir and moved, since only envy's file operations
-- create the directories they write into.
INSTALL = function(install_dir, stage_dir, fetch_dir, tmp_dir, opts)
  envy.copy(envy.path.join(fetch_dir, "yarn.cjs"), envy.path.join(install_dir, "lib", "yarn.cjs"))

  local name = platform.WINDOWS and "yarn.cmd" or "yarn"
  local launcher = envy.path.join(tmp_dir, name)
  local f = assert(io.open(launcher, "wb"))
  f:write(platform.WINDOWS and '@node "%~dp0..\\lib\\yarn.cjs" %*\r\n'
    or '#!/bin/sh\nexec node "$(dirname "$0")/../lib/yarn.cjs" "$@"\n')
  f:close()

  local dest = envy.path.join(install_dir, "bin", name)
  envy.move(launcher, dest)
  if not platform.WINDOWS then envy.run('chmod +x "' .. dest .. '"') end
end

-- Yarn's global folder holds its shared package cache and metadata; it would
-- otherwise be ~/.yarn/berry.
ENV = function(pkg_path, root)
  return {
    YARN_GLOBAL_FOLDER = envy.path.join(root, ".envy", "yarn"),
    PATH = { prepend = envy.path.join(pkg_path, "bin") },
  }
end

PRODUCTS = { yarn = platform.WINDOWS and "bin/yarn.cmd" or "bin/yarn" }

-- https://github.com/yarnpkg/berry/releases
-- Upstream publishes no sha256; hashes were computed from the downloads, and match
-- `package/bin/yarn.js` in the npm registry's `@yarnpkg/cli-dist` tarball.
hashes = {
  ["4.17.1"] = "471ffb15e0523663865bbf46a69e7d157ecf532412eb436c48dfab6e3f2abe88",
  ["4.18.0"] = "fb8b1d20be72a0b544a35bcec4c7ed0ff55a9b173c01f191b02ba164b2051db5",
  ["4.18.1"] = "a28ad591febb769f939c11f82f89bacad0b0fac0c884d3b78fa2aaaee970907e",
}
