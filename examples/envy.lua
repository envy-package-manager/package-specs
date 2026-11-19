-- Sample manifest pulling every spec out of this bundle.
--
-- The bundle source here is the checkout this file lives in, so the example
-- runs against local edits. Real projects use a git source and pinned ref --
-- see the README.
--
-- @envy version "0.7.1"
-- @envy schema "1"
-- @envy bin "bin"
-- @envy deploy "true"
-- @envy root "true"

BUNDLES = {
  ["first-party"] = {
    identity = "envy.package-specs@r12",
    source = envy.abspath(".."),
  },
}

VENDOR_ROOT = "vendor"

local gh = envy.loadenv_bundle("first-party", "lib.github")

PACKAGES = {
  { spec = "envy.python@r6", bundle = "first-party",
    options = { version = "3.13.18", release = "20261110", provide_python3 = true } },

  { spec = "envy.uv@r5", bundle = "first-party", options = { version = "0.13.9" } },

  { spec = "envy.ruff@r5", bundle = "first-party", options = { version = "0.17.6" } },

  { spec = "envy.ty@r5", bundle = "first-party", options = { version = "0.0.107" } },

  { spec = "envy.cmake@r3", bundle = "first-party", options = { version = "4.5.1" } },

  { spec = "envy.ninja@r0", bundle = "first-party", options = { version = "1.13.2" } },

  -- GN is keyed by git revision, not version -- see the README.
  { spec = "envy.gn@r5", bundle = "first-party",
    options = { ref = "f126a26ef94d5c4620d0e7d06e2390bc621d846a" } },

  { spec = "envy.protobuf@r2", bundle = "first-party", options = { version = "36.2" } },

  { spec = "envy.swig@r3", bundle = "first-party", options = { version = "4.5.1" } },

  { spec = "envy.doctest-cpp@r0", bundle = "first-party", options = { version = "2.5.3" } },

  -- Go, node, yarn and rust keep their state (modules, caches, global installs)
  -- under .envy/ in this directory, in a shell activated here.
  { spec = "envy.go@r0", bundle = "first-party", options = { version = "1.27.4" } },

  { spec = "envy.node@r0", bundle = "first-party", options = { version = "26.13.1" } },

  -- Yarn runs on the `node` product above.
  { spec = "envy.yarn@r0", bundle = "first-party", options = { version = "4.18.1" } },

  { spec = "envy.rust@r0", bundle = "first-party",
    options = { version = "1.100.0", components = { "rust-src" },
                targets = { "thumbv7em-none-eabihf" } } },

  -- One asset of a release, unpacked, with the archive's top directory stripped.
  gh.release("nanoprintf", "charlesnicholson/nanoprintf", {
    tag = "v0.8.0", asset = "nanoprintf-v0.8.0.zip", strip = 1,
    only = { "nanoprintf.h" },
    sha256 = "f0a1f76db77c47df9e8a028dec7d3317fa021b16d10691ea80e5d79b56a13109" }),

  -- A CMSIS-Pack is a zip that envy would not know by its name without `archives`.
  gh.release("CMSIS-DSP", "ARM-software/CMSIS-DSP", {
    tag = "v1.15.0", asset = "ARM.CMSIS-DSP.1.15.0.pack", archives = { "*.pack" },
    only = { "Include/**", "PrivateInclude/**", "Source/**" },
    sha256 = "4e9719d7df4036661128aa8a6f580f4ac319137624b4f304a0f0d72b4d9eeb5a" }),

  -- A clone at a commit, which needs no hash because the sha is one.
  gh.repo("libb64", "libb64/libb64",
          -- envy git-resolve https://github.com/libb64/libb64 v2.0.0.1-7-gce864b1
          "ce864b17ea0e24a91e77c7dd3eb2d1ac4175b3f0"),
}
