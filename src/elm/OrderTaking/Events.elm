port module OrderTaking.Events exposing
    ( onOrderResult
    , orderReceived
    )

import OrderTaking
    exposing
        ( PlaceOrderError
        , PlaceOrderEvents
        , UnvalidatedOrder
        , ValidationError
        )



-- Order Events


port orderReceived : (UnvalidatedOrder -> msg) -> Sub msg


onOrderResult : Result PlaceOrderError PlaceOrderEvents -> Cmd msg
onOrderResult result =
    case result of
        Ok res ->
            orderProcessed res

        Err err ->
            orderFailed <| OrderTaking.errors err



-- Internal


port orderProcessed : PlaceOrderEvents -> Cmd msg


port orderFailed : List ValidationError -> Cmd msg
