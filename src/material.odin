package main

Material :: struct {
    type: union {
        ^Lambertian,
        ^Metal,
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
