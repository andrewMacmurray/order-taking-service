import { Resolvers, MutationResolvers } from "./generated/types";

const placeOrder: MutationResolvers["placeOrder"] = (_, args, context) => {
  const { orderId } = args.order
  return new Promise(resolve => {
    context.ports.orderSucceeded.subscribe(events => {
      resolve({ success: true, orderId, events });
    });
    context.ports.orderFailed.subscribe(error => {
      resolve({ success: false, orderId, error });
    });
    context.ports.orderPlaced.send(args.order);
  });
};

export const resolvers: Resolvers = {
  Query: { version: () => "1.0.0" },
  Mutation: { placeOrder }
};
