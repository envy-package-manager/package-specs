-- @envy schema "1"
IDENTITY = "envy.doctest-cpp@r0"
EXPORTABLE = true

local github = require("lib.github")
local versions = require("lib.versions")

local hashes

OPTIONS = function() versions.validate(hashes) end

FETCH = function(tmp_dir, opts)
  return {
    source = github.raw_url("doctest/doctest", "v" .. opts.version, "doctest/doctest.h"),
    sha256 = hashes[opts.version],
  }
end

PRODUCTS = {
  doctest_cpp_dir = { value = ".", script = false },
  doctest_cpp_h = { value = "doctest.h", script = false },
}

-- https://github.com/doctest/doctest/releases
-- 2.5.x attaches only a source tarball, so the header comes from the tag. Same
-- bytes as the `doctest/doctest.h` inside `doctest-v<version>.tar.gz`.
hashes = {
  ["2.5.0"] = "a58efc9446d70ddd5dd3b7724ebb8742882860f36f46da64d62993b02911fb6f",
  ["2.5.1"] = "1c3586fe6537a231412eb8d93a5f2efa6b7c954731fac9ce31070e941dbe013b",
  ["2.5.2"] = "1f2978b948f5958d5b6ee8dc16d8284317715d6e4fafb47956b1578198d19f66",
  ["2.5.3"] = "cfd518a3ef90f67e1f3ba514df23fb3627437de1a2feeba78cf5062a40021421",
}
