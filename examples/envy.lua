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
    identity = "envy.package-specs@r3",
    source = envy.abspath(".."),
  },
}

PACKAGES = {
  { spec = "envy.python@r1", bundle = "first-party",
    options = { version = "3.13.14", release = "20260623", provide_python3 = true } },

  { spec = "envy.uv@r0", bundle = "first-party", options = { version = "0.11.30" } },

  { spec = "envy.ruff@r0", bundle = "first-party", options = { version = "0.16.0" } },

  { spec = "envy.ty@r0", bundle = "first-party", options = { version = "0.0.63" } },

  { spec = "envy.cmake@r0", bundle = "first-party", options = { version = "4.4.0" } },

  { spec = "envy.ninja@r0", bundle = "first-party", options = { version = "1.13.2" } },

  -- GN is keyed by git revision, not version -- see the README.
  { spec = "envy.gn@r0", bundle = "first-party",
    options = { ref = "10d3ab4387f7f4ad0d3fb9d626218a6e09e71d86" } },

  { spec = "envy.protobuf@r0", bundle = "first-party", options = { version = "35.1" } },

  { spec = "envy.swig@r0", bundle = "first-party", options = { version = "4.4.1" } },

  { spec = "envy.doctest-cpp@r0", bundle = "first-party", options = { version = "2.5.3" } },
}
