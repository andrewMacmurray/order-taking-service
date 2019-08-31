module OrderTaking exposing
    ( GizmoCode
    , PlaceOrderError
    , PlaceOrderEvents
    , ProductCode(..)
    , UnvalidatedOrder
    , ValidationError
    , WidgetCode
    , errors
    , placeOrder
    )

import OrderTaking.Quantity as Quantity
import OrderTaking.ShippingAddress as ShippingAddress
import Utils.NonEmptyList exposing (NonEmptyList)



-- Simple types


type ProductCode
    = Widget WidgetCode
    | Gizmo GizmoCode


type WidgetCode
    = WidgetCode String


type GizmoCode
    = GizmoCode String



-- Order life cycle


type OrderId
    = OrderId


type OrderLineId
    = OrderLineId


type CustomerId
    = CustomerId


type CustomerInfo
    = CustomerInfo


type BillingAddress
    = BillingAddress


type Price
    = Price


type BillingAmount
    = BillingAmount


type alias OrderLine =
    { id : OrderLineId
    , orderId : OrderId
    , productCode : ProductCode
    , orderQuantity : Quantity.Order
    , price : Price
    }


type alias Order =
    { id : OrderId
    , customerId : CustomerId
    , shippingAddress : ShippingAddress.Validated
    , billingAddress : BillingAddress
    , orderLines : NonEmptyList OrderLine
    , amountToBill : BillingAmount
    }



-- Entry


type alias UnvalidatedOrder =
    { orderId : String
    , customerInfo : String
    , shippingAddress : String
    , billingAddress : String
    , orderLine : List String
    }



-- Exit


type alias PlaceOrderEvents =
    { acknowledgementSent : Bool
    , orderPlaced : Bool
    , billableOrderPlaced : Bool
    }


type PlaceOrderError
    = Validation (List ValidationError)


type alias ValidationError =
    { field : String
    , errorDescription : String
    }



-- Place Order


placeOrder : UnvalidatedOrder -> Result PlaceOrderError PlaceOrderEvents
placeOrder order =
    if order.billingAddress /= "bleh" then
        Ok
            { acknowledgementSent = True
            , orderPlaced = True
            , billableOrderPlaced = False
            }

    else
        Err <| Validation [ { field = order.billingAddress, errorDescription = "Y this address eh?" } ]


errors : PlaceOrderError -> List ValidationError
errors (Validation xs) =
    xs
