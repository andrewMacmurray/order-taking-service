module OrderTaking.ShippingAddress exposing
    ( ShippingAddress
    , Validated
    , shippingAddress
    , unvalidated
    , validate
    )

-- Shipping Address


type Unvalidated
    = Unvalidated ShippingAddress


type Validated
    = Validated ShippingAddress


type alias ShippingAddress =
    {}



-- Create


unvalidated : ShippingAddress -> Unvalidated
unvalidated =
    Unvalidated



-- Update


validate : (Unvalidated -> Maybe Validated) -> ShippingAddress -> Maybe Validated
validate validator address =
    validator <| unvalidated address



-- Get


shippingAddress : Validated -> ShippingAddress
shippingAddress (Validated a) =
    a
