-- @envy schema "1"
IDENTITY = "envy.ty@r4"
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
  ["0.0.83"] = {
    ["aarch64-apple-darwin"] =
    "963def3419d2558e5a057329dbbbd8de54da7d73af6668c6d7f472ceffebe2c8",
    ["x86_64-apple-darwin"] =
    "4c1f6db572119a0e461895cd241a990ef616b30258394b02161b04d6a34d0911",
    ["aarch64-unknown-linux-musl"] =
    "fc48538601ca7f9462b8d583b65bca88aba35bbe98ced5e8e72ca08794310630",
    ["x86_64-unknown-linux-musl"] =
    "019ba29db7d14023d956d08fe413fe1795f0369aa501edff0d706504879c72b4",
    ["x86_64-pc-windows-msvc"] =
    "a6ac68c919e869b97dfd2c67cafe82e6211f7cf818ba41f48eb4223fa0bac931",
  },
  ["0.0.89"] = {
    ["aarch64-apple-darwin"] =
    "c0535481dd2ca2653dbf804bb008ca2286f9ae7f284c12f52158a1853fcdc06f",
    ["x86_64-apple-darwin"] =
    "f522783404e9b96be12a7543fe6eaab26e3c9a87f639a53b13eed883e8fdb62a",
    ["aarch64-unknown-linux-musl"] =
    "7583ebea89e7ae9a5019942f0b5394a6a18a19562050b2d6ed6df576e040e328",
    ["x86_64-unknown-linux-musl"] =
    "2618c34c21096a44a797512f2533dea52d28e95a0287833719805db72874b8b1",
    ["x86_64-pc-windows-msvc"] =
    "59232824e08b30b5aed11bab9a2d1296eab75c736938f6b8884e4597700a0fb2",
  },
  ["0.0.92"] = {
    ["aarch64-apple-darwin"] =
    "8db29940906b7c9627d43f2dd458dbe11a975577ec7748a63a3c83bc84c9f957",
    ["x86_64-apple-darwin"] =
    "a8fbaf3bb604c3ce82d3a654fe5d75c5c01d9b53f36e90d50eab9456dc83fa2d",
    ["aarch64-unknown-linux-musl"] =
    "ad762b522fbb78f4340f186342761f71ae9f33fd250931106ef81a7e1442f71e",
    ["x86_64-unknown-linux-musl"] =
    "dc5415e1c0bf1f6f7093f04cba7dda201b25fe41bad091c0de63764264dac98c",
    ["x86_64-pc-windows-msvc"] =
    "6cc04731c49d9c020242ebfd453aba877b56f98871184f9d6fa7e9554dab8294",
  },
}
