-- @envy schema "1"
IDENTITY = "envy.ruff@r4"
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
  ["0.16.8"] = {
    ["aarch64-apple-darwin"] =
    "0ffa53899f2970d24f14fbed8d8265c87180b159b7100794d97a1527dc60fa79",
    ["x86_64-apple-darwin"] =
    "bccb4d49c5c9f7e69fd42df2475730a08a641af31b8e0ee5e775e3dd829c4686",
    ["aarch64-unknown-linux-musl"] =
    "57a4e072b6b74a4dd0036b7b253e056bdb70e02c68504ca6f2bfca2707d03fb6",
    ["x86_64-unknown-linux-musl"] =
    "e56aa612121de356f37d05f3284cd806081fb72d5dbd4814b3810c5a23c562cc",
    ["x86_64-pc-windows-msvc"] =
    "7985e06caf14b0077cb68da41edbf812e1d9654fe4c144d72b71138e96350129",
  },
  ["0.17.1"] = {
    ["aarch64-apple-darwin"] =
    "1c8e6e36538eaa0b996378a20c226403c4ca6369ac24884751b024d3a9530b86",
    ["x86_64-apple-darwin"] =
    "88ee16f88dba9d440e06375f46898ec85baf578042ad086764d5a33558bb6e17",
    ["aarch64-unknown-linux-musl"] =
    "255404ccf2f7950ff6aad8858321a6f416fe2a840ae4e37dfb4c21cb8774f325",
    ["x86_64-unknown-linux-musl"] =
    "2d9878b5e6a3d0dedadbfc01a64bfe54e72f560adbfd235937cd29e1fc9238e3",
    ["x86_64-pc-windows-msvc"] =
    "a841fb7e59680508b9394bfea32e369b3907cc6620a491c65d8d1f479498db82",
  },
  ["0.17.2"] = {
    ["aarch64-apple-darwin"] =
    "94fbca85f19e8b6bb068adb7cbc9a74e3e6c01004cc67c6b00246a094ad4ccd9",
    ["x86_64-apple-darwin"] =
    "db57a84e385435a2c4a7c8946e588f79b9de0851d8618a1b5d4431edfff0bf01",
    ["aarch64-unknown-linux-musl"] =
    "ba1a3a43f8afc7bda55f8be2c600a1c8966390c3de17526bb1e6c5609c2e9fa0",
    ["x86_64-unknown-linux-musl"] =
    "d6407f429ef15e558cbe980d30a67f27d02e3d2f72780be141ee006b2fdf7df3",
    ["x86_64-pc-windows-msvc"] =
    "6f4de58abd7c8de2e8702a89fc0f221e6ca858ad23e25c658c707d83a48c79a0",
  },
}
