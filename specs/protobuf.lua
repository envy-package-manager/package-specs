-- @envy schema "1"
IDENTITY = "envy.protobuf@r0"
EXPORTABLE = true

local github = require("lib.github")
local versions = require("lib.versions")

local hashes -- version -> platform key -> sha256, populated at the bottom of this file

-- protoc uses `aarch_64` (underscore) and a single win64 build for Windows.
local function platform_key()
  return ({
    darwin = "osx-" .. ((envy.ARCH == "arm64") and "aarch_64" or envy.ARCH),
    linux = "linux-" .. ((envy.ARCH == "arm64") and "aarch_64" or envy.ARCH),
    windows = "win64",
  })[envy.PLATFORM]
end

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = github.release_url("protocolbuffers/protobuf", "v" .. opts.version,
      "protoc-" .. opts.version .. "-" .. key .. ".zip"),
    sha256 = versions.lookup(hashes, opts.version, key),
  }
end

-- The zip already has bin/ and include/ at its root.
PRODUCTS = {
  protoc = "bin/protoc" .. envy.EXE_EXT,
  -- The .proto files protoc bundles (descriptor.proto, well-known types).
  protobuf_includes = { value = "include", script = false },
}

-- https://github.com/protocolbuffers/protobuf/releases
-- Release assets carry no checksums; hashes were computed from the downloads.
-- This spec installs the prebuilt `protoc` distribution, not the runtimes.
hashes = {
  ["35.1"] = {
    ["osx-aarch_64"] = "193289af0470c6a1aada357d4fba0bbf8d78bfaac8b5e42ca30af2ef75583de2",
    ["osx-x86_64"] = "537d73604a344ded6fc94e98e07e529d4fe3e4a0b09e59905353950fafc2a1f7",
    ["linux-aarch_64"] = "01bf9d08808c7f96678b63f4bd8efa559bb4f83d5a7a270d5edaf507f9d5d9cf",
    ["linux-x86_64"] = "6930ebf62bd4ea607b98fff052596c6ee564b9835b4ce172c75a3f53ae9d91b7",
    win64 = "5d3ff218d7d91eea95f7569bcb5a98f3030f8996d44151279d9772edcff76082",
  },
}
