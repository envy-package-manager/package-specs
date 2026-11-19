-- @envy schema "1"
IDENTITY = "envy.go@r0"
EXPORTABLE = true

local platform = require("lib.platform")
local versions = require("lib.versions")

local hashes -- version -> platform key -> sha256, populated at the bottom of this file

-- go.dev's own `<os>-<arch>` naming. Windows is amd64 only, as elsewhere in the bundle.
local function platform_key()
  if envy.PLATFORM == "windows" then return "windows-amd64" end
  return envy.PLATFORM .. "-" .. ((envy.ARCH == "arm64") and "arm64" or "amd64")
end

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  local key = platform_key()
  return {
    source = "https://go.dev/dl/go" .. opts.version .. "." .. key .. platform.ARCHIVE_EXT,
    sha256 = versions.lookup(hashes, opts.version, key),
  }
end

STAGE = { strip = 1 } -- everything sits under `go/`

PRODUCTS = {
  go = "bin/go" .. envy.EXE_EXT,
  gofmt = "bin/gofmt" .. envy.EXE_EXT,
}

-- Everything go writes lands under `<root>/.envy/go`: modules, build cache and
-- `go install` output. Each variable is set rather than left to derive from GOPATH,
-- so a GOMODCACHE or GOBIN in the caller's environment cannot pull a write back out.
-- `-modcacherw` because go makes the module cache read-only, and a read-only tree
-- defeats `rm -rf`, `git clean`, and envy dropping a dependent's tmp dir.
-- GOTOOLCHAIN=local keeps go from fetching a newer toolchain when go.mod asks for
-- one; the manifest pins the toolchain, so go.mod outgrowing it is an error.
ENV = function(pkg_path, root)
  local state = envy.path.join(root, ".envy", "go")
  return {
    GOROOT = (pkg_path:gsub("[/\\]$", "")),
    GOPATH = state,
    GOMODCACHE = envy.path.join(state, "pkg", "mod"),
    GOCACHE = envy.path.join(state, "cache"),
    GOBIN = envy.path.join(state, "bin"),
    GOTOOLCHAIN = "local",
    GOFLAGS = { append = "-modcacherw", sep = " " },
    PATH = { prepend = { envy.path.join(pkg_path, "bin"), envy.path.join(state, "bin") } },
  }
end

-- https://go.dev/dl/
-- Hashes come from https://go.dev/dl/?mode=json&include=all.
hashes = {
  ["1.26.11"] = {
    ["darwin-arm64"] =
    "e3a42e67a7a8acf450ebada2b074c7ca863000ca514907b7185b45e8f5cdff57",
    ["darwin-amd64"] =
    "394baae971332f2bc783d6e2004ae57101479bd3b06ed8209a3fe3570d4ce498",
    ["linux-arm64"] =
    "6c2f29b458b5add0835f18b776f69c8881a6d88428f1484a6da55755e620757e",
    ["linux-amd64"] =
    "9849f4e04ee35303714e34fbc3ac8ab44ea3e448a95aa182f91e3b9b79c710ec",
    ["windows-amd64"] =
    "71ae086f0137e665f855a811cc119152b6a783e0bbc1b906e709f46d80141eb0",
  },
  ["1.27.4"] = {
    ["darwin-arm64"] =
    "91a44a2b8a716600ad94a4f143e156116620db8828086a6e3602291be9bd0bb4",
    ["darwin-amd64"] =
    "2b799377704ef12db39bd254995d5c348c9cc8d86562ca817724390e56c38f43",
    ["linux-arm64"] =
    "3392582988a273a87ab5043ee1b2c9c17a2c3c00580bf9326c47a2e0aaaeac92",
    ["linux-amd64"] =
    "7226736c2339719cda28fbf3a54d71aa63bcefe376e98cef00034268dab24840",
    ["windows-amd64"] =
    "178ab98950ac69ab25069307dc6ade79f3816e414cce95b4da166a115cde1e7e",
  },
}
