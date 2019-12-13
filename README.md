# trout-demo

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
