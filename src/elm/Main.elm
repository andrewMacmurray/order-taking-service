module Main exposing (main)

import OrderTaking.Context
import OrderTaking.Service as Service
import OrderTaking.Types.Domain exposing (PlaceOrderError, PlaceOrderEvent, UnvalidatedOrder)
import OrderTaking.Workflow



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
    = OrderPlaced UnvalidatedOrder



-- Init


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OrderPlaced order ->
            ( model, processOrder order )


processOrder : UnvalidatedOrder -> Cmd msg
processOrder =
    placeOrder >> OrderTaking.Context.orderProcessed


placeOrder : UnvalidatedOrder -> Result PlaceOrderError (List PlaceOrderEvent)
placeOrder =
    OrderTaking.Workflow.placeOrder
        Service.checkProductCodeExists
        Service.checkAddressExists
        Service.getProductPrice
        Service.createOrderAcknowledgementLetter
        Service.sendOrderAcknowledgement



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    OrderTaking.Context.orderPlaced OrderPlaced
