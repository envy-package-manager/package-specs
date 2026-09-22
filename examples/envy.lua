-- Sample manifest pulling every spec out of this bundle.
--
-- The bundle source here is the checkout this file lives in, so the example
-- runs against local edits. Real projects use a git source and pinned ref --
-- see the README.
--
-- @envy version "0.4.7"
-- @envy schema "1"
-- @envy bin "bin"
-- @envy deploy "true"
-- @envy root "true"

BUNDLES = {
  ["first-party"] = {
    identity = "envy.package-specs@r6",
    source = envy.abspath(".."),
  },
}

-- Source trees a build compiles have to be in the project, not the cache.
VENDOR_ROOT = "vendor"

-- The bundle's own manifest-side helper. One line per library instead of a
-- spelled-out entry each time; it reads the alias above out of ENVY_BUNDLE.
local gh = envy.loadenv_bundle("first-party", "lib.github")

PACKAGES = {
  { spec = "envy.python@r2", bundle = "first-party",
    options = { version = "3.13.15", release = "20260825", provide_python3 = true } },

  { spec = "envy.uv@r1", bundle = "first-party", options = { version = "0.12.8" } },

  { spec = "envy.ruff@r1", bundle = "first-party", options = { version = "0.16.5" } },

  { spec = "envy.ty@r1", bundle = "first-party", options = { version = "0.0.77" } },

  { spec = "envy.cmake@r1", bundle = "first-party", options = { version = "4.4.3" } },

  { spec = "envy.ninja@r0", bundle = "first-party", options = { version = "1.13.2" } },

  -- GN is keyed by git revision, not version -- see the README.
  { spec = "envy.gn@r1", bundle = "first-party",
    options = { ref = "a99d46a9d04c770d6bb87387058e1d7b151758ce" } },

  { spec = "envy.protobuf@r1", bundle = "first-party", options = { version = "36.1" } },

  { spec = "envy.swig@r1", bundle = "first-party", options = { version = "4.5.0" } },

  { spec = "envy.doctest-cpp@r0", bundle = "first-party", options = { version = "2.5.3" } },

  -- One asset of a release, unpacked, with the archive's top directory stripped.
  gh.release("nanoprintf", "charlesnicholson/nanoprintf", {
    tag = "v0.8.0", asset = "nanoprintf-v0.8.0.zip", strip = 1,
    only = { "nanoprintf.h" },
    sha256 = "f0a1f76db77c47df9e8a028dec7d3317fa021b16d10691ea80e5d79b56a13109" }),

  -- A clone at a commit, which needs no hash because the sha is one. Both of
  -- these land under VENDOR_ROOT; a trailing `vendor = "somewhere/else"` moves
  -- one, and `vendor = false` leaves it in the cache.
  gh.repo("libb64", "libb64/libb64",
          -- envy git-resolve https://github.com/libb64/libb64 v2.0.0.1-7-gce864b1
          "ce864b17ea0e24a91e77c7dd3eb2d1ac4175b3f0"),
}
