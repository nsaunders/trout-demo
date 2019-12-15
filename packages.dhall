let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.13.5-20191215/src/packages.dhall sha256:fdc5d54cd54213000100fbc13c90dce01668a73fe528d8662430558df3411bee

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
