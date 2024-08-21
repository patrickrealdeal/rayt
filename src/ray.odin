package main

import "core:math"

Ray :: struct {
    origin: Vec3,
    direction: Vec3,
}

ray_init :: proc(origin: Vec3, direction: Vec3) -> Ray {
    return Ray {
        origin,
        direction,
    }
}

ray_at :: proc(ray: ^Ray, t: f64) -> Vec3 {
    return ray.origin + t*ray.direction
}

