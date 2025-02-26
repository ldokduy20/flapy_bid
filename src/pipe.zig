const rl = @import("raylib");
const GAP = @import("config.zig").GAP;

pub const Pipe = struct {
    x: i32,
    y: i32,
    vel_x: i32,
    tex: *const rl.Texture2D,

    top_rect: rl.Rectangle,
    bot_rect: rl.Rectangle,

    pub fn new(x: i32, y: i32, vel_x: i32, tex: *const rl.Texture2D) Pipe {
        return .{ .x = x, .y = y, .vel_x = vel_x, .tex = tex, .top_rect = rl.Rectangle{
            .x = @floatFromInt((x - @divTrunc(tex.width, 2))),
            .y = @floatFromInt((y - @divTrunc(GAP, 2)) - tex.height),
            .width = @floatFromInt(tex.width),
            .height = @floatFromInt(tex.height),
        }, .bot_rect = rl.Rectangle{
            .x = @floatFromInt((x - @divTrunc(tex.width, 2))),
            .y = @floatFromInt(y + @divTrunc(GAP, 2)),
            .width = @floatFromInt(tex.width),
            .height = @floatFromInt(tex.height),
        } };
    }

    pub fn draw(p: *const Pipe) void {
        // rl.drawTextureEx(
        //     p.tex.*,
        //     rl.Vector2{
        //         .x = @floatFromInt((p.x - @divTrunc(p.tex.width, 2))),
        //         .y = @floatFromInt((p.y - @divTrunc(GAP, 2)))
        //     },
        //     180.0,
        //     1.0,
        //     rl.Color.white
        // );
        rl.drawTexturePro(
            p.tex.*,
            rl.Rectangle{
                .x = 0.0,
                .y = 0.0,
                .width = @floatFromInt(p.tex.width),
                .height = @floatFromInt(-p.tex.height),
            },
            // rl.Rectangle{
            //     .x = @floatFromInt((p.x - @divTrunc(p.tex.width, 2))),
            //     .y = @floatFromInt((p.y - @divTrunc(GAP, 2)) - p.tex.height),
            //     .width = @floatFromInt(p.tex.width),
            //     .height = @floatFromInt(p.tex.height),
            // },
            p.top_rect,
            rl.Vector2{ .x = 0.0, .y = 0.0 },
            0.0,
            rl.Color.white,
        );

        // rl.drawTexture(
        //     p.tex.*,
        //     (p.x - @divTrunc(p.tex.width, 2)),
        //     (p.y + @divTrunc(GAP, 2)),
        //     rl.Color.white,
        // );

        rl.drawTextureRec(
            p.tex.*,
            rl.Rectangle{
                .x = 0.0,
                .y = 0.0,
                .width = @floatFromInt(p.tex.width),
                .height = @floatFromInt(p.tex.height),
            },
            rl.Vector2{ .x = p.bot_rect.x, .y = p.bot_rect.y },
            rl.Color.white,
        );
    }

    pub fn update(p: *Pipe) void {
        // p.x += p.vel_x;
        p.top_rect.x += @floatFromInt(p.vel_x);
        p.bot_rect.x += @floatFromInt(p.vel_x);
    }
};
