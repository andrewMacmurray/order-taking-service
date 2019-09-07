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


type alias Success =
    { events : List DataTransfer.Event
    }


type alias Error =
    { error : DataTransfer.Error
    }



-- Order Interop


port orderPlaced : (UnvalidatedOrder -> msg) -> Sub msg


orderProcessed : Result PlaceOrderError (List PlaceOrderEvent) -> Cmd msg
orderProcessed result =
    case result of
        Ok events ->
            orderSucceeded
                { events = List.map DataTransfer.encodeEvent events
                }

        Err err ->
            orderFailed
                { error = DataTransfer.encodeError err
                }



-- Internal


port orderSucceeded : Success -> Cmd msg


port orderFailed : Error -> Cmd msg
