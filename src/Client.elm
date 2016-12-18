module Main exposing (..)

import Color exposing (..)
import Math.Vector2 exposing (..)
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

vertexShader : Shader { attr | position : Vec3 } { unif | perspective : Mat4, camera : Mat4 } { vposition : Vec3 }
vertexShader =
  [glsl|

attribute vec3 position;
uniform mat4 perspective;
uniform mat4 camera;
varying vec3 vposition;
void main () {
  gl_Position = perspective * camera * vec4(position, 1.0);
  vposition = position + vec3(0.5, 0.5, 0.0);
}

|]

fragmentShader : Shader {} { unif | time: Float } { vposition : Vec3 }
fragmentShader =
  [glsl|

precision mediump float;
varying vec3 vposition;
uniform float time;

vec3 c;
vec2 r = vec2(-480.0, 480.0);
vec2 uv,p;
float l,z;

void main () {

  z = time;
  p = vposition.xy;

  for (int i = 0; i < 3; i++) {
    uv = p;
    p -= 0.5;
    p.x *= r.x / r.y;
    z += 0.07;
    l = length(p);
    uv += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z * 2.0));
    c[i] = 0.01 / length(abs(mod(uv,1.) - 0.5));
  }

  gl_FragColor = vec4(c/l, time);
}

|]
