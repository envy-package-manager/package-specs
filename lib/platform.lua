-- Platform naming shared by the specs in this bundle.

local M = {}

M.WINDOWS = envy.PLATFORM == "windows"

-- Windows release artifacts are almost always zips, everything else tarballs.
M.ARCHIVE_EXT = M.WINDOWS and ".zip" or ".tar.gz"

-- Rust-style target triple, matching how Rust projects name their GitHub
-- release artifacts. Linux picks musl so the binaries are static and work
-- regardless of the host's glibc.
function M.rust_triple()
  if envy.PLATFORM == "darwin" then
    return (envy.ARCH == "arm64") and "aarch64-apple-darwin" or "x86_64-apple-darwin"
  elseif envy.PLATFORM == "linux" then
    return (envy.ARCH == "x86_64") and "x86_64-unknown-linux-musl"
        or "aarch64-unknown-linux-musl"
  end
  return "x86_64-pc-windows-msvc"
end

return M
