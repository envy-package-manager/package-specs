-- @envy schema "1"
IDENTITY = "envy.gn@r2"
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
  -- 2026-08-31 "Fix EditCommandTest.ShardSubcommand"
  ["a99d46a9d04c770d6bb87387058e1d7b151758ce"] = {
    ["linux-amd64"] = "a0ff30ac34026b49a25b75545e58f7bfa239364edd11caf12bdb8bd8a35d629c",
    ["linux-arm64"] = "f96206c102f15d6c50ef675a9c65279598287740fa986836504615b0fc25f417",
    ["mac-amd64"] = "477f1b4dbdd15047ab11431b0e2ef6551538d0ad93a6b9ad8332fe5e0b2aefdb",
    ["mac-arm64"] = "fd8d59ef41bd4f64acd5a21a049f5191b9df95bb25850e71d45787f9c6b62fc5",
    ["windows-amd64"] = "6fab25d350c84c0a8b58bbcf565f63478c6044a6f507b9715c0815906fbab3bc",
  },
  -- 2026-09-17 "When suggestions have a known includer target, don't complain that
  -- they don't resolve to a single target."
  ["127dd2a6d582528d6d61c4d838dc17385ef31abd"] = {
    ["linux-amd64"] = "2529a6e618be13d05b761a1b5b5e2f0c8bd3e5c592d0c8bf16afed12b6314f12",
    ["linux-arm64"] = "6f82a33452575e7376c99c55c5a5be46816fa0606cde4314d773bdeda5a3be5b",
    ["mac-amd64"] = "5755124082a2da1cc1197fe4eaf1c784330170196b13220d7578fc79d53fe954",
    ["mac-arm64"] = "abbf70538595588cb5ee222f65ecf2f9055ecfd1b54475be4d7a02b32631693a",
    ["windows-amd64"] = "0457c2f6456ed1a110f42ce841dde7c6fde53ff513f71db50c3b08e2d0d8ff47",
  },
}
