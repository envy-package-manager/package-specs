-- @envy schema "1"
IDENTITY = "envy.uv@r2"
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
  ["0.12.8"] = {
    ["aarch64-apple-darwin"] =
    "8ce083658dbff20143607ca7af8e0c1d64b6fd7bf03a5cdcb62bf3d47d991b5f",
    ["x86_64-apple-darwin"] =
    "bfcd4407de99e0a2c1904df0902fa1795653d4edd145358e6561527e746a4f16",
    ["aarch64-unknown-linux-musl"] =
    "975917badc8370163989e5bbe5a7c69bf922d19f8e57cb2652531bbffc935f84",
    ["x86_64-unknown-linux-musl"] =
    "6ca4597639c97e921fb915e113061ce8e4a14ead9e42a1ead521dbb0a6763795",
    ["x86_64-pc-windows-msvc"] =
    "e07acf3f8a29fe41f9e04b799c3325cb0e0893836bb222bf102829b45c679ad6",
  },
  ["0.12.17"] = {
    ["aarch64-apple-darwin"] =
    "85f00cbdc6dd3e97eba4c31b4d014375a9fdfe8f570023b84e5102fc3456896b",
    ["x86_64-apple-darwin"] =
    "8dcf05a8c809bb3c471d2b614788ba27a6e41298fc8c31ac84b5f4339fd468e5",
    ["aarch64-unknown-linux-musl"] =
    "a6096da273d548cb9f277d237a01ac7344a39ef0f455c0e148e4dc9737c1596b",
    ["x86_64-unknown-linux-musl"] =
    "6401c4665d8fa2a9893e087c91f585430738e3170f5398a1141483efb4a93310",
    ["x86_64-pc-windows-msvc"] =
    "a252121d5b59398fcb137c6ea448176459a44010f33f67e0072305a637119ca7",
  },
}
