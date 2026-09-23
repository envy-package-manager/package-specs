-- @envy schema "1"
IDENTITY = "envy.github@r1"
EXPORTABLE = true

local github = require("lib.github")

OPTIONS = function(opts)
  envy.options({
    repo = { type = "string", required = true }, -- "owner/name"

    -- Clone form.
    ref = { type = "string" },
    dest = { type = "string" },

    -- Release form.
    tag = { type = "string" },
    asset = { type = "string" },
    sha256 = { type = "string" },
    strip = { type = "int" },
    only = { type = "list" },
    archives = { type = "list" },
  })

  if opts.asset then
    if opts.ref then return "`ref` clones and `asset` downloads: name one, not both" end
    if not opts.tag then return "`asset` needs the `tag` of the release it hangs off" end
    if not opts.sha256 then return "`asset` needs a `sha256`" end
  elseif not opts.ref then
    return "needs a `ref` to clone, or a `tag` and `asset` to download"
  end
end

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

STAGE = function(fetch_dir, stage_dir, tmp_dir, opts)
  if not opts.asset then return end
  envy.extract_all(fetch_dir, stage_dir, { strip = opts.strip, only = opts.only,
                                            archives = opts.archives })
end
