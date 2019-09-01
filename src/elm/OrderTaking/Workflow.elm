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
import Utils.Result



-- Validation Step


type alias CheckProductCodeExists =
    ProductCode -> Bool


type AddressValidationError
    = InvalidFormat
    | AddressNotFound


type CheckedAddress
    = CheckedAddress UnvalidatedAddress


type alias CheckAddressExists =
    UnvalidatedAddress
    -> Result AddressValidationError CheckedAddress -- (Async)



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
    CheckProductCodeExists -- dependency
    -> CheckAddressExists -- dependency (Async)
    -> UnvalidatedOrder -- input
    -> Result ValidationError ValidatedOrder -- (Async) output



-- Pricing Step


type alias GetProductPrice =
    ProductCode -> Price


type alias PriceOrder =
    GetProductPrice -- dependency
    -> ValidatedOrder -- input
    -> Result PricingError PricedOrder -- output



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
    CreateOrderAcknowledgmentLetter -- dependency
    -> SendOrderAcknowledgment -- dependency
    -> PricedOrder -- input
    -> Maybe OrderAcknowledgmentSent -- output



-- Create Events


type alias CreateEvents =
    PricedOrder -- input
    -> Maybe OrderAcknowledgmentSent -- input (event from previous step)
    -> List PlaceOrderEvent -- output



-- Validate Order


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


toAddress : CheckedAddress -> Result ValidationError Address
toAddress (CheckedAddress address) =
    apply Address
        |> withString50 address.line1
        |> withString50 address.line2
        |> withString50 address.line3
        |> withString50 address.line4
        |> withString50 address.city
        |> withField (toZipCode address.zipCode)


toCheckedAddress : CheckAddressExists -> UnvalidatedAddress -> Result ValidationError CheckedAddress
toCheckedAddress checkExists address =
    address
        |> checkExists
        |> Result.mapError toAddressError


toProductCode : CheckProductCodeExists -> String -> Result String ProductCode
toProductCode checkExists productCode =
    productCode
        |> Simple.toProductCode
        |> Result.andThen (mapProductCheck checkExists)


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


validateOrder : ValidateOrder
validateOrder checkCodeExists checkAddressExists input =
    let
        orderId =
            Simple.toOrderId input.orderId

        customerInfo =
            toCustomerInfo input.customerInfo

        shippingAddress =
            input.shippingAddress
                |> toCheckedAddress checkAddressExists
                |> Result.andThen toAddress

        billingAddress =
            input.billingAddress
                |> toCheckedAddress checkAddressExists
                |> Result.andThen toAddress

        orderLines =
            input.lines
                |> List.map (toValidatedOrderLine checkCodeExists)
                |> Utils.Result.combine
    in
    apply ValidatedOrder
        |> withField orderId
        |> withNested customerInfo
        |> withNested shippingAddress
        |> withNested billingAddress
        |> withNested orderLines



-- Pricing


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


priceOrder : PriceOrder
priceOrder getProductPrice order =
    let
        lines =
            order.lines
                |> List.map (toPricedOrderLine getProductPrice)
                |> Utils.Result.combine

        amountToBill =
            lines
                |> Result.map (List.map .linePrice)
                |> Result.andThen (Simple.billingTotal >> Result.mapError PricingError)

        toPricedOrder_ =
            PricedOrder order.orderId
                order.customerInfo
                order.shippingAddress
                order.billingAddress
    in
    Result.map2 toPricedOrder_ amountToBill lines



-- Acknowledge Order


acknowledgeOrder : AcknowledgeOrder
acknowledgeOrder createLetter sendAcknowledgement pricedOrder =
    let
        acknowledgement =
            OrderAcknowledgment
                pricedOrder.customerInfo.emailAddress
                (createLetter pricedOrder)
    in
    case sendAcknowledgement acknowledgement of
        Sent ->
            Just <| OrderAcknowledgmentSent pricedOrder.orderId pricedOrder.customerInfo.emailAddress

        NotSent ->
            Nothing



-- Create Events


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



-- Place Order Workflow


placeOrder :
    CheckProductCodeExists
    -> CheckAddressExists
    -> GetProductPrice
    -> CreateOrderAcknowledgmentLetter
    -> SendOrderAcknowledgment
    -> PlaceOrder
placeOrder checkProduct checkAddress getPrice createLetter sendAcknowledgement unvalidatedOrder =
    let
        validatedOrder =
            validateOrder checkProduct checkAddress unvalidatedOrder
                |> Result.mapError Validation

        pricedOrder =
            validatedOrder
                |> Result.andThen (priceOrder getPrice >> Result.mapError Pricing)

        acknowledgement =
            pricedOrder
                |> Result.toMaybe
                |> Maybe.andThen (acknowledgeOrder createLetter sendAcknowledgement)
    in
    case pricedOrder of
        Ok order ->
            Ok <| createEvents order acknowledgement

        Err err ->
            Err err



-- Helpers


apply : value -> Result error value
apply =
    Ok


withString50 =
    withField << toString50


withField : Result String value -> Result ValidationError (value -> b) -> Result ValidationError b
withField x =
    Utils.Result.andMap <| mapValidationError x


withNested : Result e a -> Result e (a -> b) -> Result e b
withNested =
    Utils.Result.andMap


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
