{ name =
    "trout-demo"
, dependencies =
    [ "b64"
    , "console"
    , "effect"
    , "halogen"
    , "node-http"
    , "nodetrout"
    , "psci-support"
    , "refs"
    , "transformers"
    , "trout"
    , "trout-client"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}
