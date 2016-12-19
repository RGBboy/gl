module B exposing
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
vec4 base = vec4(0.4, 0.5, 1.0, 1.0);

void main () {

  vec3 c;
  vec2 uv;
  vec2 p = vposition.xy;
  float l;
  float z = time;
  p.x *= resolution.x / resolution.y;

  for (int i = 0; i < 3; i++) {
    uv = p;
    z += 0.05;
    l = length(p - 0.01);
    uv += p / l * (sin(z) + 0.01) * sin(l * 12.0 - z * 1.2);
    c[i] = 0.05 / length(uv + 0.1);
  }

  gl_FragColor = base * vec4(c / l, 1.0);
}

|]
