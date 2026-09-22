-- GitHub download URLs, and the manifest-side builders for `envy.github@r0`.

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

local SPEC_OPTIONS = {
  repo = true, ref = true, dest = true,
  tag = true, asset = true, sha256 = true, strip = true, only = true,
}

local function bundle_alias()
  local alias = ENVY_BUNDLE and ENVY_BUNDLE.alias
  return alias or error("lib.github: the entry builders are manifest scope -- reach " ..
    "this file with envy.loadenv_bundle(\"<alias>\", \"lib.github\")")
end

---@param name string
---@param base table spec options the builder fixed itself
---@param t? table the caller's table, split between options and entry keys
local function entry(name, base, t)
  local options = {}
  for key, value in pairs(base) do options[key] = value end

  local e = { spec = "envy.github@r0", bundle = bundle_alias() }
  for key, value in pairs(t or {}) do
    if SPEC_OPTIONS[key] then options[key] = value else e[key] = value end
  end

  if e.vendor == nil then
    e.vendor = VENDOR_ROOT and (VENDOR_ROOT .. "/" .. name) or true
  end

  e.options = options
  return e
end

---A clone at a commit, as a `PACKAGES` entry. `dest` names the directory the
---clone lands in after the library, so the package holds the repository the way
---a checkout of it would. Manifest scope: reach this file with
---`envy.loadenv_bundle`, not `require`.
---
---    local gh = envy.loadenv_bundle("first-party", "lib.github")
---    PACKAGES = { gh.repo("libb64", "libb64/libb64", "ce864b1...") }
---
---@param name string leaf name, and the directory inside the package
---@param repo string "owner/name"
---@param ref string commit sha
---@param t? table more spec options, and any entry keys
---@return table entry
function M.repo(name, repo, ref, t)
  return entry(name, { repo = repo, ref = ref, dest = name }, t)
end

---One asset of a release, unpacked, as a `PACKAGES` entry. `strip` and `only`
---narrow what comes out of the archive.
---@param name string leaf name
---@param repo string "owner/name"
---@param t table `tag`, `asset`, `sha256`, optional `strip`/`only`, entry keys
---@return table entry
function M.release(name, repo, t)
  return entry(name, { repo = repo }, t)
end

return M
