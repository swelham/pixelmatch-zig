const std = @import("std");
const pm = @import("pixelmatch.zig");
const pixelmatch = pm.pixelmatch;
const Rgba = pm.Rgba;

const black_pixel = Rgba{
    .r = 0,
    .g = 0,
    .b = 0,
    .a = 255,
};

const blue_pixel = Rgba{
    .r = 0,
    .g = 0,
    .b = 255,
    .a = 255,
};

const red_pixel = Rgba{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 255,
};

fn create_image(allocator: std.mem.Allocator, width: usize, height: usize) ![]Rgba {
    var image = try allocator.alloc(Rgba, width * height);

    for (0..width * height) |i| {
        image[i] = black_pixel;
    }

    return image;
}

test "returns an error if the image sizes mismatch" {
    const width = 2;
    const height = 1;

    const allocator = std.testing.allocator;

    const image1 = try allocator.alloc(Rgba, width * height);
    defer allocator.free(image1);

    const image2 = try allocator.alloc(Rgba, 1);
    defer allocator.free(image2);

    var output = try allocator.alloc(Rgba, width * height);
    defer allocator.free(output);

    try std.testing.expectError(error.ImageSizeMismatch, pixelmatch(&image1, &image2, &output, width, height));
}

test "returns an error if the output size mismatches the image size" {
    const width = 2;
    const height = 1;

    const allocator = std.testing.allocator;

    const image1 = try allocator.alloc(Rgba, width * height);
    defer allocator.free(image1);

    const image2 = try allocator.alloc(Rgba, width * height);
    defer allocator.free(image2);

    var output = try allocator.alloc(Rgba, 3);
    defer allocator.free(output);

    try std.testing.expectError(error.OutputSizeMismatch, pixelmatch(&image1, &image2, &output, width, height));
}

test "returns an error if the image sizes mismatch the width and height" {
    const width = 3;
    const height = 1;

    const allocator = std.testing.allocator;

    const image1 = try allocator.alloc(Rgba, 2);
    defer allocator.free(image1);

    const image2 = try allocator.alloc(Rgba, 2);
    defer allocator.free(image2);

    var output = try allocator.alloc(Rgba, 2);
    defer allocator.free(output);

    try std.testing.expectError(error.ImageWidthHeightMismatch, pixelmatch(&image1, &image2, &output, width, height));
}

test "returns '0' when the images are identical" {
    const width = 20;
    const height = 3;

    const allocator = std.testing.allocator;

    const image1 = try create_image(allocator, width, height);
    defer allocator.free(image1);

    const image2 = try create_image(allocator, width, height);
    defer allocator.free(image2);

    var output = try allocator.alloc(Rgba, width * height);
    defer allocator.free(output);

    const result = try pixelmatch(&image1, &image2, &output, width, height);

    try std.testing.expectEqual(0, result);
}

test "returns the number of different pixels" {
    const width = 20;
    const height = 3;

    const allocator = std.testing.allocator;

    const image1 = try create_image(allocator, width, height);
    defer allocator.free(image1);

    const image2 = try create_image(allocator, width, height);
    defer allocator.free(image2);

    // Set 3 pixels to blue
    image2[3] = blue_pixel;
    image2[36] = blue_pixel;
    image2[57] = blue_pixel;

    var output = try allocator.alloc(Rgba, width * height);
    defer allocator.free(output);

    const result = try pixelmatch(&image1, &image2, &output, width, height);

    try std.testing.expectEqual(3, result);
}

test "writes the diffs to the output" {
    const width = 20;
    const height = 3;

    const allocator = std.testing.allocator;

    const image1 = try create_image(allocator, width, height);
    defer allocator.free(image1);

    const image2 = try create_image(allocator, width, height);
    defer allocator.free(image2);

    // Set 3 pixels to blue
    image2[3] = blue_pixel;
    image2[4] = blue_pixel;
    image2[48] = blue_pixel;

    var output = try allocator.alloc(Rgba, width * height);
    defer allocator.free(output);

    _ = try pixelmatch(&image1, &image2, &output, width, height);

    const diff_semi_transparent_pixel = Rgba{
        .r = 0,
        .g = 0,
        .b = 0,
        .a = 225,
    };

    for (0..output.len) |i| {
        if (i == 3 or i == 4 or i == 48) {
            try std.testing.expectEqualDeep(red_pixel, output[i]);
            continue;
        }

        try std.testing.expectEqualDeep(diff_semi_transparent_pixel, output[i]);
    }
}
