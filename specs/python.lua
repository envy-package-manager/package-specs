-- @envy schema "1"
IDENTITY = "envy.python@r2"
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
  ["3.14.6+20260623"] = {
    ["aarch64-apple-darwin"] =
    "58ba7c2f7a5bad3031065abaad75f701a3e8b7f83679917c396a850876a48205",
    ["x86_64-apple-darwin"] =
    "8776df867b4710ff3e688c4b123677a4ac53eea3432e74e91c7b26efe5f72c77",
    ["aarch64-unknown-linux-gnu"] =
    "2746a23641001d1e7b7c1cb412b15f60824a8d66f00999a06e84da48b9939179",
    ["x86_64_v3-unknown-linux-gnu"] =
    "1b17c10274a77285112fa2399f0a02ffa77808476645985507f971cc6f366bee",
    ["x86_64-pc-windows-msvc"] =
    "81e1d5e072ec677d05287f09ce7bfcef35e998c2511ee37ae470c477bace967a",
  },
  ["3.13.15+20260825"] = {
    ["aarch64-apple-darwin"] =
    "fc018b3ac9aab396b3884ccda6952d1580fb39d9190ab99c821cf0b4dc896f2f",
    ["x86_64-apple-darwin"] =
    "4e74f9a6bc6b11d900c600bdfb9dc28f92fc389b9fbd96785ff274ea75162aef",
    ["aarch64-unknown-linux-gnu"] =
    "bd46b1c3eeb2122f0421930ea05e1fd69566ae30c0a174bd89f69d856a65ebd0",
    ["x86_64_v3-unknown-linux-gnu"] =
    "63bbf2795ff3460555d6ac26d3e5cf141626d93a6fcea032e2c67f7c708af298",
    ["x86_64-pc-windows-msvc"] =
    "ae38f063f29c65c7bc7f0baf616b2c33db09221b5fddf9e1f52a8ac76125cb15",
  },
  ["3.14.7+20260825"] = {
    ["aarch64-apple-darwin"] =
    "9cc1dd70274721d2643b6bb8b59bf7544de6d0417b9645cae49fbfae7ce13bdc",
    ["x86_64-apple-darwin"] =
    "2e8e51bfb062360314e6aa4c667e3436531bdd314c43cdbfe1d8c900aed15254",
    ["aarch64-unknown-linux-gnu"] =
    "5732edd2766c9ae25046f3c520b0f91ebca28cc857e440a50f79e2235c796c26",
    ["x86_64_v3-unknown-linux-gnu"] =
    "7f4aeabc079f415eaa6f299fcee1ee8d609e38bbb94b1e2bebe8026b80f68d98",
    ["x86_64-pc-windows-msvc"] =
    "f042d41ce45bbec95a608f522861707133afabc372758a09cfe5895a1f85d426",
  },
}
