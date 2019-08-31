import { ApolloServer } from "apollo-server";
import * as typeDefs from "./schema.graphql";
import { resolvers } from "./resolvers";
import { Elm } from "../elm/Main";

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: Elm.Main.init({ flags: null })
});

server.listen().then(({ url }) => {
  console.log(`server ready at ${url}`);
});
