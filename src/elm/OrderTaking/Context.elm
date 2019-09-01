port module OrderTaking.Context exposing
    ( orderPlaced
    , orderProcessed
    )

import OrderTaking.DataTransfer as DataTransfer
import OrderTaking.Types.Domain
    exposing
        ( PlaceOrderError
        , PlaceOrderEvent
        , UnvalidatedOrder
        , ValidationError
        )



-- Order Events


port orderPlaced : (UnvalidatedOrder -> msg) -> Sub msg


orderProcessed : Result PlaceOrderError (List PlaceOrderEvent) -> Cmd msg
orderProcessed result =
    case result of
        Ok events ->
            orderSucceeded <| List.map DataTransfer.encodeEvent events

        Err err ->
            orderFailed <| DataTransfer.encodeError err



-- Internal


port orderSucceeded : List DataTransfer.Event -> Cmd msg


port orderFailed : DataTransfer.Error -> Cmd msg
