let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.5-20191127/packages.dhall sha256:654e8427ff1f9830542f491623cd5d89b1648774a765520554f98f41d3d1b3b3

let overrides = { trout-client = ../purescript-trout-client/spago.dhall as Location }

let additions = {=}

in  upstream // overrides // additions
