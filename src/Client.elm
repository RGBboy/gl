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
    , view = scene >> WebGL.toHtml [ width 480, height 480 ]
    , subscriptions = (\model -> AnimationFrame.diffs Basics.identity)
    , update = (\dt theta -> ( theta + dt / 1000, Cmd.none ))
    }



-- MESHES - create a plane in which each vertex has a position and color


type alias Vertex =
  { position : Vec3
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
    Triangle (face rft lft lbt rbt)

face : Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face a b c d =
  [ ( Vertex a, Vertex b, Vertex c )
  , ( Vertex c, Vertex d, Vertex a )
  ]



-- VIEW


scene : Float -> List Renderable
scene t =
  [ render vertexShader fragmentShader plane (uniforms t) ]

uniforms : Float -> { time: Float, perspective : Mat4, camera : Mat4 }
uniforms t =
  { time = t
  , perspective = makePerspective 45 1 0.01 100
  , camera = makeLookAt (vec3 0 0 1) (vec3 0 0 0) (vec3 0 1 0)
  }



-- SHADERS

vertexShader : Shader { attr | position : Vec3 } { unif | time: Float, perspective : Mat4, camera : Mat4 } { vcolor : Vec3 }
vertexShader =
  [glsl|

attribute vec3 position;
uniform float time;
uniform mat4 perspective;
uniform mat4 camera;
varying vec3 vcolor;
void main () {
  gl_Position = perspective * camera * vec4(position, 1.0);
  vcolor = vec3(1.0, 1.0, 1.0) - (cos(time) * position);
}

|]

fragmentShader : Shader {} { unif | time: Float, perspective : Mat4, camera : Mat4 } { vcolor : Vec3 }
fragmentShader =
  [glsl|

precision mediump float;
varying vec3 vcolor;
void main () {
  gl_FragColor = vec4(vcolor, 1.0);
}

|]
