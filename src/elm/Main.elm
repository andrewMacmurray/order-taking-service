module Main exposing (main)

import OrderTaking.Context
import OrderTaking.Service as Service
import OrderTaking.Types.Domain exposing (PlaceOrderError, PlaceOrderEvent, UnvalidatedOrder)
import OrderTaking.Workflow
import Task exposing (Task)



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
    | OrderProcessed (Result PlaceOrderError (List PlaceOrderEvent))



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

        OrderProcessed result ->
            ( model, OrderTaking.Context.orderProcessed result )


processOrder : UnvalidatedOrder -> Cmd msg
processOrder =
    placeOrder >> Task.attempt OrderProcessed


placeOrder : UnvalidatedOrder -> Task PlaceOrderError (List PlaceOrderEvent)
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
