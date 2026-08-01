-- Tools published as one GitHub release archive per Rust target triple, with
-- bare binaries at the archive root. Tarballs wrap them in a
-- `<name>-<triple>/` directory; zips do not.
--
-- Every current user (uv, ruff, ty) happens to be an Astral project, but this
-- module is about the artifact shape, not the vendor: envy.python is Astral's
-- too and does not fit, since python-build-standalone ships a relocatable
-- CPython tree rather than a binary at the archive root.

local github = require("lib.github")
local platform = require("lib.platform")
local versions = require("lib.versions")

local M = {}

---Spec globals for one such tool.
---@param tool table `{ name, repo, hashes, binaries? }` — `hashes` is a function
---  returning the version -> triple -> sha256 table (a function, not the table,
---  so specs can keep theirs at the bottom of the file); `binaries` defaults to
---  `{ name }`, and each entry becomes a product.
---@return table globals `{ OPTIONS, FETCH, STAGE, PRODUCTS }`
function M.tool(tool)
  local products = {}
  for _, binary in ipairs(tool.binaries or { tool.name }) do
    products[binary] = binary .. envy.EXE_EXT
  end

  return {
    OPTIONS = function() versions.validate(tool.hashes()) end,

    FETCH = function(tmp_dir, opts)
      local triple = platform.rust_triple()
      return {
        source = github.release_url(tool.repo, opts.version,
          tool.name .. "-" .. triple .. platform.ARCHIVE_EXT),
        sha256 = versions.lookup(tool.hashes(), opts.version, triple),
      }
    end,

    STAGE = { strip = platform.WINDOWS and 0 or 1 },

    PRODUCTS = products,
  }
end

return M
