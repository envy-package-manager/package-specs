-- @envy schema "1"
IDENTITY = "envy.uv@r0"
EXPORTABLE = true

local hashes -- version -> triple -> sha256, populated at the bottom of this file

local uv = require("lib.rust_binary").tool {
  name = "uv",
  repo = "astral-sh/uv",
  binaries = { "uv", "uvx" },
  hashes = function() return hashes end,
}

OPTIONS = uv.OPTIONS
FETCH = uv.FETCH
STAGE = uv.STAGE
PRODUCTS = uv.PRODUCTS

-- https://github.com/astral-sh/uv/releases
-- Hashes come from the `<asset>.sha256` files in each release.
hashes = {
  ["0.11.30"] = {
    ["aarch64-apple-darwin"] =
    "9bed3567d496d8dab84ecf7a1247551ac94ef1baaebb7b65df008dd93e9dc357",
    ["x86_64-apple-darwin"] =
    "ce285fbbfbe294b1e1bc6c87c8b59d9622b85383b88b2b132a2df5c73e83d7c1",
    ["aarch64-unknown-linux-musl"] =
    "7562a40e4e08b1bfd566bd6aeca55a16ee5ac45211554543e8cdb3c395b47416",
    ["x86_64-unknown-linux-musl"] =
    "023fdd3b59fccfb67b365c69fb34182aaaed1d685d367a57571e3c1468a4c70c",
    ["x86_64-pc-windows-msvc"] =
    "be8d78c992312212e5cc05e9f9de3fa996db73b7c86a186dfb9231eb9f91d33e",
  },
}
