const rl = @import("raylib");
const Bird = @import("bird.zig").Bird;
const Pipe = @import("pipe.zig").Pipe;
const std = @import("std");
const config = @import("config.zig");
const WINDOW_WIDTH = config.WINDOW_WIDTH;
const WINDOW_HEIGHT = config.WINDOW_HEIGHT;
const rand = std.rand;

const State = enum {
    Title,
    Game,
    GameOver,
};

var state = State.Game;

var score: u32 = 0;

pub fn main() !void {
    var score_text_buf: [16]u8 = undefined;
    var prng = rand.Xoshiro256.init(@as(u64, @intCast(std.time.timestamp())));
    const rng = prng.random();
    var frames: i32 = 0;
    var random_spawn_time: i32 = 60;
    const allocator = std.heap.page_allocator;
    var pipes = std.ArrayList(Pipe).init(allocator);
    defer pipes.deinit();

    var b: Bird = undefined;
    rl.setTraceLogLevel(rl.TraceLogLevel.fatal);
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Flappy Parrot Smell");
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
        switch (state) {
            State.Game => {
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
                if ((@as(i32, @intFromFloat(b.y)) - @divTrunc(b.tex.height, 2) <= 0) or (@as(i32, @intFromFloat(b.y)) + b.tex.height >= WINDOW_HEIGHT)) {
                    state = State.GameOver;
                    frames = 0;
                    random_spawn_time = 60;
                    // @divTrunc(WINDOW_WIDTH, 2), @divTrunc(WINDOW_HEIGHT, 2)
                    b.x = @divTrunc(WINDOW_WIDTH, 2);
                    b.y = @divTrunc(WINDOW_HEIGHT, 2);
                    // THIS CAUSES PANIC: pipes.clearAndFree();
                    pipes.clearRetainingCapacity();
                    score = 0;
                }
                b.update();
                for (pipes.items) |*p| {
                    if (p.touch(.{ .x = b.x, .y = b.y }, @floatFromInt(@divTrunc(b.tex.width + b.tex.height, 2)))) {
                        state = State.GameOver;
                        frames = 0;
                        random_spawn_time = 60;
                        // @divTrunc(WINDOW_WIDTH, 2), @divTrunc(WINDOW_HEIGHT, 2)
                        b.x = @divTrunc(WINDOW_WIDTH, 2);
                        b.y = @divTrunc(WINDOW_HEIGHT, 2);
                        // THIS CAUSES PANIC: pipes.clearAndFree();
                        pipes.clearRetainingCapacity();
                        score = 0;
                    } else if (!p.passed and p.pass(.{ .x = b.x, .y = b.y })) {
                        score += 1;
                        p.passed = true;
                    }
                    p.update();
                }
                frames += 1;
                if (frames == random_spawn_time) {
                    frames = 0;
                    try pipes.append(Pipe.new(288, rng.intRangeAtMost(i32, 170, 285), -2, &pipe_green));
                    random_spawn_time = rng.intRangeAtMost(i32, 100, 150);
                }

                rl.beginDrawing();
                rl.clearBackground(rl.Color.black);
                rl.drawTexture(background_day, 0, 0, rl.Color.white);
                b.draw();
                for (pipes.items, 0..) |_, i| {
                    pipes.items[i].draw();
                }
                {
                    const score_s = try std.fmt.bufPrint(&score_text_buf, "{d}", .{score});
                    score_text_buf[score_s.len] = 0;
                    const score_str: [*:0]u8 = score_text_buf[0..score_s.len :0];
                    rl.drawText(score_str, @divTrunc(WINDOW_WIDTH, 2), 30, 20, rl.Color.black);
                }
                rl.endDrawing();
            },
            State.GameOver => {
                if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                    state = State.Game;
                }

                rl.beginDrawing();
                rl.clearBackground(rl.Color.black);
                //TODO: Actually center the text
                {
                    const size = rl.measureText(config.DEAD_MESSAGE, 20);
                    rl.drawText(config.DEAD_MESSAGE, @divTrunc(WINDOW_WIDTH, 2) - @divTrunc(size, 2), @divTrunc(WINDOW_HEIGHT, 2), 20, rl.Color.white);
                }
                rl.endDrawing();
            },
            State.Title => {},
        }
    }
}
