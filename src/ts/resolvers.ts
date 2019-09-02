import { Resolvers, MutationResolvers } from "./generated/types";

const placeOrder: MutationResolvers["placeOrder"] = (_, { order }, context) => {
  const { orderId } = order;
  const worker = context.worker();
  return new Promise(resolve => {
    worker.orderSucceeded.subscribe(events =>
      resolve({ success: true, orderId, events })
    );
    worker.orderFailed.subscribe(error =>
      resolve({ success: false, orderId, error })
    );
    worker.orderPlaced.send(order);
  });
};

export const resolvers: Resolvers = {
  Query: { version: () => "1.0.0" },
  Mutation: { placeOrder }
};
