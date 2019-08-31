module Utils.NonEmptyList exposing
    ( NonEmptyList
    , fromElement
    , fromElements
    , toList
    )

-- Non empty list


type NonEmptyList a
    = NonEmptyList
        { first : a
        , rest : List a
        }



-- Create


fromElement : a -> NonEmptyList a
fromElement a =
    fromElements a []


fromElements : a -> List a -> NonEmptyList a
fromElements first rest =
    NonEmptyList
        { first = first
        , rest = rest
        }



-- Get


toList : NonEmptyList a -> List a
toList (NonEmptyList { first, rest }) =
    first :: rest
