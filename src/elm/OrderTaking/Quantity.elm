module OrderTaking.Quantity exposing
    ( Kilogram
    , Order(..)
    , Unit
    , kilogram
    , unit
    , unitVal
    )


type Order
    = KilogramQuantity Kilogram
    | UnitQuantity Unit


type Kilogram
    = Kilogram Int


type Unit
    = Unit Int



-- Create


unit : Int -> Result String Unit
unit n =
    if n < 1 then
        Err "quantity cannot be negative"

    else if n > 1000 then
        Err "quantity cannot be more than 1000"

    else
        Ok <| Unit n


kilogram : Float -> Result String Kilogram
kilogram n =
    if n < 0 then
        Err "kilograms cannot be negative"

    else
        Ok <| Kilogram <| toGrams n



-- Get


unitVal : Unit -> Int
unitVal (Unit n) =
    n


kiloVal : Kilogram -> Float
kiloVal (Kilogram n) =
    fromGrams n



-- Internal


fromGrams : Int -> Float
fromGrams n =
    toFloat <| n // 1000


toGrams : Float -> Int
toGrams n =
    round <| n * 1000
