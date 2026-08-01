-- GitHub release URLs.

local M = {}

---@param repo string "owner/name"
---@param tag string release tag, e.g. "v1.13.2"
---@param filename string release asset filename
---@return string url
function M.release_url(repo, tag, filename)
  return "https://github.com/" .. repo .. "/releases/download/" .. tag .. "/" .. filename
end

return M
