-- @envy schema "1"
IDENTITY = "envy.ninja@r0"
EXPORTABLE = true

local github = require("lib.github")
local versions = require("lib.versions")

local hashes -- version -> platform key -> sha256, populated at the bottom of this file

-- Every platform's asset is a zip holding a single bare `ninja` binary.
local function platform_key()
  if envy.PLATFORM == "darwin" then
    return "mac" -- universal binary
  elseif envy.PLATFORM == "linux" then
    return (envy.ARCH == "x86_64") and "linux" or "linux-aarch64"
  end
  return (envy.ARCH == "arm64") and "winarm64" or "win"
end

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = github.release_url("ninja-build/ninja", "v" .. opts.version,
      "ninja-" .. key .. ".zip"),
    sha256 = versions.lookup(hashes, opts.version, key),
  }
end

PRODUCTS = { ninja = "ninja" .. envy.EXE_EXT }

-- https://github.com/ninja-build/ninja/releases
-- Release assets carry no checksums; hashes were computed from the downloads.
-- Note the `version` option omits the tag's leading `v`.
hashes = {
  ["1.13.2"] = {
    mac = "c99048673aa765960a99cf10c6ddb9f1fad506099ff0a0e137ad8960a88f321b",
    linux = "5749cbc4e668273514150a80e387a957f933c6ed3f5f11e03fb30955e2bbead6",
    ["linux-aarch64"] = "fd2cacc8050a7f12a16a2e48f9e06fca5c14fc4c2bee2babb67b58be17a607fc",
    win = "07fc8261b42b20e71d1720b39068c2e14ffcee6396b76fb7a795fb460b78dc65",
    winarm64 = "e52f0bdef9dfb1003229dbd6508a508c4073fd017247002adc66e5e806cb0391",
  },
}
