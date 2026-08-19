module CipherTest exposing (suite)

import Cipher exposing (Glyph(..))
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Cipher"
        [ test "alphabet is the 26 letters A-Z" <|
            \_ ->
                Cipher.alphabet
                    |> String.fromList
                    |> Expect.equal "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        , test "every letter in the alphabet has a glyph" <|
            \_ ->
                Cipher.alphabet
                    |> List.filterMap Cipher.glyph
                    |> List.length
                    |> Expect.equal (List.length Cipher.alphabet)
        , test "A-I and S-V have no dot" <|
            \_ ->
                String.toList "ABCDEFGHISTUV"
                    |> List.map hasDot
                    |> Expect.equal (List.repeat 13 (Just False))
        , test "J-R and W-Z have a dot" <|
            \_ ->
                String.toList "JKLMNOPQRWXYZ"
                    |> List.map hasDot
                    |> Expect.equal (List.repeat 13 (Just True))
        , test "lowercase input maps to the same glyph as uppercase" <|
            \_ ->
                Cipher.alphabet
                    |> List.map (\c -> ( Cipher.glyph c, Cipher.glyph (Char.toLower c) ))
                    |> List.all (\( upper, lower ) -> upper == lower)
                    |> Expect.equal True
        ]


hasDot : Char -> Maybe Bool
hasDot c =
    Cipher.glyph c
        |> Maybe.map
            (\g ->
                case g of
                    Grid sides ->
                        sides.dot

                    Cross _ dot ->
                        dot
            )
