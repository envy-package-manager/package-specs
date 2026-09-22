# envy package specs

First-party [envy](https://github.com/envy-package-manager/envy) package specs. The repo
is one envy bundle: `envy.package-specs@r6`. Needs envy 0.4.7 or newer, for
`envy.loadenv_bundle` and `ENVY_BUNDLE`.

## Use

```lua
-- your envy.lua
BUNDLES = {
  ["first-party"] = {
    identity = "envy.package-specs@r6",
    source = "https://github.com/envy-package-manager/package-specs.git",
    ref = "<commit sha>",
  },
}

PACKAGES = {
  { spec = "envy.cmake@r1", bundle = "first-party", options = { version = "4.4.3" } },
  { spec = "envy.ninja@r0", bundle = "first-party", options = { version = "1.13.2" } },
}
```

`examples/envy.lua` pulls all of them from a local checkout.

## Helpers

`lib/` is public: `envy.loadenv_bundle` reaches it from a manifest, and a spec that
declared this bundle reaches it with `envy.loadenv_spec`. `lib.github` builds
`envy.github@r0` entries, so a manifest names a library in a line rather than spelling
out the spec, the bundle alias and the vendor path every time.

```lua
VENDOR_ROOT = "vendor"

local gh = envy.loadenv_bundle("first-party", "lib.github")

PACKAGES = {
  gh.repo("libb64", "libb64/libb64", "ce864b17ea0e24a91e77c7dd3eb2d1ac4175b3f0"),

  gh.release("nanoprintf", "charlesnicholson/nanoprintf", {
    tag = "v0.8.0", asset = "nanoprintf-v0.8.0.zip", strip = 1,
    only = { "nanoprintf.h" },
    sha256 = "f0a1f76db77c47df9e8a028dec7d3317fa021b16d10691ea80e5d79b56a13109" }),

  gh.repo("hidapi", "libusb/hidapi", "4ebce6b5059b086d05ca7e091ce04a5fd08ac3ac",
          { vendor = "third_party/hidapi", platforms = { "linux" } }),
}
```

Each entry vendors to `<VENDOR_ROOT>/<name>` on its own, with a clone one level down
inside that (`vendor/libb64/libb64`), which is the shape a submodule of the same name
had. Per entry, `vendor = "<dir>"` puts it somewhere else and `vendor = false` leaves it
in the cache. `VENDOR_ROOT` is read when a builder runs, not when the helper loads, so it
can be set either side of the `envy.loadenv_bundle` call — but only by the root manifest,
which is envy's rule rather than this helper's.

The trailing table holds both halves of an entry: keys `envy.github@r0` declares
(`tag`, `asset`, `sha256`, `strip`, `only`, `dest`) become its options, and anything else
(`vendor`, `platforms`, `needed_by`) is a key on the `PACKAGES` entry itself.

Nothing is handed back in. An entry these builders return has to name a bundle, and the
helper reads the alias the calling file used out of `ENVY_BUNDLE`, which envy seeds into
a module it loads from a bundle.

## Specs

| spec | options | products |
| --- | --- | --- |
| `envy.cmake@r1` | `version` | `cmake` `ctest` `cpack` |
| `envy.doctest-cpp@r0` | `version` | `doctest_cpp_dir` `doctest_cpp_h` |
| `envy.github@r0` | `repo` `ref` `dest` `tag` `asset` `sha256` `strip` `only` | — |
| `envy.gn@r1` | `ref` | `gn` |
| `envy.ninja@r0` | `version` | `ninja` |
| `envy.protobuf@r1` | `version` | `protoc` `protobuf_includes` |
| `envy.python@r2` | `version` `release` `provide_python` `provide_python3` | `python<maj>.<min>`, plus `python`/`python3` when asked |
| `envy.ruff@r1` | `version` | `ruff` |
| `envy.swig@r1` | `version` | `swig` `swiglibdir` |
| `envy.ty@r1` | `version` | `ty` |
| `envy.uv@r1` | `version` | `uv` `uvx` |

Prebuilt downloads, except SWIG, which builds from source on Unix against a PCRE2 it
statically links itself, and uses the prebuilt swigwin on Windows. Python comes from
[python-build-standalone](https://github.com/astral-sh/python-build-standalone), so
`release` pins the build and `version` the interpreter. doctest is the amalgamated
`doctest.h` and nothing else: `doctest_cpp_dir` is the package directory to put on a
`-I` line, `doctest_cpp_h` the header inside it. [GN](https://gn.googlesource.com/gn) is
the one spec without a `version` because it cuts no releases: `ref` is a git revision and
the binary comes from that revision's
[CIPD package](https://chrome-infra-packages.appspot.com/p/gn/gn).

`envy.github@r0` is the odd one out: it names no tool and pins nothing, because the
manifest entry supplies the repository. Two forms, and exactly one of them per entry --
a clone at a commit (`repo` and `ref`, with `dest` naming the directory the clone lands
in) or one release asset unpacked (`repo`, `tag`, `asset` and `sha256`, narrowed by
`strip` and `only`, which mean what they mean to `envy.extract`). It declares no products
because the package is a source tree rather than a binary: consumers vendor it, or reach
it with `envy.package`. A third-party library that needs build phases of its own still
writes its own spec -- this is for the ones that just need to be in the tree. Manifests
usually reach it through `lib.github` rather than writing the entry out; see above.

## Layout

```
envy-bundle.lua   bundle identity + spec paths
specs/            one spec per tool
lib/              shared helpers: require("lib.<name>") from a spec in this bundle,
                  envy.loadenv_bundle("<alias>", "lib.<name>") from a manifest
examples/         sample manifest
```

## Adding a version

Every download is hash-verified, so a version only exists once its hashes are recorded.
(`envy.github@r0` records none: its hash rides on the manifest entry, which is why its
release form insists on a `sha256` that envy itself would let you omit.)

1. Get the hashes: a release checksum asset if upstream publishes one (`.sha256`
   sidecars, `SHA256SUMS`, `cmake-<v>-SHA-256.txt`), else download and `shasum -a 256`.
2. Add a `hashes["<version>"]` entry with one hash per platform key. Every platform key
   already in the table needs one.
3. Bump the spec's revision and the bundle's, and update `envy-bundle.lua`, the
   table above and `examples/envy.lua` to match. Consumers pin a spec revision, so
   revving is what lets a manifest ask for the new version.

Conventions: `version` never carries a leading `v` (specs add it to the tag), platform
keys are upstream's own artifact naming, and products are named after the binary. GN's
hash table is keyed by git revision instead, one entry per `ref`.
