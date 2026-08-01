-- @envy schema "1"
IDENTITY = "envy.cmake@r0"
EXPORTABLE = true

local github = require("lib.github")
local platform = require("lib.platform")
local versions = require("lib.versions")

local hashes -- version -> platform key -> sha256, populated at the bottom of this file

-- Kitware ships one universal macOS build and x86_64-only Windows builds.
local function platform_key()
  return ({
    darwin = "macos-universal",
    linux = "linux-" .. ((envy.ARCH == "arm64") and "aarch64" or envy.ARCH),
    windows = "windows-x86_64",
  })[envy.PLATFORM]
end

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = github.release_url("Kitware/CMake", "v" .. opts.version,
      "cmake-" .. opts.version .. "-" .. key .. platform.ARCHIVE_EXT),
    sha256 = versions.lookup(hashes, opts.version, key),
  }
end

STAGE = { strip = 1 }

-- The macOS archive is an app bundle with the command line tools inside it.
local bin = (envy.PLATFORM == "darwin") and "CMake.app/Contents/bin/" or "bin/"

PRODUCTS = {
  cmake = bin .. "cmake" .. envy.EXE_EXT,
  ctest = bin .. "ctest" .. envy.EXE_EXT,
  cpack = bin .. "cpack" .. envy.EXE_EXT,
}

-- https://github.com/Kitware/CMake/releases
-- Hashes come from the `cmake-<version>-SHA-256.txt` asset in each release.
hashes = {
  ["4.2.1"] = {
    ["macos-universal"] =
    "0bb18f295e52d7e9309980e361e79e76a1d8da67a1587255cbe3696ea998f597",
    ["linux-x86_64"] =
    "c059bff1e97a2b6b5b0c0872263627486345ad0ed083298cb21cff2eda883980",
    ["linux-aarch64"] =
    "3e178207a2c42af4cd4883127f8800b6faf99f3f5187dccc68bfb2cc7808f5f7",
    ["windows-x86_64"] =
    "dfc2b2afac257555e3b9ce375b12b2883964283a366c17fec96cf4d17e4f1677",
  },
  ["4.2.3"] = {
    ["macos-universal"] =
    "c2302d3e9c48daabee5ea7c4db4b2b93b989bcc89dae8b760880e00120641b5b",
    ["linux-x86_64"] =
    "5bb505d5e0cca0480a330f7f27ccf52c2b8b5214c5bba97df08899f5ef650c23",
    ["linux-aarch64"] =
    "e529c75f18f27ba27c52b329efe7b1f98dc32ccc0c6d193c7ab343f888962672",
    ["windows-x86_64"] =
    "eb4ebf5155dbb05436d675706b2a08189430df58904257ae5e91bcba4c86933c",
  },
  ["4.3.0"] = {
    ["macos-universal"] =
    "5bd933daf6e9234a53a9a43092746993870d9f162b6c399fd6e4a05cdd475e67",
    ["linux-x86_64"] =
    "201bdabe17a54e017f119cffa247648e9c44327e52473c2cc60a88fded94652a",
    ["linux-aarch64"] =
    "26fe3011f497eb9398115dcabcc094685e634b1841f7c01dc01c5a89b8b0ea0d",
    ["windows-x86_64"] =
    "0f664f44eeb5b35b77f83e0984459c0dfa70539bd215c54ae1059604fd4f77ea",
  },
  ["4.3.2"] = {
    ["macos-universal"] =
    "808ab43a0db04c8eec9ed7db12b90d7be1c8e2e75f4a060724d604a2043ccaf7",
    ["linux-x86_64"] =
    "791ae3604841ca03cb3889a3ad89165346e4b180ae3448efd4b0caa9ef46d245",
    ["linux-aarch64"] =
    "377079ab739f5765176f427609d9a2015b756ea20d5cba908d279c3731a2f481",
    ["windows-x86_64"] =
    "83d20c23f5c5f64b3b328785e35b23c532e33057a97ed6294acaca3781b78a01",
  },
  ["4.4.0"] = {
    ["macos-universal"] =
    "09d6382059aa1b986b25fd1809459f5eb3da6a1ab342d44d6084265f38541397",
    ["linux-x86_64"] =
    "3864eb649b4466ae126a64bbde1657adad78efbbaa068bf38201de5cf1b5349f",
    ["linux-aarch64"] =
    "e98bb53e0b00a8f672424517d34c05bb9b94fd1c888c89e0b81bc8df51d1a94b",
    ["windows-x86_64"] =
    "156d70eb7625a7b469444df7d0861d2af8d5d0a437fce32c350372b08f5620e8",
  },
}
