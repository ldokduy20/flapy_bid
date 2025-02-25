const rl = @import("raylib");
const config = @import("config.zig");

pub const Bird = struct {
    // x and y position is in the **center**.
    x: i32,
    y: i32,
    vel_y: i32,
    grav: i32,

    w: i32,
    h: i32,

    tex: *const rl.Texture2D,

    pub fn new(x: i32, y: i32, tex: *const rl.Texture2D) Bird {
        return .{ .x = x, .y = y, .vel_y = 0, .grav = config.BIRD_GRAVITY, .tex = tex, .w = tex.width, .h = tex.height };
    }

    pub fn draw(b: *const Bird) void {
        rl.drawTexture(b.tex.*, b.x - @divTrunc(b.w, 2), b.y - @divTrunc(b.h, 2), rl.Color.white);
    }

    pub fn update(b: *Bird) void {
        b.y += b.vel_y;
        b.vel_y += b.grav;
    }

    pub fn bump(b: *Bird) void {
        b.vel_y = -config.BIRD_BUMP_AMOUNT;
    }
};
