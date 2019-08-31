import { Resolvers, MutationResolvers } from "./generated/types";

const placeOrder: MutationResolvers["placeOrder"] = (_, args, context) => {
  return new Promise(resolve => {
    context.ports.orderProcessed.subscribe(() => {
      resolve({ success: true });
    });
    context.ports.orderFailed.subscribe(() => {
      resolve({ success: false });
    });
    context.ports.orderReceived.send(args.order);
  });
};

export const resolvers: Resolvers = {
  Query: { version: () => "1.0.0" },
  Mutation: { placeOrder }
};
