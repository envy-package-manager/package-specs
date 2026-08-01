-- @envy schema "1"
IDENTITY = "envy.ty@r0"
EXPORTABLE = true

local hashes -- version -> triple -> sha256, populated at the bottom of this file

local ty = require("lib.rust_binary").tool {
  name = "ty",
  repo = "astral-sh/ty",
  hashes = function() return hashes end,
}

OPTIONS = ty.OPTIONS
FETCH = ty.FETCH
STAGE = ty.STAGE
PRODUCTS = ty.PRODUCTS

-- https://github.com/astral-sh/ty/releases
-- Hashes come from the `<asset>.sha256` files in each release.
hashes = {
  ["0.0.63"] = {
    ["aarch64-apple-darwin"] =
    "30d09000d5f2524769816c57f85e19505676d23618aad6a43e046d5c50510988",
    ["x86_64-apple-darwin"] =
    "5a18373c8bd6894be5f595a2cbefa4e72b7d5b95cfe2c2f075024a949064bba9",
    ["aarch64-unknown-linux-musl"] =
    "e44b9da55ec237a8e8c53991c9df56603d2948d721c9710ec430e4112e2fbe6e",
    ["x86_64-unknown-linux-musl"] =
    "363c340abc2490f3cfd7d9b829ff89cd8e79a41f8d9db911bf78dae48c36c436",
    ["x86_64-pc-windows-msvc"] =
    "f9476788c8c27c328bff1b4691dbb1aa6f1591e103e630caffb9ccb70648a1a0",
  },
}
