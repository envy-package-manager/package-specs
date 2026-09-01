-- @envy schema "1"
IDENTITY = "envy.ty@r1"
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
  ["0.0.77"] = {
    ["aarch64-apple-darwin"] =
    "d86ca04e12c7b110d95cebe7b192ae0164f596605e28e081c1b71a0ee30ea711",
    ["x86_64-apple-darwin"] =
    "6da0da90db79b01f8552f0d7cda40151d54d55b70982c6d1046f818ab9b0b5d3",
    ["aarch64-unknown-linux-musl"] =
    "38730d0146a07536e8e67d8f4ab7a806f24a3fc7510d056b63ef6a3a349b98c0",
    ["x86_64-unknown-linux-musl"] =
    "b538162da342afd5462fb68812baaa1c6a80d1cce92aa869ed6a35247e094ae9",
    ["x86_64-pc-windows-msvc"] =
    "b07f6bdce4cc2b0e496b7d936694f6227c63942af1104f881e7e660a7f56fe8a",
  },
}
