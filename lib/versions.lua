-- Helpers for the `hashes[version][platform_key]` tables that specs in this
-- bundle use to pin their downloads. Every download is verified, so a version
-- exists for a spec only once its hashes are recorded.

local M = {}

local function sorted_keys(t)
  local out = {}
  for key in pairs(t) do out[#out + 1] = key end
  table.sort(out)
  return out
end

-- Segment-wise numeric compare so 4.10.0 sorts after 4.9.0. Segments split on
-- `.`, `-` and `+`; non-numeric segments fall back to string compare.
local function version_lt(a, b)
  local a_seg, b_seg = a:gmatch("[^.+-]+"), b:gmatch("[^.+-]+")
  while true do
    local x, y = a_seg(), b_seg()
    if not x then return y ~= nil end
    if not y then return false end
    local nx, ny = tonumber(x), tonumber(y)
    if nx and ny then
      if nx ~= ny then return nx < ny end
    elseif x ~= y then
      return x < y
    end
  end
end

---Versions recorded in a hash table, ascending.
---@param hashes table
---@return string[]
function M.list(hashes)
  local out = sorted_keys(hashes)
  table.sort(out, version_lt)
  return out
end

---Constrain `version` to the recorded versions. Call from an OPTIONS function,
---which runs after the spec file has loaded, so specs can keep their hash
---tables at the bottom.
---@param hashes table
---@param extra? table additional envy.options() constraints
function M.validate(hashes, extra)
  local schema = { version = { required = true, choices = M.list(hashes) } }
  for key, constraint in pairs(extra or {}) do schema[key] = constraint end
  envy.options(schema)
end

---Recorded hash for (version, platform_key).
---A miss means either an unsupported host or a version whose hash for this
---host was never recorded, so the error spells out what is available.
---@param hashes table
---@param version string
---@param platform_key string
---@return string
function M.lookup(hashes, version, platform_key)
  local by_platform = hashes[version]
  assert(by_platform, "no sha256 recorded for version '" .. tostring(version) ..
    "'; recorded: " .. table.concat(M.list(hashes), ", "))

  local hash = by_platform[platform_key]
  assert(hash, "version '" .. version .. "' has no sha256 for '" .. platform_key ..
    "'; recorded: " .. table.concat(sorted_keys(by_platform), ", "))

  return hash
end

return M
