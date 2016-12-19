module Main exposing (..)

import Color exposing (..)
import Math.Vector2 exposing (..)
import Math.Vector3 exposing (..)
import Math.Matrix4 exposing (..)
import WebGL exposing (..)
import Html
import AnimationFrame
import Html.Attributes as A
import Time exposing (Time)

import A

width : Float
width = 480

height : Float
height = 480


main : Program Never Time Time
main =
  Html.program
    { init = ( 0, Cmd.none )
    , view = scene >> WebGL.toHtml [ A.width (round width), A.height (round height) ]
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
  [ render A.vertexShader A.fragmentShader plane (uniforms t) ]

uniforms : Float -> { time: Float, resolution: Vec2, camera : Mat4 }
uniforms t =
  { resolution = vec2 width height
  , time = t
  , camera = makeLookAt (vec3 0 0 1) (vec3 0 0 0) (vec3 0 1 0)
  }
