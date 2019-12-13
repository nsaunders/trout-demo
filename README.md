# trout-demo [![build status](https://img.shields.io/travis/nsaunders/trout-demo.svg)](https://travis-ci.org/nsaunders/trout-demo)
## A demo of the Trout library and client/server code sharing in PureScript

[Trout](https://github.com/purescript-hyper/purescript-trout) is a type-level routing DSL. Similar to Haskell's [Servant](https://github.com/haskell-servant/servant) library, Trout allows routes to be specified as a data type. For example, a `GET /api/tasks` route that responds with an `Array Task` in JSON format can be represented as `"api" :/ "tasks" :> Resource (Get (Array Task) JSON`. Trout provides various combinators for matching literal URL segments, parsing route parameters, extracting headers, reading the request body, and more.

This app demonstrates the use of [`purescript-nodetrout`](https://github.com/nsaunders/purescript-nodetrout)
and [`purescript-trout-client`](https://github.com/purescript-hyper/purescript-trout-client) to build a REST
API and client.

Build client:
```
spago bundle-app --to static/app.js --main Client
```

Run server:
```
spago run --main Server
```
