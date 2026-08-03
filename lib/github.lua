-- GitHub download URLs.

local M = {}

---@param repo string "owner/name"
---@param tag string release tag, e.g. "v1.13.2"
---@param filename string release asset filename
---@return string url
function M.release_url(repo, tag, filename)
  return "https://github.com/" .. repo .. "/releases/download/" .. tag .. "/" .. filename
end

---A single file out of the repository itself, for projects that ship something
---worth fetching but do not attach it to their releases.
---@param repo string "owner/name"
---@param ref string tag, branch or commit sha
---@param path string repository-relative path to the file
---@return string url
function M.raw_url(repo, ref, path)
  return "https://raw.githubusercontent.com/" .. repo .. "/" .. ref .. "/" .. path
end

return M
