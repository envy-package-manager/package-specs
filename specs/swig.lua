-- @envy schema "1"
IDENTITY = "envy.swig@r2"
EXPORTABLE = true

local platform = require("lib.platform")
local versions = require("lib.versions")

local hashes -- version -> archive -> sha256, populated at the bottom of this file
local pcre2  -- the pinned PCRE2 source tarball, likewise

local function swig_archive(version)
  return platform.WINDOWS and ("swigwin-" .. version .. ".zip")
      or ("swig-" .. version .. ".tar.gz")
end

local function pcre2_archive()
  return "pcre2-" .. pcre2.version .. ".tar.gz"
end

OPTIONS = function() versions.validate(hashes) end

-- SourceForge is the only place upstream publishes these artifacts: the GitHub
-- repo carries release tags but cuts no GitHub releases, so there is no asset
-- mirror to prefer, and the swigwin zip's prebuilt swig.exe exists nowhere else.
-- downloads.sourceforge.net 302s to a mirror picked per request, and an
-- occasional mirror accepts the connection and then stalls mid-body, so a fetch
-- failure here is usually transient and lands on a different mirror next time.
--
-- Unix builds SWIG against its own static PCRE2, so both tarballs are named in
-- one array: envy downloads the elements of a returned array concurrently.
FETCH = function(tmp_dir, opts)
  local sourceforge = "https://downloads.sourceforge.net/project/swig/"

  if platform.WINDOWS then
    return {
      source = sourceforge .. "swigwin/swigwin-" .. opts.version .. "/" ..
          swig_archive(opts.version),
      sha256 = versions.lookup(hashes, opts.version, "windows"),
    }
  end

  return {
    {
      source = sourceforge .. "swig/swig-" .. opts.version .. "/" ..
          swig_archive(opts.version),
      sha256 = versions.lookup(hashes, opts.version, "source"),
    },
    {
      source = "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-" ..
          pcre2.version .. "/" .. pcre2_archive(),
      sha256 = pcre2.sha256,
    },
  }
end

-- Only SWIG gets unpacked. Tools/pcre-build.sh wants the PCRE2 tarball intact
-- and sitting in the directory SWIG is configured from.
STAGE = function(fetch_dir, stage_dir, tmp_dir, opts)
  envy.extract(envy.path.join(fetch_dir, swig_archive(opts.version)), stage_dir,
    { strip = 1 })

  if platform.WINDOWS then return end

  envy.copy(envy.path.join(fetch_dir, pcre2_archive()),
    envy.path.join(stage_dir, pcre2_archive()))
end

BUILD = function(install_dir, stage_dir, fetch_dir, tmp_dir, opts)
  if platform.WINDOWS then return end -- swigwin ships a prebuilt swig.exe

  -- pcre-build.sh locates the tarball by globbing `pcre2-*.tar*` here, then
  -- builds and installs it as a static library under pcre/pcre-swig-install/.
  -- Handing configure that pcre2-config by absolute path keeps the build
  -- hermetic: an absolute PCRE2_CONFIG suppresses the PATH search outright, so
  -- a system PCRE2 (Homebrew, apt) can never be picked up, and a missing local
  -- one fails the build instead of silently falling back to the host.
  return envy.template([[
Tools/pcre-build.sh
./configure --prefix={{prefix}} PCRE2_CONFIG={{pcre2_config}}
make -j
]], {
    prefix = install_dir,
    pcre2_config = envy.path.join(stage_dir, "pcre/pcre-swig-install/bin/pcre2-config"),
  })
end

INSTALL = function(install_dir, stage_dir, fetch_dir, tmp_dir, opts)
  if not platform.WINDOWS then return "make install" end

  -- swigwin is not a configure/make tree: place the binary and its Lib/
  -- directory of .i interface files by hand.
  envy.move(envy.path.join(stage_dir, "swig.exe"), envy.path.join(install_dir, "swig.exe"))
  envy.move(envy.path.join(stage_dir, "Lib"), envy.path.join(install_dir, "Lib"))
end

PRODUCTS = function(opts)
  return {
    swig = (platform.WINDOWS and "" or "bin/") .. "swig" .. envy.EXE_EXT,
    -- SWIG_LIB: where swig looks for its .i interface files.
    swiglibdir = {
      value = platform.WINDOWS and "Lib" or ("share/swig/" .. opts.version),
      script = false,
    },
  }
end

-- https://sourceforge.net/projects/swig/files/
-- SWIG publishes no checksums; hashes were computed from the downloads.
-- `source` is the tarball built on Unix; `windows` is the prebuilt swigwin zip.
hashes = {
  ["4.5.1"] = {
    source = "7fec50b27deddab5455a9633780b6341eddfb96215a7619e93a76eb27178f653",
    windows = "6a8662c063ba4d1e72beaecef24da4af3d631d73ffdde958fb42aa50fdefb962",
  },
  ["4.5.0"] = {
    source = "22ae0e887f8cca8031a325c67d005207653200b40e71edb3f88780e28e47d0ff",
    windows = "d08a5b5cfd3f285ccc13b9ee0667f6e05d07433aaae89e8ae24850e05e62e04e",
  },
  ["4.4.1"] = {
    source = "40162a706c56f7592d08fd52ef5511cb7ac191f3593cf07306a0a554c6281fcf",
    windows = "ce01474c81120eab381491d8d45cbcce4768fd1e5c23ffc7654b522702769598",
  },
}

-- https://github.com/PCRE2Project/pcre2/releases
-- Pinned here rather than exposed as an option: this is a private build-time
-- dependency of the Unix build, not something a manifest picks.
pcre2 = {
  version = "10.48",
  sha256 = "ebcc25aadf2a51fa1fefa9b8bc9e7a79b3dae86870a0f1152a22e42befd46888",
}
