module OrderTaking.DataTransfer exposing
    ( Error
    , Event
    , encodeError
    , encodeEvent
    )

import Json.Encode as Encode
import OrderTaking.Types.Compound exposing (Address, CustomerInfo, PersonalName)
import OrderTaking.Types.Domain
    exposing
        ( BillableOrderPlacedDetails
        , OrderAcknowledgmentSent
        , OrderPlaced
        , PlaceOrderError(..)
        , PlaceOrderEvent(..)
        , PricedOrderLine
        , PricingError(..)
        , RemoteServiceError(..)
        , ValidationError(..)
        )
import OrderTaking.Types.Simple as Simple



-- PlaceOrder Events


type alias Event =
    { event : String
    , timeStamp : Float
    , data : String
    }


type alias Error =
    { error : String
    , reason : String
    }


encodeEvent : PlaceOrderEvent -> Event
encodeEvent evt =
    case evt of
        OrderPlaced order ->
            eventWrapper "OrderPlaced" <| encodeOrderPlaced order

        BillableOrderPlaced order ->
            eventWrapper "BillableOrderPlaced" <| encodeBillableOrderPlaced order

        AcknowledgmentSent acknowledgement ->
            eventWrapper "AcknowledgementSent" <| encodeAcknowledgementSent acknowledgement



-- PlaceOrder Errors


encodeError : PlaceOrderError -> Error
encodeError err =
    case err of
        Validation (ValidationError err_) ->
            errorWrapper "Validation Error" err_

        Pricing (PricingError err_) ->
            errorWrapper "Pricing Error" err_

        RemoteService (RemoteServiceError err_) ->
            errorWrapper "Service Error" err_



-- Helpers


encodeAcknowledgementSent : OrderAcknowledgmentSent -> Encode.Value
encodeAcknowledgementSent acknowledgement =
    Encode.object
        [ ( "orderId", orderId acknowledgement.orderId )
        , ( "emailAddress", email acknowledgement.emailAddress )
        ]


encodeBillableOrderPlaced : BillableOrderPlacedDetails -> Encode.Value
encodeBillableOrderPlaced details =
    Encode.object
        [ ( "orderId", orderId details.orderId )
        , ( "billingAddress", encodeAddress details.billingAddress )
        , ( "amountToBill", billingAmount details.amountToBill )
        ]


encodeOrderPlaced : OrderPlaced -> Encode.Value
encodeOrderPlaced o =
    Encode.object
        [ ( "orderId", orderId o.orderId )
        , ( "customerInfo", encodeCustomerInfo o.customerInfo )
        , ( "shippingAddress", encodeAddress o.shippingAddress )
        , ( "billingAddress", encodeAddress o.billingAddress )
        , ( "amountToBill", billingAmount o.amountToBill )
        , ( "orderLines", Encode.list encodeOrderLine o.lines )
        ]


encodeOrderLine : PricedOrderLine -> Encode.Value
encodeOrderLine line =
    Encode.object
        [ ( "orderLineId", orderLineId line.orderLineId )
        , ( "productCode", productCode line.productCode )
        , ( "quantity", quantity line.quantity )
        , ( "linePrice", linePrice line.linePrice )
        ]


encodeAddress : Address -> Encode.Value
encodeAddress address =
    Encode.object
        [ ( "line1", string50 address.line1 )
        , ( "line2", string50 address.line2 )
        , ( "line3", string50 address.line3 )
        , ( "line4", string50 address.line4 )
        , ( "city", string50 address.city )
        , ( "zipCode", zip address.zipCode )
        ]


encodeCustomerInfo : CustomerInfo -> Encode.Value
encodeCustomerInfo info =
    Encode.object
        [ ( "name", encodeName info.name )
        , ( "emailAddress", email info.emailAddress )
        ]


encodeName : PersonalName -> Encode.Value
encodeName name =
    Encode.object
        [ ( "firstName", string50 name.firstName )
        , ( "lastName", string50 name.lastName )
        ]



-- Wrappers


eventWrapper : String -> Encode.Value -> Event
eventWrapper eventName data =
    { event = eventName
    , timeStamp = 0
    , data = Encode.encode 2 data
    }


errorWrapper : String -> String -> Error
errorWrapper =
    Error



-- Fields


linePrice : Simple.Price -> Encode.Value
linePrice =
    Encode.float << Simple.price


quantity : Simple.OrderQuantity -> Encode.Value
quantity =
    Encode.float << Simple.orderQuantity


productCode : Simple.ProductCode -> Encode.Value
productCode =
    Encode.string << Simple.productCode


orderLineId : Simple.OrderLineId -> Encode.Value
orderLineId =
    Encode.string << Simple.orderLineId


billingAmount : Simple.BillingAmount -> Encode.Value
billingAmount =
    Encode.float << Simple.billingAmount


zip : Simple.ZipCode -> Encode.Value
zip =
    Encode.string << Simple.zipCode


orderId : Simple.OrderId -> Encode.Value
orderId =
    Encode.string << Simple.orderId


email : Simple.EmailAddress -> Encode.Value
email =
    Encode.string << Simple.emailAddress


string50 : Simple.String50 -> Encode.Value
string50 =
    Encode.string << Simple.string50
