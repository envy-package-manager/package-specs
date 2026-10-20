-- The cases CI installs: every version each spec in envy-bundle.lua records,
-- read out of the specs themselves so a version is covered the moment its
-- hashes land. One manifest per case, since two versions of one spec claim
-- the same products and envy refuses that in a single manifest.
--
--   envy lua .github/ci/cases.lua
--       prints the JSON array of spec identities that have cases
--   CASES_SPEC=<identity> CASES_OUT=<existing dir> envy lua .github/ci/cases.lua
--       writes <dir>/<label>.lua for each of that spec's cases

local ROOT = envy.abspath("../..")

local function sorted_keys(t)
  local out = {}
  for key in pairs(t) do out[#out + 1] = key end
  table.sort(out)
  return out
end

local function read(path)
  local f = assert(io.open(ROOT .. path, "rb"))
  local text = f:read("a")
  f:close()
  return text
end

local function run(path, env)
  return assert(load(read(path), "@" .. path, "t", env))()
end

-- A spec file evaluated the way envy would, minus the phases, with
-- `envy.options` swapped for whatever `capture` wants to do with the schema.
local function load_spec(path, capture)
  local env = setmetatable({}, { __index = _G })
  env.envy = setmetatable({ options = capture }, { __index = envy })

  local modules = {}
  env.require = function(name)
    if modules[name] == nil then
      modules[name] = run(name:gsub("%.", "/") .. ".lua", env)
    end
    return modules[name]
  end

  run(path, env)
  return env
end

local function upvalue(fn, name)
  for i = 1, math.huge do
    local key, value = debug.getupvalue(fn, i)
    if key == nil then return nil end
    if key == name then return value end
  end
end

-- The option a spec's OPTIONS constrains to `choices`, and those choices. Past
-- its envy.options call, OPTIONS reads options that this call never set, so
-- whatever it does after that is beside the point.
local function choices(path)
  local schema
  local spec = load_spec(path, function(s) schema = s end)

  if type(spec.OPTIONS) == "table" then
    schema = spec.OPTIONS
  elseif spec.OPTIONS then
    local ok, err = pcall(spec.OPTIONS, {})
    if not ok and not schema then error(err, 0) end
  end

  local found = {}
  for name, constraint in pairs(schema or {}) do
    if type(constraint) == "table" and constraint.choices then
      found[#found + 1] = { name = name, choices = constraint.choices }
    end
  end
  if #found == 1 then return found[1] end
end

-- Specs whose OPTIONS constrains no single option to `choices`, so their cases
-- are spelled out here. A spec that is neither fails the run rather than going
-- untested.
local SPECIAL = {
  -- Hashes are keyed "<version>+<release>": the two options are pinned together.
  ["envy.python"] = function(spec)
    local cases = {}
    for _, pin in ipairs(sorted_keys(upvalue(spec.OPTIONS, "hashes"))) do
      local version, release = pin:match("^(.-)%+(.+)$")
      cases[#cases + 1] = { label = pin, options = { version = version, release = release } }
    end
    return cases
  end,

  -- Pins nothing, since the manifest entry names the repository. The examples
  -- job covers it: examples/envy.lua holds an entry of each form.
  ["envy.github"] = function() return {} end,
}

local function cases_of(identity, path)
  local special = SPECIAL[identity:match("^(.-)@")]
  if special then return special(load_spec(path, function() end)) end

  local option = choices(path)
  if not option then
    error(identity .. ": OPTIONS constrains no single option to `choices`; " ..
      "give it an entry in SPECIAL in .github/ci/cases.lua", 0)
  end

  local cases = {}
  for _, choice in ipairs(option.choices) do
    cases[#cases + 1] = { label = choice, options = { [option.name] = choice } }
  end
  return cases
end

local function lua_table(t)
  local fields = {}
  for _, key in ipairs(sorted_keys(t)) do
    fields[#fields + 1] = key .. " = " .. string.format("%q", t[key])
  end
  return "{ " .. table.concat(fields, ", ") .. " }"
end

local function manifest(bundle, envy_version, identity, options)
  return table.concat({
    '-- @envy version "' .. envy_version .. '"',
    '-- @envy schema "1"',
    '-- @envy bin "bin"',
    '-- @envy deploy "false"',
    "",
    "BUNDLES = {",
    "  ci = { identity = " .. string.format("%q", bundle) ..
        ", source = " .. string.format("%q", ROOT) .. " },",
    "}",
    "",
    "PACKAGES = {",
    "  { spec = " .. string.format("%q", identity) .. ', bundle = "ci", options = ' ..
        lua_table(options) .. " },",
    "}",
    "",
  }, "\n")
end

local bundle = {}
run("envy-bundle.lua", bundle)

local wanted = os.getenv("CASES_SPEC")
if not wanted then
  local identities = {}
  for _, identity in ipairs(sorted_keys(bundle.SPECS)) do
    if #cases_of(identity, bundle.SPECS[identity]) > 0 then
      identities[#identities + 1] = string.format("%q", identity)
    end
  end
  -- envy's print logs to stderr.
  io.write("[" .. table.concat(identities, ",") .. "]\n")
  return
end

local path = bundle.SPECS[wanted] or error("envy-bundle.lua has no spec " .. wanted, 0)
local out = os.getenv("CASES_OUT") or error("CASES_OUT is not set", 0)

-- The examples pin the oldest envy this bundle supports, so the cases do too.
local envy_version = read("examples/envy.lua"):match('%-%-%s*@envy%s+version%s+"([^"]+)"')

for _, case in ipairs(cases_of(wanted, path)) do
  local f = assert(io.open(envy.path.join(out, case.label .. ".lua"), "wb"))
  f:write(manifest(bundle.BUNDLE, envy_version, wanted, case.options))
  f:close()
end
