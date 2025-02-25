const rl = @import("raylib");
const Bird = @import("bird.zig").Bird;
const Pipe = @import("pipe.zig").Pipe;
const std = @import("std");
const config = @import("config.zig");
const WINDOW_WIDTH = config.WINDOW_WIDTH;
const WINDOW_HEIGHT = config.WINDOW_HEIGHT;
const rand = std.rand;

pub fn main() !void {
    var prng = rand.Xoshiro256.init(@as(u64, @intCast(std.time.timestamp())));
    const rng = prng.random();
    var frames: i32 = 0;
    var random_spawn_time: i32 = 30;
    const allocator = std.heap.page_allocator;
    var pipes = std.ArrayList(Pipe).init(allocator);
    defer pipes.deinit();

    var b: Bird = undefined;
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Flapy Bord");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    const background_day = try rl.loadTexture("assets/sprites/background-day.png");
    defer rl.unloadTexture(background_day);

    const bluebird_midflap = try rl.loadTexture("assets/sprites/bluebird-midflap.png");
    defer rl.unloadTexture(bluebird_midflap);
    b = Bird.new(@divTrunc(WINDOW_WIDTH, 2), @divTrunc(WINDOW_HEIGHT, 2), &bluebird_midflap);

    const pipe_green = try rl.loadTexture("assets/sprites/pipe-green.png");
    defer rl.unloadTexture(pipe_green);

    while (!rl.windowShouldClose()) {
        //UPDATE
        for (pipes.items, 0..) |p, i| {
            if (p.x + @divTrunc(pipe_green.width, 2) <= 0) {
                _ = pipes.swapRemove(i);
            }
        }

        // if (rl.isKeyPressed(rl.KeyboardKey.s)) {
        //     try pipes.append(Pipe.new(288, @divTrunc(WINDOW_HEIGHT, 2), -15, &pipe_green));
        // }

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            b.bump();
        }
        b.update();

        for (pipes.items) |*p| {
            p.update();
            // std.debug.print("Pipe index: {d}, X: {d}, Y: {d}\n", .{ i, pipes.items[i].x, pipes.items[i].y });
        }
        frames += 1;
        if (frames == random_spawn_time) {
            frames = 0;
            try pipes.append(Pipe.new(288, @divTrunc(WINDOW_HEIGHT, 2), -2, &pipe_green));
            random_spawn_time = rng.intRangeAtMost(i32, 30, 120);
        }
        //__UPDATE

        //DRAWING
        rl.beginDrawing();
        rl.drawTexture(background_day, 0, 0, rl.Color.white);
        b.draw();
        for (pipes.items, 0..) |_, i| {
            pipes.items[i].draw();
        }
        rl.endDrawing();
        //__DRAWING
    }
}
