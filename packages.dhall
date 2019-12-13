let upstream =
      https://raw.githubusercontent.com/nsaunders/package-sets/trout-client/src/packages.dhall sha256:03c186d61e9d7c17909481a6a65107115d719370d9dfa0bfef13f0acaffcfc42

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
