module A exposing
  ( vertexShader
  , fragmentShader
  )

import Math.Vector2 exposing (..)
import Math.Vector3 exposing (..)
import Math.Matrix4 exposing (..)
import WebGL exposing (..)



vertexShader : Shader { attr | position : Vec3 } { unif | camera : Mat4 } { vposition : Vec2 }
vertexShader =
  [glsl|

attribute vec3 position;
uniform mat4 camera;
varying vec2 vposition;

void main () {
  gl_Position = camera * vec4(position, 1.0);
  vposition = gl_Position.xy;
}

|]



fragmentShader : Shader {} { unif | time: Float, resolution: Vec2 } { vposition : Vec2 }
fragmentShader =
  [glsl|

precision highp float;
varying vec2 vposition;
uniform float time;
uniform vec2 resolution;

void main () {

  vec3 c;
  vec2 uv;
  vec2 p = vposition.xy;
  float l;
  float z = time;
  p.x *= resolution.x / resolution.y;

  for (int i = 0; i < 3; i++) {
    uv = p;
    z += 0.07;
    l = length(p);
    uv += p / l * (cos(z) + 1.0) * abs(cos(l * 9.0 - z * 2.0));
    c[i] = 0.02 / length(abs(mod(uv, 1.0) - 0.5));
  }

  gl_FragColor = vec4(c / l, 1.0);
}

|]
