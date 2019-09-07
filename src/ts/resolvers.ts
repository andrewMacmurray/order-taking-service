import { Resolvers, MutationResolvers } from "./generated/types";
import * as Workflow from "./workflow";

const placeOrder: MutationResolvers["placeOrder"] = (_, { order }, context) => {
  const worker = context.worker();
  return Workflow.process(order, {
    onSuccess: worker.orderSucceeded,
    onError: worker.orderFailed,
    start: worker.orderPlaced
  });
};

export const resolvers: Resolvers = {
  Query: { version: () => "1.0.0" },
  Mutation: { placeOrder }
};
