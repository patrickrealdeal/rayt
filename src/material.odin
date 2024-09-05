package main

import "core:math"
import "core:math/rand"

Material :: struct {
    type: union {
        ^Lambertian,
        ^Metal,
        ^Dielectric,
    }
}

Lambertian :: struct {
    using _base: Material,
    albedo: Vec3,
}

Metal :: struct {
    using _base: Material,
    albedo: Vec3,
    roughness: f64,
}

Dielectric :: struct {
    using _base: Material,
    refractive_index: f64,
}

material_scatter :: proc(mat: ^Material, r_in: ^Ray, rec: ^Hit_Record) -> (bool, Vec3, Ray) {
    ok, attenuation, scattered := false, Vec3{}, Ray{}
    switch m in mat.type {
        case ^Lambertian:
            ok, attenuation, scattered = lambertian_scatter(m, r_in, rec)
            return ok, attenuation, scattered
        case ^Metal: {
            ok, attenuation, scattered := metal_scatter(m, r_in, rec)
            return ok, attenuation, scattered
        }
        case ^Dielectric: {
            ok, attenuation, scattered := dielectric_scatter(m, r_in, rec)
            return ok, attenuation, scattered
        }
    }

    return ok, attenuation, scattered
}

material_new_lambertian :: proc(albedo: Vec3) -> ^Lambertian {
    mat := new(Lambertian)
    mat.type = mat
    mat.albedo = albedo
    return mat
}

material_new_metal :: proc(albedo : Vec3, roughness : f64 = 0.0) -> ^Metal {
    mat := new(Metal);
    mat.type = mat;
    mat.albedo = albedo;
    mat.roughness = clamp(roughness, 0.0, 1.0);
    return mat
}

material_new_dielectric :: proc(refractive_index: f64) -> ^Material {
    mat := new(Dielectric)
    mat.type = mat
    mat.refractive_index = refractive_index
    return mat
}


@(private)
lambertian_scatter :: proc(mat: ^Lambertian, r_in: ^Ray, rec: ^Hit_Record) -> (bool, Vec3, Ray) {
    scatter_direction := rec.normal + random_unit_vec()
    if vec_is_near_zero(scatter_direction) {
        scatter_direction = rec.normal
    }

    scattered := Ray{ origin = rec.p, direction = scatter_direction }
    attenuation := mat.albedo
    ok := true
    return ok, attenuation, scattered
}

@(private)
metal_scatter :: proc(mat : ^Metal, ray_in : ^Ray, record : ^Hit_Record) -> (bool, Vec3, Ray) {
    reflected_direction := vec_reflect(vec_unit(ray_in.direction), record.normal);
    scattered := Ray{ origin = record.p, direction = reflected_direction + mat.roughness * random_vec_in_unit_sphere() };
    attenuation := mat.albedo;
    ok := vec_dot(scattered.direction, record.normal) > 0;
    return ok, attenuation, scattered
}

@(private)
dielectric_scatter :: proc(mat: ^Dielectric, ray_in: ^Ray, record: ^Hit_Record) -> (bool, Vec3, Ray) {
    attenuation := Vec3{1, 1, 1}
    refraction_ratio := 1.0 / mat.refractive_index if record.front_face else mat.refractive_index

    unit_dir := vec_unit(ray_in.direction)
    cos_theta := min(vec_dot(-unit_dir, record.normal), 1.0)
    sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)

    direction: Vec3
    reflectance :: proc(cos_theta, ratio: f64) -> f64 {
        denom := 1e-8 if (1.0 + ratio) < 1e-8 else (1.0 + ratio)
        r0 := (1.0 - ratio) / denom
        return (r0 * r0) + (1.0 - r0 * r0) * math.pow((1 - cos_theta), 5)
    }

    if refraction_ratio * sin_theta < 1.0 && reflectance(cos_theta, refraction_ratio) < rand.float64() {
        direction = vec_refract(unit_dir, record.normal, refraction_ratio)
    } else {
        direction = vec_reflect(unit_dir, record.normal)
    }

    scattered := Ray{ origin = record.p, direction = direction }
    ok := true
    return ok, attenuation, scattered
}

