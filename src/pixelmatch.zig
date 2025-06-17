const std = @import("std");

pub const Rgba = struct {
    r: u8,
    b: u8,
    g: u8,
    a: u8,

    fn equals(self: Rgba, other: Rgba) bool {
        return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a;
    }
};

pub fn pixelmatch(image1: *const []Rgba, image2: *const []Rgba, output: *[]Rgba, width: usize, height: usize) !usize {
    if (image1.len != image2.len) return error.ImageSizeMismatch;
    if (output.len != image1.len) return error.OutputSizeMismatch;
    if (image1.len != width * height) return error.ImageWidthHeightMismatch;

    var identical = true;

    // Fast pass if the images are identical
    for (image1.*, image2.*) |pixel1, pixel2| {
        if (!pixel1.equals(pixel2)) {
            identical = false;
            break;
        }
    }

    // Images are identical, return 0 diffs
    if (identical) return 0;

    var diffs: usize = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            const i = y * width + x;
            const pixel1 = image1.*[i];
            const pixel2 = image2.*[i];

            if (!pixel1.equals(pixel2)) {
                diffs += 1;
                output.*[i] = Rgba{
                    .r = 255,
                    .g = 0,
                    .b = 0,
                    .a = 255,
                };
            } else {
                output.*[i] = Rgba{
                    .r = 0,
                    .g = 0,
                    .b = 0,
                    .a = 225,
                };
            }
        }
    }

    // todo:
    return diffs;
}
