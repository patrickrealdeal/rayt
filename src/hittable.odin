package main

import "core:math"

Hit_Record :: struct {
    p: Vec3,
    normal: Vec3,
    t: f64,
    material: ^Material,
    front_face: bool,
}

Hittable :: struct {
    type: union { ^Sphere },
    material: ^Material,
}

Sphere :: struct {
    using _base: Hittable,
    center: Vec3,
    radius: f64,
}

sphere_init :: proc(center: Vec3, radius: f64, mat: ^Material) -> ^Sphere {
    sphere := new(Sphere)
    sphere.type = sphere
    sphere.center = center
    sphere.radius = radius
    sphere.material = mat
    return sphere
}

@(private)
sphere_collision :: proc(sphere: ^Sphere, r: ^Ray, t_min, t_max: f64) -> (bool, Hit_Record) {
    hit, rec := false, Hit_Record{}

    oc := sphere.center - r.origin
    a := vec_len2(r.direction)
    h := vec_dot(r.direction, oc)
    c := vec_len2(oc) - sphere.radius*sphere.radius
    discriminant := h*h - a*c 
    
    if discriminant < 0 {
        return hit, rec 
    }

    sqrtd := math.sqrt(discriminant)

    // Find the nearest root that lies in the acceptable range.
    root := (h - sqrtd) / a
    if (root <= t_min || t_max <= root) {
        root = (h + sqrtd) / a
        if (root <= t_min || t_max <= root) {
            return hit, rec
        }
    }

    rec.t = root
    rec.p = ray_at(r, rec.t)
    outward_normal := vec_unit((rec.p - sphere.center) / sphere.radius)
    record_set_front_face_normal(&rec, r, outward_normal)
    rec.material = sphere.material
    hit = true

    return hit, rec
} 

collision :: proc { collision_single, collision_multi }
collision_single :: proc(hittable: ^Hittable, r: ^Ray, t_min, t_max: f64) -> (bool, Hit_Record) {
    hit, rec := false, Hit_Record{}
    switch h in hittable.type {
        case ^Sphere: {
            hit, rec = sphere_collision(h, r, t_min, t_max)
            return hit, rec
        }
        case: {
            return hit, rec
        }
    }
}

collision_multi :: proc(hittable_list: []^Hittable, r: ^Ray, t_min, t_max: f64) -> (bool, Hit_Record) {
    hit_any, rec := false, Hit_Record{}
    closest_t := t_max

    for hittable in hittable_list {
        if hit, temp_rec := collision_single(hittable, r, t_min, closest_t); hit {
            hit_any = true
            closest_t = temp_rec.t 
            rec = temp_rec
        }
    }

    return hit_any, rec
}

record_set_front_face_normal :: #force_inline proc(record : ^Hit_Record, ray : ^Ray, outward_normal : Vec3) {
    record.front_face = vec_dot(ray.direction, outward_normal) < 0;
    record.normal = outward_normal if record.front_face else -outward_normal;
}

