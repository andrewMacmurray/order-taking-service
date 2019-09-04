module Utils.Task exposing (andThen2)

import Task exposing (Task)


andThen2 : (a -> b -> Task x c) -> Task x a -> Task x b -> Task x c
andThen2 f t1 t2 =
    Task.andThen (\x1 -> Task.andThen (\x2 -> f x1 x2) t2) t1
