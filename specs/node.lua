-- @envy schema "1"
IDENTITY = "envy.node@r0"
EXPORTABLE = true

local platform = require("lib.platform")
local versions = require("lib.versions")

local hashes -- version -> platform key -> sha256, populated at the bottom of this file

-- nodejs.org's own naming. Windows is x64 only, as elsewhere in the bundle.
local function platform_key()
  if platform.WINDOWS then return "win-x64" end
  return envy.PLATFORM .. "-" .. ((envy.ARCH == "arm64") and "arm64" or "x64")
end

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = "https://nodejs.org/dist/v" .. opts.version .. "/node-v" .. opts.version ..
        "-" .. key .. (platform.WINDOWS and ".zip" or ".tar.xz"),
    sha256 = versions.lookup(hashes, opts.version, key),
  }
end

STAGE = { strip = 1 }

-- Windows puts the executables at the archive root, as `.cmd` launchers for npm.
-- Unix npm and npx are symlinks to scripts that find `node` on PATH.
local bin = platform.WINDOWS and "" or "bin/"

PRODUCTS = {
  node = bin .. "node" .. envy.EXE_EXT,
  npm = bin .. (platform.WINDOWS and "npm.cmd" or "npm"),
  npx = bin .. (platform.WINDOWS and "npx.cmd" or "npx"),
}

-- npm's default prefix is the node install itself, so without a prefix of its own
-- `npm install -g` would write into the cache. The prefix, npm's cache and
-- corepack's (node 24 and older ship it) all land under `<root>/.envy`. The npm
-- names are lowercase because npm exports its config to child processes that way,
-- and a second spelling of one name leaves which wins to npm.
--
-- node-gyp's header cache stays per-user: its `devdir` is not an npm config, and
-- npm warns on every run about an `npm_config_` name it does not know.
ENV = function(pkg_path, root)
  local npm = envy.path.join(root, ".envy", "npm")
  return {
    npm_config_prefix = npm,
    npm_config_cache = envy.path.join(npm, "cache"),
    COREPACK_HOME = envy.path.join(root, ".envy", "corepack"),
    PATH = { prepend = platform.WINDOWS and { pkg_path, npm }
        or { envy.path.join(pkg_path, "bin"), envy.path.join(npm, "bin") } },
  }
end

-- https://nodejs.org/dist/
-- Hashes come from the `SHASUMS256.txt` in each release directory.
hashes = {
  ["22.23.5"] = {
    ["darwin-arm64"] =
    "d0c68c321161bb2c6483efea9a343010dea8e5e7f60d73c6a7eba140016d662f",
    ["darwin-x64"] =
    "d68bf234a07781141dfca61ae4461c24560f70bd53223d76a41529eb02e8554e",
    ["linux-arm64"] =
    "2babb9eb5264860d540849f4b064a6fbdebcdc323657d9d382ce23d313fd5e09",
    ["linux-x64"] =
    "cdeb8670a0c81f51b4dc4ac61919f9b1ad917b304bf8221eb939570663d240f8",
    ["win-x64"] =
    "4a191082e9706866830379d577d2cc8a50c776fcd9436a8d061b063ed0d9a0e3",
  },
  ["24.22.3"] = {
    ["darwin-arm64"] =
    "1d64136c8a43d648d1b3bad10797a4c995b1ca032d2bde8799de43b37f058fe5",
    ["darwin-x64"] =
    "4daeec962855c1a6e66cda398a25037319dc1bbd4a0939188b3547afbbfb6490",
    ["linux-arm64"] =
    "6e51a2ada00f0011cc266f65d98922b403d7ad88f809ca2aa615a5fe1ce6e86c",
    ["linux-x64"] =
    "4f2b175a6d53a5c617a80dba2676238a0688cef28c6da4eba35c7d844e66fcfb",
    ["win-x64"] =
    "e612af99f626ab415ea225af6bce5c971feb448cb5cae250bb1c3fa50c5f7d9f",
  },
  ["26.13.1"] = {
    ["darwin-arm64"] =
    "af6202f5370a3a5209e85dc543758dfd9f44c8726626a236730cd603a67a8559",
    ["darwin-x64"] =
    "2693310b2820f9350d29524f21344e1c623875bab773457d55b2aceb9670716f",
    ["linux-arm64"] =
    "89e1853138db51e8b82d3e98ba9c0d3f2956a28e5e55ea1b7e12d25aae92d5dd",
    ["linux-x64"] =
    "5c063e46bab0fbc1c17cc445d7ff129cbdcd0471be6ed83b6ab864f8143bc864",
    ["win-x64"] =
    "e2edda75bfb089654705cf65a13b58933bfd5f57148e8ebda916f58a2474f1f7",
  },
}
