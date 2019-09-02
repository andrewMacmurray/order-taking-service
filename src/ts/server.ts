import { ApolloServer } from "apollo-server";
import * as typeDefs from "./schema.graphql";
import { resolvers } from "./resolvers";
import { context } from "./context";

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context
});

server.listen().then(({ url }) => {
  console.log(`graphql server listening at ${url}`);
});
