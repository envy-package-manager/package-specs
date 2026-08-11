-- @envy schema "1"
IDENTITY = "envy.gn@r0"
EXPORTABLE = true

local versions = require("lib.versions")

local hashes -- git revision -> platform key -> sha256, populated at the bottom of this file

-- CIPD platform names, exactly as they appear in the download path.
local function platform_key()
  if envy.PLATFORM == "darwin" then
    return (envy.ARCH == "arm64") and "mac-arm64" or "mac-amd64"
  elseif envy.PLATFORM == "linux" then
    return (envy.ARCH == "x86_64") and "linux-amd64" or "linux-arm64"
  end
  return "windows-amd64"
end

-- GN cuts no releases and carries no version number: upstream builds one CIPD
-- package per git revision, so the option is a revision and the hash table is
-- keyed by it rather than by a version.
OPTIONS = function()
  envy.options({ ref = { required = true, choices = versions.list(hashes) } })
end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = "https://chrome-infra-packages.appspot.com/dl/gn/gn/" .. key ..
        "/+/git_revision:" .. opts.ref,
    -- The URL ends in the revision, so name the download to make it a zip.
    dest = "gn.zip",
    sha256 = versions.lookup(hashes, opts.ref, key),
  }
end

-- Every platform's zip holds the bare binary plus CIPD's own `.cipdpkg/`.
PRODUCTS = { gn = "gn" .. envy.EXE_EXT }

-- https://chrome-infra-packages.appspot.com/p/gn/gn
-- Revisions of https://gn.googlesource.com/gn. CIPD publishes no checksums, so
-- hashes were computed from the downloads.
hashes = {
  -- 2026-07-13 "Replace OutputFile with StringAtom under the hood"
  ["10d3ab4387f7f4ad0d3fb9d626218a6e09e71d86"] = {
    ["linux-amd64"] = "5758c43bcf5035987f85a21272e28a89ab3198da21d2c1fdc47c6978aa9ab5ac",
    ["linux-arm64"] = "677da954d6f0492b20e9b17112980a70421927f0011d5faeaf4ab302d51ff067",
    ["mac-amd64"] = "17e27b08c3c34e9d1ebc80faebc73453fa5e9be48c0ba6695b56183c245184bd",
    ["mac-arm64"] = "38804d8ff18dbf3fef6de32fb37f4977a4e18f4bc887c1f6d6084349789d7667",
    ["windows-amd64"] = "4b2c416aeed92aebb11446b00be5d15885b2c6f17f2ca80955d3309c2a62ea3e",
  },
}
