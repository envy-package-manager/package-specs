# envy package specs

First-party [envy](https://github.com/envy-package-manager/envy) package specs. The repo
is one envy bundle: `envy.package-specs@r3`.

## Use

```lua
-- your envy.lua
BUNDLES = {
  ["first-party"] = {
    identity = "envy.package-specs@r3",
    source = "git://github.com/envy-package-manager/package-specs",
    ref = "<commit sha>",
  },
}

PACKAGES = {
  { spec = "envy.cmake@r0", bundle = "first-party", options = { version = "4.4.0" } },
  { spec = "envy.ninja@r0", bundle = "first-party", options = { version = "1.13.2" } },
}
```

`examples/envy.lua` pulls all of them from a local checkout.

## Specs

| spec | options | products |
| --- | --- | --- |
| `envy.cmake@r0` | `version` | `cmake` `ctest` `cpack` |
| `envy.doctest-cpp@r0` | `version` | `doctest_cpp_dir` `doctest_cpp_h` |
| `envy.gn@r0` | `ref` | `gn` |
| `envy.ninja@r0` | `version` | `ninja` |
| `envy.protobuf@r0` | `version` | `protoc` `protobuf_includes` |
| `envy.python@r1` | `version` `release` `provide_python` `provide_python3` | `python<maj>.<min>`, plus `python`/`python3` when asked |
| `envy.ruff@r0` | `version` | `ruff` |
| `envy.swig@r0` | `version` `pcre2` | `swig` `swiglibdir` |
| `envy.ty@r0` | `version` | `ty` |
| `envy.uv@r0` | `version` | `uv` `uvx` |

Prebuilt downloads, except SWIG, which builds from source on Unix (`--without-pcre`
unless `pcre2 = true`, which needs PCRE2 dev files on the host) and uses the prebuilt
swigwin on Windows. Python comes from
[python-build-standalone](https://github.com/astral-sh/python-build-standalone), so
`release` pins the build and `version` the interpreter. doctest is the amalgamated
`doctest.h` and nothing else: `doctest_cpp_dir` is the package directory to put on a
`-I` line, `doctest_cpp_h` the header inside it. [GN](https://gn.googlesource.com/gn) is
the one spec without a `version` because it cuts no releases: `ref` is a git revision and
the binary comes from that revision's
[CIPD package](https://chrome-infra-packages.appspot.com/p/gn/gn).

## Layout

```
envy-bundle.lua   bundle identity + spec paths
specs/            one spec per tool
lib/              shared helpers, require("lib.<name>") from any spec
examples/         sample manifest
```

## Adding a version

Every download is hash-verified, so a version only exists once its hashes are recorded.

1. Get the hashes: a release checksum asset if upstream publishes one (`.sha256`
   sidecars, `SHA256SUMS`, `cmake-<v>-SHA-256.txt`), else download and `shasum -a 256`.
2. Add a `hashes["<version>"]` entry with one hash per platform key. Every platform key
   already in the table needs one.
3. Leave `IDENTITY` alone — a new version isn't an interface change.

Conventions: `version` never carries a leading `v` (specs add it to the tag), platform
keys are upstream's own artifact naming, and products are named after the binary. GN's
hash table is keyed by git revision instead, one entry per `ref`.
