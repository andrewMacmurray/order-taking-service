import { GraphQLResolveInfo } from 'graphql';
import { Context } from '../context';
export type Maybe<T> = T | null;
export type RequireFields<T, K extends keyof T> = { [X in Exclude<keyof T, K>]?: T[X] } & { [P in K]-?: NonNullable<T[P]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string,
  String: string,
  Boolean: boolean,
  Int: number,
  Float: number,
};

export type Address = {
  line1: Scalars['String'],
  line2: Scalars['String'],
  line3: Scalars['String'],
  line4: Scalars['String'],
  city: Scalars['String'],
  zipCode: Scalars['String'],
};

export type CustomerInfo = {
  firstName: Scalars['String'],
  lastName: Scalars['String'],
  emailAddress: Scalars['String'],
};

export type Error = {
   __typename?: 'Error',
  error: Scalars['String'],
  reason: Scalars['String'],
};

export type Event = {
   __typename?: 'Event',
  event: Scalars['String'],
  timeStamp: Scalars['Float'],
  data: Scalars['String'],
};

export type Mutation = {
   __typename?: 'Mutation',
  placeOrder: PlaceOrderResponse,
};


export type MutationPlaceOrderArgs = {
  order: Order
};

export type Order = {
  orderId: Scalars['String'],
  customerInfo: CustomerInfo,
  shippingAddress: Address,
  billingAddress: Address,
  lines: Array<OrderLine>,
};

export type OrderLine = {
  orderLineId: Scalars['String'],
  productCode: Scalars['String'],
  quantity: Scalars['Float'],
};

export type PlaceOrderResponse = {
   __typename?: 'PlaceOrderResponse',
  events?: Maybe<Array<Event>>,
  error?: Maybe<Error>,
};

export type Query = {
   __typename?: 'Query',
  version: Scalars['String'],
};


export type ResolverTypeWrapper<T> = Promise<T> | T;

export type ResolverFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => Promise<TResult> | TResult;


export type StitchingResolver<TResult, TParent, TContext, TArgs> = {
  fragment: string;
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};

export type Resolver<TResult, TParent = {}, TContext = {}, TArgs = {}> =
  | ResolverFn<TResult, TParent, TContext, TArgs>
  | StitchingResolver<TResult, TParent, TContext, TArgs>;

export type SubscriptionSubscribeFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => AsyncIterator<TResult> | Promise<AsyncIterator<TResult>>;

export type SubscriptionResolveFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

export interface SubscriptionSubscriberObject<TResult, TKey extends string, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<{ [key in TKey]: TResult }, TParent, TContext, TArgs>;
  resolve?: SubscriptionResolveFn<TResult, { [key in TKey]: TResult }, TContext, TArgs>;
}

export interface SubscriptionResolverObject<TResult, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<any, TParent, TContext, TArgs>;
  resolve: SubscriptionResolveFn<TResult, any, TContext, TArgs>;
}

export type SubscriptionObject<TResult, TKey extends string, TParent, TContext, TArgs> =
  | SubscriptionSubscriberObject<TResult, TKey, TParent, TContext, TArgs>
  | SubscriptionResolverObject<TResult, TParent, TContext, TArgs>;

export type SubscriptionResolver<TResult, TKey extends string, TParent = {}, TContext = {}, TArgs = {}> =
  | ((...args: any[]) => SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>)
  | SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>;

export type TypeResolveFn<TTypes, TParent = {}, TContext = {}> = (
  parent: TParent,
  context: TContext,
  info: GraphQLResolveInfo
) => Maybe<TTypes>;

export type NextResolverFn<T> = () => Promise<T>;

export type DirectiveResolverFn<TResult = {}, TParent = {}, TContext = {}, TArgs = {}> = (
  next: NextResolverFn<TResult>,
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

/** Mapping between all available schema types and the resolvers types */
export type ResolversTypes = {
  Query: ResolverTypeWrapper<{}>,
  String: ResolverTypeWrapper<Scalars['String']>,
  Mutation: ResolverTypeWrapper<{}>,
  Order: Order,
  CustomerInfo: CustomerInfo,
  Address: Address,
  OrderLine: OrderLine,
  Float: ResolverTypeWrapper<Scalars['Float']>,
  PlaceOrderResponse: ResolverTypeWrapper<PlaceOrderResponse>,
  Event: ResolverTypeWrapper<Event>,
  Error: ResolverTypeWrapper<Error>,
  Boolean: ResolverTypeWrapper<Scalars['Boolean']>,
};

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = {
  Query: {},
  String: Scalars['String'],
  Mutation: {},
  Order: Order,
  CustomerInfo: CustomerInfo,
  Address: Address,
  OrderLine: OrderLine,
  Float: Scalars['Float'],
  PlaceOrderResponse: PlaceOrderResponse,
  Event: Event,
  Error: Error,
  Boolean: Scalars['Boolean'],
};

export type ErrorResolvers<ContextType = Context, ParentType extends ResolversParentTypes['Error'] = ResolversParentTypes['Error']> = {
  error?: Resolver<ResolversTypes['String'], ParentType, ContextType>,
  reason?: Resolver<ResolversTypes['String'], ParentType, ContextType>,
};

export type EventResolvers<ContextType = Context, ParentType extends ResolversParentTypes['Event'] = ResolversParentTypes['Event']> = {
  event?: Resolver<ResolversTypes['String'], ParentType, ContextType>,
  timeStamp?: Resolver<ResolversTypes['Float'], ParentType, ContextType>,
  data?: Resolver<ResolversTypes['String'], ParentType, ContextType>,
};

export type MutationResolvers<ContextType = Context, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  placeOrder?: Resolver<ResolversTypes['PlaceOrderResponse'], ParentType, ContextType, RequireFields<MutationPlaceOrderArgs, 'order'>>,
};

export type PlaceOrderResponseResolvers<ContextType = Context, ParentType extends ResolversParentTypes['PlaceOrderResponse'] = ResolversParentTypes['PlaceOrderResponse']> = {
  events?: Resolver<Maybe<Array<ResolversTypes['Event']>>, ParentType, ContextType>,
  error?: Resolver<Maybe<ResolversTypes['Error']>, ParentType, ContextType>,
};

export type QueryResolvers<ContextType = Context, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  version?: Resolver<ResolversTypes['String'], ParentType, ContextType>,
};

export type Resolvers<ContextType = Context> = {
  Error?: ErrorResolvers<ContextType>,
  Event?: EventResolvers<ContextType>,
  Mutation?: MutationResolvers<ContextType>,
  PlaceOrderResponse?: PlaceOrderResponseResolvers<ContextType>,
  Query?: QueryResolvers<ContextType>,
};


/**
 * @deprecated
 * Use "Resolvers" root object instead. If you wish to get "IResolvers", add "typesPrefix: I" to your config.
*/
export type IResolvers<ContextType = Context> = Resolvers<ContextType>;
