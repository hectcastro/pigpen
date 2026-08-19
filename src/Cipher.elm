module Cipher exposing (Dir(..), Glyph(..), Sides, alphabet, glyph)

{- CIPHER DATA -}


type Glyph
    = Grid Sides
    | Cross Dir Bool


type alias Sides =
    { top : Bool, right : Bool, bottom : Bool, left : Bool, dot : Bool }


type Dir
    = Up
    | Right
    | Down
    | Left


alphabet : List Char
alphabet =
    String.toList "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


{-| Look up the glyph for a letter, case-insensitive. `Nothing` for anything
outside A-Z (digits, punctuation, whitespace pass through the UI unchanged).
-}
glyph : Char -> Maybe Glyph
glyph letter =
    case Char.toUpper letter of
        'A' ->
            Just (Grid (Sides False True True False False))

        'B' ->
            Just (Grid (Sides False True True True False))

        'C' ->
            Just (Grid (Sides False False True True False))

        'D' ->
            Just (Grid (Sides True True True False False))

        'E' ->
            Just (Grid (Sides True True True True False))

        'F' ->
            Just (Grid (Sides True False True True False))

        'G' ->
            Just (Grid (Sides True True False False False))

        'H' ->
            Just (Grid (Sides True True False True False))

        'I' ->
            Just (Grid (Sides True False False True False))

        'J' ->
            Just (Grid (Sides False True True False True))

        'K' ->
            Just (Grid (Sides False True True True True))

        'L' ->
            Just (Grid (Sides False False True True True))

        'M' ->
            Just (Grid (Sides True True True False True))

        'N' ->
            Just (Grid (Sides True True True True True))

        'O' ->
            Just (Grid (Sides True False True True True))

        'P' ->
            Just (Grid (Sides True True False False True))

        'Q' ->
            Just (Grid (Sides True True False True True))

        'R' ->
            Just (Grid (Sides True False False True True))

        'S' ->
            Just (Cross Up False)

        'T' ->
            Just (Cross Right False)

        'U' ->
            Just (Cross Down False)

        'V' ->
            Just (Cross Left False)

        'W' ->
            Just (Cross Up True)

        'X' ->
            Just (Cross Right True)

        'Y' ->
            Just (Cross Down True)

        'Z' ->
            Just (Cross Left True)

        _ ->
            Nothing
