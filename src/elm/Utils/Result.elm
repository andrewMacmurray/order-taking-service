module Utils.Result exposing (andMap, combine, toTask)

import Task exposing (Task)


andMap : Result e a -> Result e (a -> b) -> Result e b
andMap ra rb =
    case ( ra, rb ) of
        ( _, Err x ) ->
            Err x

        ( o, Ok fn ) ->
            Result.map fn o


combine : List (Result x a) -> Result x (List a)
combine =
    List.foldr (Result.map2 (::)) (Ok [])


toTask : Result x a -> Task x a
toTask result =
    case result of
        Err x ->
            Task.fail x

        Ok a ->
            Task.succeed a
