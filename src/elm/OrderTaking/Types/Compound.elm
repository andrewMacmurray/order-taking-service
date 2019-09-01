module OrderTaking.Types.Compound exposing
    ( Address
    , CustomerInfo
    , PersonalName
    )

import OrderTaking.Types.Simple
    exposing
        ( EmailAddress
        , String50
        , ZipCode
        )


type alias PersonalName =
    { firstName : String50
    , lastName : String50
    }


type alias CustomerInfo =
    { name : PersonalName
    , emailAddress : EmailAddress
    }


type alias Address =
    { line1 : String50
    , line2 : String50
    , line3 : String50
    , line4 : String50
    , city : String50
    , zipCode : ZipCode
    }
