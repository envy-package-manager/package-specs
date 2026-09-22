-- @envy schema "1"
IDENTITY = "envy.github@r0"
EXPORTABLE = true

local github = require("lib.github")

-- "The package is a GitHub repository", in the two shapes that covers: a clone at
-- a commit, or one asset of a release unpacked. Every other spec in this bundle
-- pins a tool and its hashes; this one pins nothing, because a manifest entry
-- supplies the repository, the revision and the hash. A library that needs phases
-- of its own still writes its own spec -- this is for the ones that do not.
--
-- The forms are exclusive, and the check is cross-field, so OPTIONS is a function:
-- `envy.options` constrains the keys, the returned string rejects the shape.
OPTIONS = function(opts)
  envy.options({
    repo = { type = "string", required = true }, -- "owner/name"

    -- Clone form. `dest` names the directory the clone lands in under the staging
    -- root, which becomes the one directory in the package. It cannot be "." --
    -- envy wants a plain filename.
    ref = { type = "string" },
    dest = { type = "string" },

    -- Release form. The asset has to be an archive; `strip` drops leading path
    -- components and `only` keeps part of it, both as `envy.extract_all` takes them.
    tag = { type = "string" },
    asset = { type = "string" },
    sha256 = { type = "string" },
    strip = { type = "int" },
    only = { type = "list" },
  })

  if opts.asset then
    if opts.ref then return "`ref` clones and `asset` downloads: name one, not both" end
    if not opts.tag then return "`asset` needs the `tag` of the release it hangs off" end
    -- A commit sha pins a clone by itself; a release asset is a mutable URL, so it
    -- gets the same treatment as every other download in this bundle.
    if not opts.sha256 then return "`asset` needs a `sha256`" end
  elseif not opts.ref then
    return "needs a `ref` to clone, or a `tag` and `asset` to download"
  end
end

-- The owner says nothing a progress row needs; the repository name and its tag do.
DISPLAY = function(opts)
  local name = opts.repo:match("[^/]+$")
  return opts.tag and (name .. " " .. opts.tag) or name
end

FETCH = function(tmp_dir, opts)
  if opts.asset then
    return { source = github.release_url(opts.repo, opts.tag, opts.asset),
             sha256 = opts.sha256 }
  end
  return { source = "https://github.com/" .. opts.repo .. ".git",
           ref = opts.ref, dest = opts.dest }
end

-- A clone has already landed in the staging tree by the time this runs; only a
-- release asset needs unpacking, and only that form carries the filter options.
STAGE = function(fetch_dir, stage_dir, tmp_dir, opts)
  if not opts.asset then return end
  envy.extract_all(fetch_dir, stage_dir, { strip = opts.strip, only = opts.only })
end
