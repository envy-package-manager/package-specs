-- @envy schema "1"
IDENTITY = "envy.python@r0"
EXPORTABLE = true

local github = require("lib.github")
local versions = require("lib.versions")

local hashes -- "<version>+<release>" -> triple -> sha256, at the bottom of this file

-- Linux x86_64 builds target the x86-64-v3 microarchitecture (AVX2).
local function platform_key()
  if envy.PLATFORM == "darwin" then
    return (envy.ARCH == "arm64") and "aarch64-apple-darwin" or "x86_64-apple-darwin"
  elseif envy.PLATFORM == "linux" then
    return (envy.ARCH == "x86_64") and "x86_64_v3-unknown-linux-gnu"
        or "aarch64-unknown-linux-gnu"
  end
  return "x86_64-pc-windows-msvc"
end

local function pin(opts) return opts.version .. "+" .. opts.release end

OPTIONS = function(opts)
  envy.options({
    version = { required = true },
    release = { required = true },
    -- Whether this interpreter claims the bare `python` / `python3` product
    -- names. Off by default so several interpreters can coexist in one
    -- manifest; each always provides `python<major>.<minor>`.
    provide_python = { type = "boolean" },
    provide_python3 = { type = "boolean" },
  })

  if not hashes[pin(opts)] then
    return "unrecorded version+release '" .. pin(opts) .. "'; recorded: " ..
        table.concat(versions.list(hashes), ", ")
  end
end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  -- Windows builds have no LTO variant.
  local flavor = (envy.PLATFORM == "windows") and "pgo" or "pgo+lto"

  return {
    source = github.release_url("astral-sh/python-build-standalone", opts.release,
      "cpython-" .. pin(opts) .. "-" .. key .. "-" .. flavor .. "-full.tar.zst"),
    sha256 = versions.lookup(hashes, pin(opts), key),
  }
end

-- The archive nests everything under `python/`; `install/` is the prefix.
STAGE = { strip = 1 }

PRODUCTS = function(opts)
  local python = ((envy.PLATFORM == "windows") and "install/" or "install/bin/")
      .. "python" .. envy.EXE_EXT

  return {
    python = opts.provide_python and python or nil,
    python3 = opts.provide_python3 and python or nil,
    ["python" .. opts.version:match("^(%d+%.%d+)")] = python,
  }
end

-- https://github.com/astral-sh/python-build-standalone/releases
-- Hashes come from the `SHA256SUMS` asset in each release. Keys are
-- "<version>+<release>" because an interpreter version is only meaningful
-- alongside the build that produced it; the two options are pinned together.
hashes = {
  ["3.13.14+20260623"] = {
    ["aarch64-apple-darwin"] =
    "3caf9b0084fdbedc6da1c96a53c020f4a0bce35aab15e63e0e0c62ae450b4d7b",
    ["x86_64-apple-darwin"] =
    "1c1389b59727633916612e2e54a11a5f3a5ed41ffc7867294ea3bd71cbf1c6cf",
    ["aarch64-unknown-linux-gnu"] =
    "da311ff9ce8f793618a1b7c4061153b4cd58058529d912c398048f543675cedc",
    ["x86_64_v3-unknown-linux-gnu"] =
    "cb4eeeda8c8d324e1cd504d6061659f3b7a776ce34ff4db00b6037070163bbfe",
    ["x86_64-pc-windows-msvc"] =
    "9ae78c0a2e4babdbcadee9ccbf9c72882f367b922be98eda87f7edba98462afd",
  },
}
