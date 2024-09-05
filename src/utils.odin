package main

import "core:math"
import "core:math/rand"

Vec3 :: [3]f64

Pi :: f64(math.PI)

Infinity         :: f64(0h7ff0_0000_0000_0000)
NegativeInfinity :: f64(0hfff0_0000_0000_0000)

deg_to_radians :: #force_inline proc(deg: f64) -> f64 { return deg * (Pi / 180.0) }
vec_is_near_zero :: proc(v : Vec3) -> bool { return v.x < 1e-8 && v.y < 1e-8 && v.z < 1e-8 }
vec_reflect :: proc(v, n : Vec3) -> Vec3 { return v - 2 * vec_dot(v, n) * n }

vec_refract :: proc { vec_refract_indices, vec_refract_ratio }
vec_refract_indices :: proc(v, n: Vec3, refractive_index_1, refractive_index_2: f64) -> Vec3 {
    return vec_refract_ratio(v, n, refractive_index_1 / refractive_index_2) 
} 
vec_refract_ratio :: proc(v, n: Vec3, refractive_ratio: f64) -> Vec3 {
    cos_theta := min(vec_dot(-v, n), 1.0)
    r_out_perpendicular := refractive_ratio * (v + cos_theta * n)
    r_out_parallel := -math.sqrt(abs(1.0 - vec_len2(r_out_perpendicular))) * n
    return r_out_perpendicular + r_out_parallel
}

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
    return Vec3{ rand.float64_range(min, max), rand.float64_range(min, max), rand.float64_range(min, max) }
}

random_vec_in_unit_sphere :: proc() -> Vec3 {
    for {
        v := random_vec3(-1.0, 1.0)
        if vec_len2(v) >= 1 { continue }
        return v
    }
}

random_unit_vec :: proc() -> Vec3 {
    return vec_unit(random_vec_in_unit_sphere())
}

random_vec_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
    u := random_vec_in_unit_sphere()
    return u if vec_dot(u, normal) > 0.0 else -u
}
