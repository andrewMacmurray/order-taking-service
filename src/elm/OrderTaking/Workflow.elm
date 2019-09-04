module OrderTaking.Workflow exposing
    ( AddressValidationError(..)
    , CheckAddressExists
    , CheckProductCodeExists
    , CheckedAddress(..)
    , CreateOrderAcknowledgmentLetter
    , GetProductPrice
    , HtmlString(..)
    , SendOrderAcknowledgment
    , SendResult(..)
    , Service
    , placeOrder
    )

import OrderTaking.Types.Compound exposing (Address, CustomerInfo, PersonalName)
import OrderTaking.Types.Domain
    exposing
        ( BillableOrderPlacedDetails
        , OrderAcknowledgmentSent
        , OrderLine
        , OrderPlaced
        , PlaceOrder
        , PlaceOrderError(..)
        , PlaceOrderEvent(..)
        , PricedOrder
        , PricedOrderLine
        , PricingError(..)
        , UnvalidatedAddress
        , UnvalidatedCustomerInfo
        , UnvalidatedOrder
        , UnvalidatedOrderLine
        , ValidationError(..)
        )
import OrderTaking.Types.Simple as Simple
    exposing
        ( EmailAddress
        , OrderId
        , OrderLineId
        , OrderQuantity
        , Price
        , ProductCode
        , toEmailAddress
        , toString50
        , toZipCode
        )
import Task exposing (Task)
import Utils.Result as Result
import Utils.Task as Task



-- Validation Step


type alias CheckProductCodeExists =
    ProductCode -> Bool


type AddressValidationError
    = InvalidFormat
    | AddressNotFound


type CheckedAddress
    = CheckedAddress UnvalidatedAddress


type alias CheckAddressExists =
    UnvalidatedAddress -> Task AddressValidationError CheckedAddress



-- Validated Order


type alias ValidatedOrderLine =
    { orderLineId : OrderLineId
    , productCode : ProductCode
    , quantity : OrderQuantity
    }


type alias ValidatedOrder =
    { orderId : OrderId
    , customerInfo : CustomerInfo
    , shippingAddress : Address
    , billingAddress : Address
    , lines : List ValidatedOrderLine
    }


type alias ValidateOrder =
    UnvalidatedOrder -> Task ValidationError ValidatedOrder



-- Pricing Step


type alias GetProductPrice =
    ProductCode -> Price


type alias PriceOrder =
    ValidatedOrder -> Result PricingError PricedOrder



-- Send Order Acknowledgement


type HtmlString
    = HtmlString String


type alias OrderAcknowledgment =
    { emailAddress : EmailAddress
    , letter : HtmlString
    }


type alias CreateOrderAcknowledgmentLetter =
    PricedOrder -> HtmlString


type SendResult
    = Sent
    | NotSent


type alias SendOrderAcknowledgment =
    OrderAcknowledgment -> SendResult


type alias AcknowledgeOrder =
    PricedOrder -> Maybe OrderAcknowledgmentSent



-- Create Events


type alias CreateEvents =
    PricedOrder
    -> Maybe OrderAcknowledgmentSent
    -> List PlaceOrderEvent



-- Validate Order


validateOrder : CheckAddressExists -> CheckProductCodeExists -> ValidateOrder
validateOrder checkAddressExists checkProductCodeExists input =
    let
        validateAddress =
            toCheckedAddress checkAddressExists
                >> Task.andThen toAddress

        orderLines =
            input.lines
                |> List.map (toValidatedOrderLine checkProductCodeExists)
                |> Result.combine

        toValidatedOrder shipping billing =
            apply ValidatedOrder
                |> withField (Simple.toOrderId input.orderId)
                |> withNested (toCustomerInfo input.customerInfo)
                |> withNested (Ok shipping)
                |> withNested (Ok billing)
                |> withNested orderLines
                |> Result.toTask
    in
    Task.andThen2
        toValidatedOrder
        (validateAddress input.shippingAddress)
        (validateAddress input.billingAddress)


toCustomerInfo : UnvalidatedCustomerInfo -> Result ValidationError CustomerInfo
toCustomerInfo info =
    let
        personalName =
            apply PersonalName
                |> withString50 info.firstName
                |> withString50 info.lastName
    in
    apply CustomerInfo
        |> withNested personalName
        |> withField (toEmailAddress info.emailAddress)


toAddress : CheckedAddress -> Task ValidationError Address
toAddress (CheckedAddress address) =
    apply Address
        |> withString50 address.line1
        |> withString50 address.line2
        |> withString50 address.line3
        |> withString50 address.line4
        |> withString50 address.city
        |> withField (toZipCode address.zipCode)
        |> Result.toTask


toCheckedAddress : CheckAddressExists -> UnvalidatedAddress -> Task ValidationError CheckedAddress
toCheckedAddress checkAddressExists =
    checkAddressExists >> Task.mapError toAddressError


toProductCode : CheckProductCodeExists -> String -> Result String ProductCode
toProductCode checkProductCodeExists =
    Simple.toProductCode >> Result.andThen (mapProductCheck checkProductCodeExists)


toValidatedOrderLine : CheckProductCodeExists -> UnvalidatedOrderLine -> Result ValidationError ValidatedOrderLine
toValidatedOrderLine checkProductExists line =
    let
        orderLineId =
            Simple.toOrderLineId line.orderLineId

        productCode =
            toProductCode checkProductExists line.productCode

        quantity =
            productCode |> Result.andThen (\code -> Simple.toOrderQuantity code line.quantity)
    in
    apply ValidatedOrderLine
        |> withField orderLineId
        |> withField productCode
        |> withField quantity



-- Pricing


priceOrder : GetProductPrice -> PriceOrder
priceOrder getProductPrice order =
    let
        lines =
            order.lines
                |> List.map (toPricedOrderLine getProductPrice)
                |> Result.combine

        amountToBill =
            lines
                |> Result.map (List.map .linePrice)
                |> Result.andThen (Simple.billingTotal >> Result.mapError PricingError)

        toPricedOrder =
            PricedOrder order.orderId
                order.customerInfo
                order.shippingAddress
                order.billingAddress
    in
    Result.map2 toPricedOrder amountToBill lines


toPricedOrderLine : GetProductPrice -> ValidatedOrderLine -> Result PricingError PricedOrderLine
toPricedOrderLine getProductPrice line =
    let
        linePrice =
            getProductPrice line.productCode
                |> Simple.multiplyPrice (Simple.orderQuantity line.quantity)
                |> Result.mapError PricingError

        toPricedOrderLine_ =
            PricedOrderLine line.orderLineId
                line.productCode
                line.quantity
    in
    Result.map toPricedOrderLine_ linePrice



-- Acknowledge Order


acknowledgeOrder : CreateOrderAcknowledgmentLetter -> SendOrderAcknowledgment -> AcknowledgeOrder
acknowledgeOrder createOrderAcknowledgementLetter sendOrderAcknowledgement pricedOrder =
    let
        acknowledgement =
            OrderAcknowledgment
                pricedOrder.customerInfo.emailAddress
                (createOrderAcknowledgementLetter pricedOrder)
    in
    case sendOrderAcknowledgement acknowledgement of
        Sent ->
            Just <| OrderAcknowledgmentSent pricedOrder.orderId pricedOrder.customerInfo.emailAddress

        NotSent ->
            Nothing



-- Create Events


createEvents : CreateEvents
createEvents pricedOrder maybeAcknowledgementSent =
    let
        acknowledgementEvent =
            maybeAcknowledgementSent
                |> Maybe.map AcknowledgmentSent
                |> maybeToList

        orderPlacedEvent =
            pricedOrder
                |> OrderPlaced
                |> List.singleton

        billingEvent =
            pricedOrder
                |> createBillingEvent
                |> Maybe.map BillableOrderPlaced
                |> maybeToList
    in
    List.concat
        [ acknowledgementEvent
        , orderPlacedEvent
        , billingEvent
        ]


createBillingEvent : PricedOrder -> Maybe BillableOrderPlacedDetails
createBillingEvent placedOrder =
    if Simple.billingAmount placedOrder.amountToBill > 0 then
        Just <|
            BillableOrderPlacedDetails
                placedOrder.orderId
                placedOrder.billingAddress
                placedOrder.amountToBill

    else
        Nothing


maybeToList : Maybe a -> List a
maybeToList =
    Maybe.map List.singleton >> Maybe.withDefault []



-- Place Order Workflow


type alias Service =
    { checkProductCodeExists : CheckProductCodeExists
    , checkAddressExists : CheckAddressExists
    , getProductPrice : GetProductPrice
    , createOrderAcknowledgementLetter : CreateOrderAcknowledgmentLetter
    , sendOrderAcknowledgement : SendOrderAcknowledgment
    }


placeOrder : Service -> PlaceOrder
placeOrder service unvalidatedOrder =
    unvalidatedOrder
        |> validateOrder service.checkAddressExists service.checkProductCodeExists
        |> Task.mapError Validation
        |> getPricedOrder service.getProductPrice
        |> Task.map (getEvents service)


getEvents : Service -> PricedOrder -> List PlaceOrderEvent
getEvents service order =
    order
        |> acknowledgeOrder service.createOrderAcknowledgementLetter service.sendOrderAcknowledgement
        |> createEvents order


getPricedOrder : GetProductPrice -> Task PlaceOrderError ValidatedOrder -> Task PlaceOrderError PricedOrder
getPricedOrder getProductPrice =
    Task.andThen
        (priceOrder getProductPrice
            >> Result.toTask
            >> Task.mapError Pricing
        )



-- Helpers


apply : value -> Result error value
apply =
    Ok


withString50 =
    withField << toString50


withField : Result String value -> Result ValidationError (value -> b) -> Result ValidationError b
withField x =
    Result.andMap <| mapValidationError x


withNested : Result e a -> Result e (a -> b) -> Result e b
withNested =
    Result.andMap


mapValidationError : Result String value -> Result ValidationError value
mapValidationError =
    Result.mapError ValidationError


mapProductCheck : (value -> Bool) -> value -> Result String value
mapProductCheck checkExists code =
    if checkExists code then
        Ok code

    else
        Err "invalid product code"


toAddressError : AddressValidationError -> ValidationError
toAddressError err =
    case err of
        AddressNotFound ->
            ValidationError "Address not found"

        InvalidFormat ->
            ValidationError "Invalid Format"
