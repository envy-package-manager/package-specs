-- Sample manifest pulling every spec out of this bundle.
--
-- The bundle source here is the checkout this file lives in, so the example
-- runs against local edits. Real projects use a git source and pinned ref --
-- see the README.
--
-- @envy schema "1"
-- @envy bin "bin"
-- @envy deploy "true"
-- @envy root "true"

BUNDLES = {
  ["first-party"] = {
    identity = "envy.package-specs@r5",
    source = envy.abspath(".."),
  },
}

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
}
