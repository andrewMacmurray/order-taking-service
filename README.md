# Domain Driven Design Example - Apollo Elm Server

An 'Order Taking Service' adapted from an example in [Domain Modeling Made Functional](https://pragprog.com/book/swdddf/domain-modeling-made-functional)


## What is it?

+ A TypeScript Apollo Graphql Server
+ An embedded Elm worker program (the Domain Brain!)

The server implements a single Mutation: `placeOrder` which runs a number of validations on the input, calls some fake services and returns either the recorded `PlaceOrderEvents` or `Errors` that occur.

## How to run it

install dependencies

```
> npm install
```

bundle the server

```
> npm run build
```

start the server with

```
> npm run serve
```

Visit the `graphiql` playground at `http://localhost:4000` to try out the service.

![Screen Shot 2019-09-01 at 23 37 01](https://user-images.githubusercontent.com/14013616/64083105-98034500-cd11-11e9-9644-4e25ed23e3f3.png)

