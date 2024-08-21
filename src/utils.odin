package main

import "core:math"
import "core:math/rand"

Vec3 :: [3]f64

Pi :: f64(math.PI)

Infinity         :: f64(0h7ff0_0000_0000_0000);
NegativeInfinity :: f64(0hfff0_0000_0000_0000);

deg_to_radians :: #force_inline proc(deg: f64) -> f64 { return deg * (Pi / 180.0) }

vec_len2 :: proc(v: Vec3) -> f64 {
    return v.x*v.x + v.y*v.y + v.z*v.z
}

vec_len :: proc(v: Vec3) -> f64 {
    return math.sqrt(vec_len2(v))
}

vec_dot :: proc(a: Vec3, b: Vec3) -> f64 {
    return a.x * b.x + a.y * b.y + a.z * b.z
}

vec_unit :: proc(v: Vec3) -> Vec3 {
   return v / vec_len(v) 
}

random_vec3 :: proc(min : f64 = 0.0, max : f64 = 1.0) -> Vec3 {
    return Vec3{ rand.float64_range(min, max), rand.float64_range(min, max), rand.float64_range(min, max) };
}
