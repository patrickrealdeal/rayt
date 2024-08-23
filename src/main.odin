package main

import "core:fmt"
import "core:os"
import "core:mem"
import "core:math"
import "core:math/rand"
import "core:strings"

ray_color :: proc(r: ^Ray, world: []^Hittable, depth: int) -> Vec3 {
    if depth <= 0 {
        return Vec3{0,0,0}
    }

    if hit_any, rec := collision(world, r, 0.001, Infinity); hit_any {
        if ok, attenuation, scattered := material_scatter(rec.material, r, &rec); ok {
            return attenuation * ray_color(&scattered, world, depth-1)
        }
        return Vec3{0,0,0}
    }

    unit_direction := vec_unit(r.direction)
    a := 0.5 * (unit_direction.y + 1.0)
    return (1.0-a)*Vec3{1.0, 1.0, 1.0} + a*Vec3{0.5, 0.7, 1.0}
}

render :: proc(output: ^[]Vec3, world: []^Hittable, cam: ^Camera, image_width, image_height: int) {  
    for y in 0..< image_height {
        for x in 0..< image_width {
            color := Vec3{0,0,0}
            fmt.fprintf(os.stderr, "\rDrawing ... ")
            current_line := image_height -y - 1;
            percentage := 100.0 * (f64(image_height - current_line) / f64(image_height))
            fmt.fprintf(os.stderr, "\rTracing rays:   {: 4d} / {: 4d} ({:.2f}%% done)...", current_line, image_height, percentage );
            for _ in 0..< cam.samples {
                r := camera_get_ray(cam, f64(x), f64(y))
                color += ray_color(&r, world, cam.depth)
            } 
            scale := 1.0 / f64(cam.samples);
            output[y * image_width + x] = color * scale 
        }
    }
    fmt.fprintf(os.stderr, "Done.\n")
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    defer track_allocs(&track)

    // IMAGE
    image_width := 640
    aspect_ratio: f64 = 16.0 / 9.0

    // Calculate the image height and ensure is at least 1
    image_height := int(f64(image_width) / aspect_ratio)
    
    // WORLD
    world := make([dynamic]^Hittable, 0, 10)
    defer {
        for h in world {
            free(h.material)
            free(h)
        }
        delete(world)
    }

    material_ground := material_new_lambertian(Vec3{0.8, 0.8, 0.0})
    material_center := material_new_lambertian(Vec3{0.1, 0.2, 0.5})
    material_left := material_new_metal(Vec3{0.8, 0.8, 0.8}, 0.3)
    material_right := material_new_metal(Vec3{0.8, 0.6, 0.2}, 1.0)

    append(&world, sphere_init(Vec3{ 0.0 , -100.5, -1.0 }, 100, material_ground))
    append(&world, sphere_init(Vec3{ 0.0 , 0.0   , -1.2 }, 0.5, material_center))
    append(&world, sphere_init(Vec3{ -1.0, 0.0   , -1.0 }, 0.5, material_left))
    append(&world, sphere_init(Vec3{ 1.0 , 0.0   , -1.0 }, 0.5, material_right))

    // CAMERA
    cam := camera_init(aspect_ratio, image_width, image_height)
    cam.samples = 100
    cam.depth = 50
    
    // RENDER
    output := make([]Vec3, image_width * image_height)
    defer delete(output)
    
    render(&output, world[:], &cam, image_width, image_height)
    output_to_ppm(output, image_width, image_height)
}

linear_to_gamma :: proc(linear_component: f64) -> f64 {
    if linear_component > 0 { 
        return math.sqrt(linear_component)
    }

    return 0
}

output_to_ppm :: proc(output: []Vec3, image_width, image_height: int) {
    sb : strings.Builder
    strings.builder_init(&sb)
    defer strings.builder_destroy(&sb)

    fmt.printf("P3\n{} {}\n255\n", image_width, image_height);
    for y in 0..< image_height {
        current_line := image_height - y;
        fmt.fprintf(os.stderr, "\rScan lines remaining: %v ", (image_height - y - 1))
        for x in 0 ..< image_width {
            c := output[y * image_width + x];
            // r, g, b := linear_to_gamma(c.r), linear_to_gamma(c.g), linear_to_gamma(c.b)
            ir, ig, ib := int(256 * clamp(c.r, 0.0, 0.999)), int(256 * clamp(c.g, 0.0, 0.999)), int(256 * clamp(c.b, 0.0, 0.999));
            strings.write_string(&sb, fmt.tprintf("{} {} {}\n", ir, ig, ib));
        }
    }

    fmt.print(strings.to_string(sb));
    fmt.fprintf(os.stderr, "\rDone.                  \n");
}

track_allocs :: proc(track: ^mem.Tracking_Allocator) {
        if len(track.allocation_map) > 0 {
            fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
            for _, entry in track.allocation_map {
                fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
            }
        }
        if len(track.bad_free_array) > 0 {
            fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
            for entry in track.bad_free_array {
                fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
            }
        }
        mem.tracking_allocator_destroy(track)
}
