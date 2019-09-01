module OrderTaking.Types.Simple exposing
    ( BillingAmount
    , EmailAddress
    , GizmoCode
    , Kilogram
    , OrderId
    , OrderLineId
    , OrderQuantity
    , Price
    , ProductCode
    , String50
    , Unit
    , WidgetCode
    , ZipCode
    , billingAmount
    , billingTotal
    , emailAddress
    , kilo
    , multiplyPrice
    , orderId
    , orderLineId
    , orderQuantity
    , price
    , productCode
    , string50
    , toBillingAmount
    , toEmailAddress
    , toKilogram
    , toOrderId
    , toOrderLineId
    , toOrderQuantity
    , toPrice
    , toProductCode
    , toString50
    , toUnit
    , toZipCode
    , unit
    , unsafePrice__
    , zipCode
    )

import Utils.Constrained as Constrained



-- String50


type String50
    = String50 String


toString50 : String -> Result String String50
toString50 =
    Constrained.string "String50" String50 50


string50 : String50 -> String
string50 (String50 s) =
    s



-- Product Code


type ProductCode
    = Widget WidgetCode
    | Gizmo GizmoCode


type WidgetCode
    = WidgetCode String


type GizmoCode
    = GizmoCode String


productCode : ProductCode -> String
productCode code =
    case code of
        Widget (WidgetCode c) ->
            c

        Gizmo (GizmoCode c) ->
            c


toProductCode : String -> Result String ProductCode
toProductCode str =
    if String.isEmpty str then
        Err "Product code must not be empty"

    else if String.startsWith "W" str then
        toWidgetCode str |> Result.map Widget

    else if String.startsWith "G" str then
        toGizmoCode str |> Result.map Gizmo

    else
        Err <| "Unrecognized product code " ++ str


toWidgetCode : String -> Result String WidgetCode
toWidgetCode =
    Constrained.stringLike "WidgetCode" WidgetCode "W\\d{4}"


toGizmoCode : String -> Result String GizmoCode
toGizmoCode =
    Constrained.stringLike "GizmoCode" GizmoCode "G\\d{3}"



-- Order Quantity


type OrderQuantity
    = KilogramQuantity Kilogram
    | UnitQuantity Unit


type Kilogram
    = Kilogram Float


type Unit
    = Unit Int


toOrderQuantity : ProductCode -> Float -> Result String OrderQuantity
toOrderQuantity productCode_ quantity =
    case productCode_ of
        Widget _ ->
            toUnit (round quantity) |> Result.map UnitQuantity

        Gizmo _ ->
            toKilogram quantity |> Result.map KilogramQuantity


orderQuantity : OrderQuantity -> Float
orderQuantity q =
    case q of
        KilogramQuantity (Kilogram k) ->
            k

        UnitQuantity (Unit u) ->
            toFloat u


toUnit : Int -> Result String Unit
toUnit =
    Constrained.integer "Unit" Unit 1 1000


toKilogram : Float -> Result String Kilogram
toKilogram =
    Constrained.decimal "Kilogram" Kilogram 0.05 100


unit : Unit -> Int
unit (Unit n) =
    n


kilo : Kilogram -> Float
kilo (Kilogram n) =
    n



-- Zip Code


type ZipCode
    = ZipCode String


toZipCode : String -> Result String ZipCode
toZipCode =
    Constrained.stringLike "ZipCode" ZipCode "\\d{5}"


zipCode : ZipCode -> String
zipCode (ZipCode c) =
    c



-- Email


type EmailAddress
    = EmailAddress String


toEmailAddress : String -> Result String EmailAddress
toEmailAddress =
    Constrained.stringLike "EmailAddress" EmailAddress ".+@.+"


emailAddress : EmailAddress -> String
emailAddress (EmailAddress e) =
    e



-- Order Id


type OrderId
    = OrderId String


toOrderId : String -> Result String OrderId
toOrderId =
    Constrained.string "OrderId" OrderId 50


orderId : OrderId -> String
orderId (OrderId id) =
    id



-- OrderLine Id


type OrderLineId
    = OrderLineId String


toOrderLineId : String -> Result String OrderLineId
toOrderLineId =
    Constrained.string "OrderLineId" OrderLineId 50


orderLineId : OrderLineId -> String
orderLineId (OrderLineId id) =
    id



-- Price


type Price
    = Price Float


toPrice : Float -> Result String Price
toPrice =
    Constrained.decimal "Price" Price 0 1000


price : Price -> Float
price (Price p) =
    p


multiplyPrice : Float -> Price -> Result String Price
multiplyPrice m (Price p) =
    toPrice <| m * p


unsafePrice__ : Float -> Price
unsafePrice__ =
    Price



-- Billing Amount


type BillingAmount
    = BillingAmount Float


toBillingAmount : Float -> Result String BillingAmount
toBillingAmount =
    Constrained.decimal "BillingAmount" BillingAmount 0 10000


billingAmount : BillingAmount -> Float
billingAmount (BillingAmount a) =
    a


billingTotal : List Price -> Result String BillingAmount
billingTotal =
    List.map price >> List.sum >> toBillingAmount
