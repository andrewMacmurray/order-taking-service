module OrderTaking.Service exposing (service)

import OrderTaking.Types.Simple exposing (unsafePrice__)
import OrderTaking.Workflow
    exposing
        ( CheckAddressExists
        , CheckProductCodeExists
        , CheckedAddress(..)
        , CreateOrderAcknowledgmentLetter
        , GetProductPrice
        , HtmlString(..)
        , SendOrderAcknowledgment
        , SendResult(..)
        , Service
        )
import Task



-- Services


service : Service
service =
    { checkProductCodeExists = checkProductCodeExists
    , checkAddressExists = checkAddressExists
    , getProductPrice = getProductPrice
    , createOrderAcknowledgementLetter = createOrderAcknowledgementLetter
    , sendOrderAcknowledgement = sendOrderAcknowledgement
    }


checkProductCodeExists : CheckProductCodeExists
checkProductCodeExists code =
    True


checkAddressExists : CheckAddressExists
checkAddressExists unvalidatedAddress =
    Task.succeed <| CheckedAddress unvalidatedAddress


getProductPrice : GetProductPrice
getProductPrice code =
    unsafePrice__ 50


createOrderAcknowledgementLetter : CreateOrderAcknowledgmentLetter
createOrderAcknowledgementLetter order =
    HtmlString "<p>order acknowledged</p>"


sendOrderAcknowledgement : SendOrderAcknowledgment
sendOrderAcknowledgement acknowledgement =
    Sent
