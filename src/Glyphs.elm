module Glyphs exposing (view)

import Cipher exposing (Dir(..), Glyph(..), Sides)
import Svg exposing (Svg, circle, line, svg)
import Svg.Attributes as A


sk : String
sk =
    "3.5"


pd : Float
pd =
    4


vb : Float
vb =
    40


view : Int -> Glyph -> Svg msg
view size g =
    let
        sizeStr : String
        sizeStr =
            String.fromInt size

        vbStr : String
        vbStr =
            "0 0 " ++ String.fromFloat vb ++ " " ++ String.fromFloat vb
    in
    svg [ A.width sizeStr, A.height sizeStr, A.viewBox vbStr, A.fill "none" ]
        (case g of
            Grid sides ->
                gridStrokes sides

            Cross dir hasDot ->
                crossStrokes dir hasDot
        )


gridStrokes : Sides -> List (Svg msg)
gridStrokes sides =
    List.filterMap identity
        [ ifTrue sides.top (edge pd pd (vb - pd) pd)
        , ifTrue sides.right (edge (vb - pd) pd (vb - pd) (vb - pd))
        , ifTrue sides.bottom (edge pd (vb - pd) (vb - pd) (vb - pd))
        , ifTrue sides.left (edge pd pd pd (vb - pd))
        , ifTrue sides.dot (dot (vb / 2) (vb / 2))
        ]


{-| Two diagonal strokes plus an optional dot, per direction. Mirrors X\_LINES /
X\_DOT from the original cipher.js.
-}
crossStrokes : Dir -> Bool -> List (Svg msg)
crossStrokes dir hasDot =
    let
        ( edge1, edge2 ) =
            case dir of
                Up ->
                    ( edge 4 36 20 4, edge 36 36 20 4 )

                Right ->
                    ( edge 4 4 36 20, edge 4 36 36 20 )

                Down ->
                    ( edge 4 4 20 36, edge 36 4 20 36 )

                Left ->
                    ( edge 36 4 4 20, edge 36 36 4 20 )

        ( cx, cy ) =
            case dir of
                Up ->
                    ( 20, 25 )

                Right ->
                    ( 15, 20 )

                Down ->
                    ( 20, 15 )

                Left ->
                    ( 25, 20 )
    in
    List.filterMap identity
        [ Just edge1
        , Just edge2
        , ifTrue hasDot (dot cx cy)
        ]


ifTrue : Bool -> Svg msg -> Maybe (Svg msg)
ifTrue cond svgEl =
    if cond then
        Just svgEl

    else
        Nothing


edge : Float -> Float -> Float -> Float -> Svg msg
edge x1 y1 x2 y2 =
    line
        [ A.x1 (String.fromFloat x1)
        , A.y1 (String.fromFloat y1)
        , A.x2 (String.fromFloat x2)
        , A.y2 (String.fromFloat y2)
        , A.stroke "currentColor"
        , A.strokeWidth sk
        , A.strokeLinecap "round"
        ]
        []


dot : Float -> Float -> Svg msg
dot cx cy =
    circle
        [ A.cx (String.fromFloat cx)
        , A.cy (String.fromFloat cy)
        , A.r "3"
        , A.fill "currentColor"
        ]
        []
