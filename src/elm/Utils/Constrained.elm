module Utils.Constrained exposing
    ( decimal
    , integer
    , string
    , stringLike
    )

import Regex


string : String -> (String -> a) -> Int -> String -> Result String a
string fieldName constructor maxLen str =
    if String.isEmpty str then
        notEmpty fieldName

    else if String.length str > maxLen then
        aboveMaxLength fieldName <| String.fromInt maxLen

    else
        Ok <| constructor str


integer : String -> (Int -> a) -> Int -> Int -> Int -> Result String a
integer fieldName constructor minVal maxVal i =
    if i < minVal then
        belowMinVal fieldName <| String.fromInt minVal

    else if i > maxVal then
        aboveMaxVal fieldName <| String.fromInt maxVal

    else
        Ok <| constructor i


decimal : String -> (Float -> a) -> Float -> Float -> Float -> Result String a
decimal fieldName constructor minVal maxVal i =
    if i < minVal then
        belowMinVal fieldName <| String.fromFloat minVal

    else if i > maxVal then
        aboveMaxVal fieldName <| String.fromFloat maxVal

    else
        Ok <| constructor i


stringLike : String -> (String -> value) -> String -> String -> Result String value
stringLike fieldName constructor pattern str =
    if String.isEmpty str then
        notEmpty fieldName

    else
        case match pattern str of
            Just True ->
                Ok <| constructor str

            Just False ->
                nonMatchingPattern fieldName pattern

            Nothing ->
                invalidPattern pattern



-- Internal


match : String -> String -> Maybe Bool
match pattern str =
    Regex.fromString pattern |> Maybe.map (\r -> Regex.contains r str)


notEmpty : String -> Result String value
notEmpty fieldName =
    Err <| fieldName ++ " must not be null or empty"


aboveMaxLength : String -> String -> Result String value
aboveMaxLength fieldName maxLen =
    Err <| fieldName ++ " must not be more than " ++ maxLen ++ " chars"


belowMinVal : String -> String -> Result String value
belowMinVal fieldName minVal =
    Err <| fieldName ++ " must not be below " ++ minVal


aboveMaxVal : String -> String -> Result String value
aboveMaxVal fieldName maxVal =
    Err <| fieldName ++ " must not be above " ++ maxVal


nonMatchingPattern : String -> String -> Result String value
nonMatchingPattern fieldName pattern =
    Err <| fieldName ++ " must match the pattern " ++ pattern


invalidPattern : String -> Result String value
invalidPattern pattern =
    Err <| "invalid pattern given " ++ pattern
