module OrderTaking.Types.Domain exposing
    ( BillableOrderPlacedDetails
    , Command
    , Order
    , OrderAcknowledgmentSent
    , OrderLine
    , OrderPlaced
    , PlaceOrder
    , PlaceOrderError(..)
    , PlaceOrderEvent(..)
    , PricedOrder
    , PricedOrderLine
    , PricingError(..)
    , RemoteServiceError(..)
    , UnvalidatedAddress
    , UnvalidatedCustomerInfo
    , UnvalidatedOrder
    , UnvalidatedOrderLine
    , ValidationError(..)
    )

import OrderTaking.Types.Compound exposing (Address, CustomerInfo)
import OrderTaking.Types.Simple
    exposing
        ( BillingAmount
        , EmailAddress
        , OrderId
        , OrderLineId
        , OrderQuantity
        , Price
        , ProductCode
        )
import Utils.NonEmptyList exposing (NonEmptyList)



-- Inputs


type alias UnvalidatedCustomerInfo =
    { firstName : String
    , lastName : String
    , emailAddress : String
    }


type alias UnvalidatedAddress =
    { line1 : String
    , line2 : String
    , line3 : String
    , line4 : String
    , city : String
    , zipCode : String
    }


type alias UnvalidatedOrderLine =
    { orderLineId : String
    , productCode : String
    , quantity : Float
    }


type alias UnvalidatedOrder =
    { orderId : String
    , customerInfo : UnvalidatedCustomerInfo
    , shippingAddress : UnvalidatedAddress
    , billingAddress : UnvalidatedAddress
    , lines : List UnvalidatedOrderLine
    }



-- Validated


type alias Command data =
    { timeStamp : Int
    , userId : String
    , data : data
    }


type alias OrderLine =
    { id : OrderLineId
    , orderId : OrderId
    , productCode : ProductCode
    , orderQuantity : OrderQuantity
    , price : Price
    }


type alias Order =
    { id : OrderId
    , customerInfo : CustomerInfo
    , shippingAddress : Address
    , billingAddress : Address
    , orderLines : NonEmptyList OrderLine
    , amountToBill : BillingAmount
    }



-- Exit


type alias OrderAcknowledgmentSent =
    { orderId : OrderId
    , emailAddress : EmailAddress
    }


type alias PricedOrderLine =
    { orderLineId : OrderLineId
    , productCode : ProductCode
    , quantity : OrderQuantity
    , linePrice : Price
    }


type alias PricedOrder =
    { orderId : OrderId
    , customerInfo : CustomerInfo
    , shippingAddress : Address
    , billingAddress : Address
    , amountToBill : BillingAmount
    , lines : List PricedOrderLine
    }


type alias OrderPlaced =
    PricedOrder


type alias BillableOrderPlacedDetails =
    { orderId : OrderId
    , billingAddress : Address
    , amountToBill : BillingAmount
    }


type PlaceOrderEvent
    = OrderPlaced OrderPlaced
    | BillableOrderPlaced BillableOrderPlacedDetails
    | AcknowledgmentSent OrderAcknowledgmentSent



-- Errors


type PlaceOrderError
    = Validation ValidationError
    | Pricing PricingError
    | RemoteService RemoteServiceError


type PricingError
    = PricingError String


type ValidationError
    = ValidationError String


type RemoteServiceError
    = RemoteServiceError String



-- Place Order


type alias PlaceOrder =
    UnvalidatedOrder -> Result PlaceOrderError (List PlaceOrderEvent)
