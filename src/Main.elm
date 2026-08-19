port module Main exposing (main)

import Browser
import Cipher
import Glyphs
import Html exposing (Html, button, div, h1, h2, main_, nav, p, span, text, textarea)
import Html.Attributes as HA exposing (class, placeholder, title, value)
import Html.Events exposing (onClick, onInput)
import Svg
import Svg.Attributes as SA


port setTheme : String -> Cmd msg



{- ───────────────────── MODEL ───────────────────── -}


type Mode
    = Encode
    | Decode


type Theme
    = Dark
    | Light


type alias Model =
    { mode : Mode
    , text : String
    , decoded : String
    , showRef : Bool
    , theme : Theme
    }


init : String -> ( Model, Cmd Msg )
init themeFlag =
    ( { mode = Encode
      , text = ""
      , decoded = ""
      , showRef = False
      , theme = themeFromString themeFlag
      }
    , Cmd.none
    )


themeFromString : String -> Theme
themeFromString s =
    if s == "dark" then
        Dark

    else
        Light


themeToString : Theme -> String
themeToString t =
    case t of
        Dark ->
            "dark"

        Light ->
            "light"



{- ───────────────────── UPDATE ───────────────────── -}


type Msg
    = SetMode Mode
    | SetText String
    | Append String
    | Backspace
    | Clear
    | ToggleRef
    | ToggleTheme


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetMode mode ->
            ( { model | mode = mode }, Cmd.none )

        SetText t ->
            ( { model | text = t }, Cmd.none )

        Append s ->
            ( { model | decoded = model.decoded ++ s }, Cmd.none )

        Backspace ->
            ( { model | decoded = String.dropRight 1 model.decoded }, Cmd.none )

        Clear ->
            ( { model | decoded = "" }, Cmd.none )

        ToggleRef ->
            ( { model | showRef = not model.showRef }, Cmd.none )

        ToggleTheme ->
            let
                next =
                    case model.theme of
                        Dark ->
                            Light

                        Light ->
                            Dark
            in
            ( { model | theme = next }, setTheme (themeToString next) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



{- ───────────────────── VIEW ───────────────────── -}


view : Model -> Html Msg
view model =
    div [ class "root" ]
        [ viewNav model
        , viewHero model.mode
        , main_ [ class "main" ]
            (List.concat
                [ if model.mode == Encode then
                    viewEncode model.text

                  else
                    viewDecode model.decoded
                , if model.showRef then
                    [ viewReference ]

                  else
                    []
                ]
            )
        , Html.footer [ class "footer" ] [ span [] [ text "PIGPEN!!! By Elle Castro" ] ]
        ]


viewNav : Model -> Html Msg
viewNav model =
    nav [ class "nav" ]
        [ div [ class "navBrand" ]
            [ brandIcon
            , span [ class "navTitle" ] [ text "PIGPEN!!!" ]
            ]
        , div [ class "navPills" ]
            [ pill (model.mode == Encode) (SetMode Encode) "Encode"
            , pill (model.mode == Decode) (SetMode Decode) "Decode"
            , pill model.showRef ToggleRef "Reference"
            , button
                [ onClick ToggleTheme
                , class "themeToggle"
                , HA.attribute "aria-label" "Toggle theme"
                ]
                [ if model.theme == Dark then
                    sunIcon

                  else
                    moonIcon
                ]
            ]
        ]


pill : Bool -> Msg -> String -> Html Msg
pill active msg label =
    button
        [ onClick msg
        , class
            (if active then
                "pill pill--active"

             else
                "pill"
            )
        ]
        [ text label ]


viewHero : Mode -> Html Msg
viewHero mode =
    Html.section [ class "hero" ]
        [ h1 [ class "heroHeading" ]
            [ text
                (if mode == Encode then
                    "Encode your message"

                 else
                    "Decode cipher symbols"
                )
            ]
        , p [ class "heroSub" ]
            [ text
                (if mode == Encode then
                    "Type plaintext below to translate it into pigpen cipher symbols."

                 else
                    "Tap pigpen glyphs to reconstruct the original message."
                )
            ]
        ]


outputCard : String -> List (Html msg) -> Html msg
outputCard label children =
    div [ class "outputCard" ]
        (div [ class "outputCardHeader" ] [ span [ class "outputCardLabel" ] [ text label ] ]
            :: children
        )



{- ════ ENCODE ════ -}


viewEncode : String -> List (Html Msg)
viewEncode inputText =
    textarea
        [ value inputText
        , onInput SetText
        , placeholder "Type your secret message…"
        , HA.rows 4
        , class "textarea"
        ]
        []
        :: (if String.isEmpty inputText then
                []

            else
                [ div [ class "encodeOutput" ]
                    [ outputCard "encoded symbols"
                        [ div [ class "glyphRow" ] (List.map viewSegment (segments inputText)) ]
                    , div [ class "plaintextHint" ]
                        [ span [ class "plaintextHintLabel" ] [ text "plaintext:" ]
                        , text inputText
                        ]
                    ]
                ]
           )


{-| A run of the input text: either a whitespace run (rendered as a fixed-width
spacer between words) or a run of non-whitespace characters (rendered as
glyphs, one per character). Mirrors `text.split(/(\\s+)/)` from App.jsx.
-}
type Segment
    = Spacer
    | Word String


segments : String -> List Segment
segments str =
    String.toList str
        |> groupRuns
        |> List.map
            (\( runIsSpace, chars ) ->
                if runIsSpace then
                    Spacer

                else
                    Word (String.fromList chars)
            )


groupRuns : List Char -> List ( Bool, List Char )
groupRuns chars =
    List.foldl
        (\c acc ->
            case acc of
                ( curIsSpace, curChars ) :: rest ->
                    if isSpace c == curIsSpace then
                        ( curIsSpace, c :: curChars ) :: rest

                    else
                        ( isSpace c, [ c ] ) :: ( curIsSpace, curChars ) :: rest

                [] ->
                    [ ( isSpace c, [ c ] ) ]
        )
        []
        chars
        |> List.reverse
        |> List.map (\( b, cs ) -> ( b, List.reverse cs ))


isSpace : Char -> Bool
isSpace c =
    c == ' ' || c == '\t' || c == '\n' || c == '\u{000D}'


viewSegment : Segment -> Html msg
viewSegment seg =
    case seg of
        Spacer ->
            div [ class "glyphWordSpacer" ] []

        Word s ->
            span [ class "glyphWord" ] (List.map viewChar (String.toList s))


viewChar : Char -> Html msg
viewChar c =
    case Cipher.glyph c of
        Just g ->
            Glyphs.view 44 g

        Nothing ->
            span [ class "glyphPassthrough" ] [ text (String.fromChar c) ]



{- ════ DECODE ════ -}


viewDecode : String -> List (Html Msg)
viewDecode decoded =
    [ div [ class "decodeGrid" ] (List.map viewDecodeBtn Cipher.alphabet)
    , div [ class "controlBtns" ]
        [ button [ onClick (Append " "), class "controlBtn controlBtn--space" ] [ text "Space" ]
        , button [ onClick Backspace, class "controlBtn" ] [ text "⌫" ]
        , button [ onClick Clear, class "controlBtn" ] [ text "Clear" ]
        ]
    , outputCard "decoded message"
        [ div [ class "decodedOutput" ]
            (if String.isEmpty decoded then
                [ span [ class "decodedPlaceholder" ] [ text "Tap symbols above to see your message…" ] ]

             else
                [ text decoded, span [ class "cursor" ] [] ]
            )
        ]
    ]


viewDecodeBtn : Char -> Html Msg
viewDecodeBtn letter =
    let
        label =
            String.fromChar letter
    in
    button
        [ onClick (Append label)
        , title ("Decodes to: " ++ label)
        , class "decodeBtn"
        ]
        [ case Cipher.glyph letter of
            Just g ->
                Glyphs.view 52 g

            Nothing ->
                text ""
        , span [ class "decodeBtnLabel" ] [ text label ]
        ]



{- ════ REFERENCE ════ -}


type alias RefSection =
    { label : String, letters : String, tag : String }


refSections : List RefSection
refSections =
    [ { label = "Grid", letters = "ABCDEFGHI", tag = "no dot" }
    , { label = "Grid + Dot", letters = "JKLMNOPQR", tag = "dot" }
    , { label = "X", letters = "STUV", tag = "no dot" }
    , { label = "X + Dot", letters = "WXYZ", tag = "dot" }
    ]


viewReference : Html Msg
viewReference =
    div [ class "refSection" ]
        (div [ class "refHeader" ] [ h2 [ class "refHeading" ] [ text "Symbol Reference" ] ]
            :: List.map viewRefGroup refSections
        )


viewRefGroup : RefSection -> Html Msg
viewRefGroup sec =
    div [ class "refGroup" ]
        [ div [ class "refGroupHeader" ]
            [ span [ class "refGroupLabel" ] [ text sec.label ]
            , span
                [ class
                    (if sec.tag == "dot" then
                        "refTagBadge refTagBadge--dot"

                     else
                        "refTagBadge refTagBadge--nodot"
                    )
                ]
                [ text sec.tag ]
            ]
        , div [ class "refGrid" ] (List.map viewRefCell (String.toList sec.letters))
        ]


viewRefCell : Char -> Html Msg
viewRefCell letter =
    div [ class "refCell" ]
        [ viewChar letter
        , span [ class "refCellLabel" ] [ text (String.fromChar letter) ]
        ]



{- ───────────────────── ICONS ───────────────────── -}


brandIcon : Html msg
brandIcon =
    Svg.svg [ SA.width "36", SA.height "36", SA.viewBox "0 0 40 40", SA.fill "none" ]
        [ Svg.line [ SA.x1 "4", SA.y1 "4", SA.x2 "36", SA.y2 "4", SA.stroke "currentColor", SA.strokeWidth "3", SA.strokeLinecap "round" ] []
        , Svg.line [ SA.x1 "36", SA.y1 "4", SA.x2 "36", SA.y2 "36", SA.stroke "currentColor", SA.strokeWidth "3", SA.strokeLinecap "round" ] []
        , Svg.line [ SA.x1 "4", SA.y1 "36", SA.x2 "36", SA.y2 "36", SA.stroke "currentColor", SA.strokeWidth "3", SA.strokeLinecap "round" ] []
        , Svg.line [ SA.x1 "4", SA.y1 "4", SA.x2 "4", SA.y2 "36", SA.stroke "currentColor", SA.strokeWidth "3", SA.strokeLinecap "round" ] []
        , Svg.circle [ SA.cx "20", SA.cy "20", SA.r "3", SA.fill "currentColor" ] []
        ]


iconAttrs : List (Svg.Attribute msg)
iconAttrs =
    [ SA.width "18", SA.height "18", SA.viewBox "0 0 24 24", SA.fill "none", SA.stroke "currentColor", SA.strokeWidth "2", SA.strokeLinecap "round", SA.strokeLinejoin "round" ]


sunIcon : Html msg
sunIcon =
    Svg.svg iconAttrs
        [ Svg.circle [ SA.cx "12", SA.cy "12", SA.r "5" ] []
        , Svg.line [ SA.x1 "12", SA.y1 "1", SA.x2 "12", SA.y2 "3" ] []
        , Svg.line [ SA.x1 "12", SA.y1 "21", SA.x2 "12", SA.y2 "23" ] []
        , Svg.line [ SA.x1 "4.22", SA.y1 "4.22", SA.x2 "5.64", SA.y2 "5.64" ] []
        , Svg.line [ SA.x1 "18.36", SA.y1 "18.36", SA.x2 "19.78", SA.y2 "19.78" ] []
        , Svg.line [ SA.x1 "1", SA.y1 "12", SA.x2 "3", SA.y2 "12" ] []
        , Svg.line [ SA.x1 "21", SA.y1 "12", SA.x2 "23", SA.y2 "12" ] []
        , Svg.line [ SA.x1 "4.22", SA.y1 "19.78", SA.x2 "5.64", SA.y2 "18.36" ] []
        , Svg.line [ SA.x1 "18.36", SA.y1 "5.64", SA.x2 "19.78", SA.y2 "4.22" ] []
        ]


moonIcon : Html msg
moonIcon =
    Svg.svg iconAttrs
        [ Svg.path [ SA.d "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" ] [] ]



{- ───────────────────── MAIN ───────────────────── -}


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
