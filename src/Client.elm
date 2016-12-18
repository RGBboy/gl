module Main exposing (..)

import Color exposing (..)
import Math.Vector3 exposing (..)
import Math.Matrix4 exposing (..)
import WebGL exposing (..)
import Html
import AnimationFrame
import Html.Attributes exposing (width, height)
import Time exposing (Time)


main : Program Never Time Time
main =
  Html.program
    { init = ( 0, Cmd.none )
    , view = scene >> WebGL.toHtml [ width 400, height 400 ]
    , subscriptions = (\model -> AnimationFrame.diffs Basics.identity)
    , update = (\dt theta -> ( theta + dt / 5000, Cmd.none ))
    }



-- MESHES - create a plane in which each vertex has a position and color


type alias Vertex =
  { color : Vec3
  , position : Vec3
  }


plane : Drawable Vertex
plane =
  let
    rft =
      vec3 1 1 0

    lft =
      vec3 -1 1 0

    lbt =
      vec3 -1 -1 0

    rbt =
      vec3 1 -1 0
  in
    Triangle (face yellow rft lft lbt rbt)


face : Color -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face rawColor a b c d =
  let
    color =
      let
        c = toRgb rawColor
      in
        vec3
          (toFloat c.red / 255)
          (toFloat c.green / 255)
          (toFloat c.blue / 255)

    vertex position =
        Vertex color position
  in
    [ ( vertex a, vertex b, vertex c )
    , ( vertex c, vertex d, vertex a )
    ]



-- VIEW


scene : Float -> List Renderable
scene angle =
  [ render vertexShader fragmentShader plane (uniforms angle) ]


uniforms : Float -> { perspective : Mat4, camera : Mat4, shade : Float }
uniforms t =
  { perspective = makePerspective 45 1 0.01 100
  , camera = makeLookAt (vec3 0 0 1) (vec3 0 0 0) (vec3 0 1 0)
  , shade = 0.8
  }



-- SHADERS


vertexShader : Shader { attr | position : Vec3, color : Vec3 } { unif | perspective : Mat4, camera : Mat4 } { vcolor : Vec3 }
vertexShader =
  [glsl|

attribute vec3 position;
attribute vec3 color;
uniform mat4 perspective;
uniform mat4 camera;
varying vec3 vcolor;
void main () {
    gl_Position = perspective * camera * vec4(position, 1.0);
    vcolor = color;
}

|]


fragmentShader : Shader {} { u | shade : Float } { vcolor : Vec3 }
fragmentShader =
  [glsl|

precision mediump float;
uniform float shade;
varying vec3 vcolor;
void main () {
    gl_FragColor = shade * vec4(vcolor, 1.0);
}

|]
