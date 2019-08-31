module Main exposing (main)

import OrderTaking exposing (UnvalidatedOrder)
import OrderTaking.Events



-- Program


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    {}


type Msg
    = PlaceOrder UnvalidatedOrder



-- Init


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceOrder order ->
            ( model, processOrder order )


processOrder : UnvalidatedOrder -> Cmd msg
processOrder =
    OrderTaking.placeOrder >> OrderTaking.Events.onOrderResult



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    OrderTaking.Events.orderReceived PlaceOrder
