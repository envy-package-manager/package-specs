-- @envy schema "1"
IDENTITY = "envy.rust@r0"
EXPORTABLE = true

local versions = require("lib.versions")

local hashes -- version -> sha256 of its channel manifest, populated at the bottom of this file

local DIST = "https://static.rust-lang.org/dist/"

-- The host toolchain. Linux takes the glibc build: a musl-hosted rustc defaults to
-- producing musl binaries, so lib.platform's static triples are wrong here.
local function host()
  if envy.PLATFORM == "darwin" then
    return (envy.ARCH == "arm64") and "aarch64-apple-darwin" or "x86_64-apple-darwin"
  elseif envy.PLATFORM == "linux" then
    return (envy.ARCH == "arm64") and "aarch64-unknown-linux-gnu" or "x86_64-unknown-linux-gnu"
  end
  return "x86_64-pc-windows-msvc"
end

-- rustup's default profile, less the HTML docs.
local BASE = { "rustc", "cargo", "rust-std", "clippy", "rustfmt" }

OPTIONS = function()
  versions.validate(hashes, {
    -- More rustup components: "rust-src", "rust-analyzer", "llvm-tools", ...
    components = { type = "list" },
    -- Cross targets, each adding its rust-std: "thumbv7em-none-eabihf", ...
    targets = { type = "list" },
  })
end

-- The `[pkg.<name>.target.<triple>]` tables of a channel manifest, and its
-- `[renames]` (clippy -> clippy-preview). Every key this reads is a flat
-- `key = value` line, so a line scan is all the TOML it needs.
local function read_manifest(path)
  local pkgs, renames, section = {}, {}, nil
  local f = assert(io.open(path, "rb"))
  for line in f:lines() do
    local header = line:match("^%[([^%[%]]+)%]$")
    if header then
      local name, target = header:match('^pkg%.([^.]+)%.target%."?([^"]+)"?$')
      local from = header:match("^renames%.(.+)$")
      section = (name or from) and {} or nil
      if name then
        pkgs[name] = pkgs[name] or {}
        pkgs[name][target] = section
      elseif from then
        renames[from] = section
      end
    elseif line:match("^%[%[") then
      section = nil
    elseif section then
      local key, value = line:match('^([%w_]+) = "?([^"]*)"?$')
      if key then section[key] = value end
    end
  end
  f:close()
  return pkgs, renames
end

-- Trust runs through the manifest: its hash is pinned below, and it names the
-- sha256 of every component tarball for every target.
FETCH = function(tmp_dir, opts)
  local manifest = "channel-rust-" .. opts.version .. ".toml"
  envy.fetch({ source = DIST .. manifest, sha256 = hashes[opts.version] }, { dest = tmp_dir })
  local pkgs, renames = read_manifest(envy.path.join(tmp_dir, manifest))

  local wanted = {}
  for _, name in ipairs(BASE) do wanted[#wanted + 1] = { name, host() } end
  for _, name in ipairs(opts.components or {}) do wanted[#wanted + 1] = { name, host() } end
  for _, target in ipairs(opts.targets or {}) do wanted[#wanted + 1] = { "rust-std", target } end

  local fetches, seen = {}, {}
  for _, want in ipairs(wanted) do
    local name, target = want[1], want[2]
    local by_target = pkgs[renames[name] and renames[name].to or name]
    if not by_target then
      error("rust " .. opts.version .. " has no component '" .. name .. "'", 0)
    end
    -- rust-src is one tarball for every target, filed under "*".
    local entry = by_target[target] or by_target["*"]
    if not entry or entry.available ~= "true" then
      error("rust " .. opts.version .. " has no '" .. name .. "' for " .. target, 0)
    end
    if not seen[entry.xz_url] then
      seen[entry.xz_url] = true
      fetches[#fetches + 1] = { source = entry.xz_url, sha256 = entry.xz_hash }
    end
  end
  return fetches
end

-- Each tarball is `<pkg>-<version>-<target>/<component>/` around the tree the
-- component installs, plus rust-installer's bookkeeping. Stripping both levels
-- merges every component into one sysroot; the components never share a file.
STAGE = { strip = 2, only = { "!manifest.in" } }

-- rust-objcopy looks for libLLVM only in its own `../lib`, the target's library
-- directory, where only llvm-tools puts one; rustup covers for that by setting the
-- loader's search path for every tool it starts. A link there instead lets rustc
-- strip debuginfo, as release builds do by default, with no such variable.
-- A function, not a string: with no function verb envy extracts straight into the
-- package, and a string BUILD would run in an empty stage directory.
BUILD = function()
  if envy.PLATFORM == "windows" then return end
  return 'cd "lib/rustlib/' .. host() .. '/lib" && for f in ../../../libLLVM*; do\n' ..
      '  [ -e "${f##*/}" ] || ln -s "$f" .\ndone'
end

PRODUCTS = function(opts)
  local tools = { "cargo", "rustc", "rustdoc", "rustfmt", "cargo-fmt", "cargo-clippy",
    "clippy-driver" }
  for _, name in ipairs(type(opts.components) == "table" and opts.components or {}) do
    if name == "rust-analyzer" then tools[#tools + 1] = name end
  end

  local products = {}
  for _, tool in ipairs(tools) do products[tool] = "bin/" .. tool .. envy.EXE_EXT end
  return products
end

-- Cargo keeps its registry, git checkouts and `cargo install` output under
-- `<root>/.envy/cargo`; CARGO_INSTALL_ROOT too, so one set in the caller's
-- environment cannot send installs elsewhere. RUSTC and RUSTDOC point cargo at the
-- binaries themselves rather than the project's bin dir wrappers, which would cost
-- an envy launch on every rustc cargo starts.
ENV = function(pkg_path, root)
  local cargo = envy.path.join(root, ".envy", "cargo")
  local bin = envy.path.join(pkg_path, "bin")
  return {
    CARGO_HOME = cargo,
    CARGO_INSTALL_ROOT = cargo,
    RUSTC = envy.path.join(bin, "rustc" .. envy.EXE_EXT),
    RUSTDOC = envy.path.join(bin, "rustdoc" .. envy.EXE_EXT),
    PATH = { prepend = { bin, envy.path.join(cargo, "bin") } },
  }
end

-- https://forge.rust-lang.org/infra/other-installation-methods.html
-- Each hash is of https://static.rust-lang.org/dist/channel-rust-<version>.toml, and
-- matches the `.sha256` file published beside it.
hashes = {
  ["1.98.0"] = "3f7d139b73bbbd0004ef6e58b430831c68cdad2b1f64ee2eb35d54c09199489a",
  ["1.99.0"] = "ce6dddc886364f8d786514771212cebe9b731ba82d6b859951c6b0ccc516b6a2",
  ["1.100.0"] = "3051e859570f64a8c5acb9d09e87425db52c7d97287c67e8f6d57d7d34ef9258",
}
