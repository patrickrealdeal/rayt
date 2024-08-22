package main

Camera :: struct {
    image_height, image_width: int,
    aspect_ratio: f64,
    center: Vec3,
    pixel00_loc: Vec3,
    pixel_delta_v, pixel_delta_u: Vec3,
    samples, depth: int,
}

camera_init :: proc(aspect_ratio: f64, image_width, image_height: int) -> Camera {
    cam: Camera
    cam.image_height = image_height 
    cam.image_height = 1 if image_height < 1 else image_height

    cam.center = Vec3{0,0,0}

    // Determine viewport dimensions
    focal_length := 1.0
    viewport_height := 2.0
    viewport_width := viewport_height * f64(image_width) / f64(image_height)

    // Calcualate the vectors across the horizontal and vertical vieport edges
    viewport_u := Vec3{viewport_width, 0, 0}
    viewport_v := Vec3{0, -viewport_height, 0}
    
    // Calculate the horizontal and vertical delta vectors from pixel to pixel
    cam.pixel_delta_u = viewport_u / f64(image_width)
    cam.pixel_delta_v = viewport_v / f64(image_height)

    // Calculate the location of the upper left pixel
    viewport_upper_left := cam.center - Vec3{0,0, focal_length} - viewport_u/2 - viewport_v/2
    cam.pixel00_loc = viewport_upper_left + 0.5 * (cam.pixel_delta_u + cam.pixel_delta_v)

    return cam
}

camera_get_ray :: proc(cam: ^Camera, i, j: f64) -> Ray {
    offset := sample_squared()
    pixel_sample := cam.pixel00_loc + ((f64(i) + offset.x) * cam.pixel_delta_u) + ((f64(j) + offset.y) * cam.pixel_delta_v)
    ray_origin := cam.center
    ray_direction := pixel_sample - ray_origin

    return Ray{ ray_origin, ray_direction }
}

sample_squared :: proc() -> Vec3 {
    return random_vec3() - 0.5
}
