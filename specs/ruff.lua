-- @envy schema "1"
IDENTITY = "envy.ruff@r1"
EXPORTABLE = true

local hashes -- version -> triple -> sha256, populated at the bottom of this file

local ruff = require("lib.rust_binary").tool {
  name = "ruff",
  repo = "astral-sh/ruff",
  hashes = function() return hashes end,
}

OPTIONS = ruff.OPTIONS
FETCH = ruff.FETCH
STAGE = ruff.STAGE
PRODUCTS = ruff.PRODUCTS

-- https://github.com/astral-sh/ruff/releases
-- Hashes come from the `<asset>.sha256` files in each release.
hashes = {
  ["0.16.0"] = {
    ["aarch64-apple-darwin"] =
    "ce6564491a2cc4b0659f45ee174dbef17e4dec24e03a9c03d313b5430bc21099",
    ["x86_64-apple-darwin"] =
    "3d9ef6228c4eeb26d593c398b2dc5250e0f6d6425933db2993fcf30d49c78b69",
    ["aarch64-unknown-linux-musl"] =
    "7a6add3d38768dfa00c6d3853e9bd940b5526f3fbb76f02b1fe77ec0653f1e0e",
    ["x86_64-unknown-linux-musl"] =
    "2138b7bc58ff877f5bba09aea4cc984ad5699433b6a3f811003527b8cff8e9ad",
    ["x86_64-pc-windows-msvc"] =
    "c5d1185c47261f86361d03b547da25be79120226a6f1721d623b2aba9d27668b",
  },
  ["0.16.5"] = {
    ["aarch64-apple-darwin"] =
    "ed142f8656e0092828c103dd058b55b871c88e13a801cade8f860d8a9ca8943e",
    ["x86_64-apple-darwin"] =
    "4895245fe294cd9f38b8c941b9aa009b3015729f73327bdbf8a716b7fec8f84d",
    ["aarch64-unknown-linux-musl"] =
    "ae88ae21344546a4b3e5d342360197ea8e79d3794d673cc807c6f302d8b87f03",
    ["x86_64-unknown-linux-musl"] =
    "0c560ee4a72245c6d0c9cdfd9dd69cbdc348b9448349707cf4061cea62472059",
    ["x86_64-pc-windows-msvc"] =
    "02fe2fc6d04eb4e768c34daaca4990b327ea83e84b0eac58affb924c0f554a75",
  },
}
