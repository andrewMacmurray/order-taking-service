module OrderTaking.Service exposing
    ( checkAddressExists
    , checkProductCodeExists
    , createOrderAcknowledgementLetter
    , getProductPrice
    , sendOrderAcknowledgement
    )

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
        )



-- Services


checkProductCodeExists : CheckProductCodeExists
checkProductCodeExists code =
    True


checkAddressExists : CheckAddressExists
checkAddressExists unvalidatedAddress =
    Ok <| CheckedAddress unvalidatedAddress


getProductPrice : GetProductPrice
getProductPrice code =
    unsafePrice__ 50


createOrderAcknowledgementLetter : CreateOrderAcknowledgmentLetter
createOrderAcknowledgementLetter order =
    HtmlString "<p>order acknowledged</p>"


sendOrderAcknowledgement : SendOrderAcknowledgment
sendOrderAcknowledgement acknowledgement =
    Sent
