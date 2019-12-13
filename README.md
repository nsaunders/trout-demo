# trout-demo [![build status](https://img.shields.io/travis/nsaunders/trout-demo.svg)](https://travis-ci.org/nsaunders/trout-demo)
## A demo of the Trout library and client/server code sharing in PureScript

[Trout](https://github.com/purescript-hyper/purescript-trout) is a type-level routing DSL. Similar to Haskell's [Servant](https://github.com/haskell-servant/servant) library, Trout allows routes to be specified as a data type. For example, a `GET /api/tasks` route that responds with an `Array Task` in JSON format can be represented as `"api" :/ "tasks" :> Resource (Get (Array Task) JSON)`. Trout provides various combinators for matching literal URL segments, parsing route parameters, extracting headers, reading the request body, and more.

Multiple options exist for building an HTTP server from a Trout specification. These are helpful because they allow request handlers to focus on domain logic rather than uninteresting protocol-level details. One such option is [`purescript-hypertrout`](https://github.com/purescript-hyper/purescript-hypertrout), originally by [Oskar Wickström](https://wickstrom.tech) (who also started the Trout project). The other option, demonstrated here, is [`purescript-nodetrout`](https://github.com/nsaunders/purescript-nodetrout).

Build client:
```
spago bundle-app --to static/app.js --main Client
```

Run server:
```
spago run --main Server
```
