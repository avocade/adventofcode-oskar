const std = @import("std");

const Vec2 = struct { x: i32, y: i32 };

const directions = [_]Vec2{
    .{ .x = 0, .y = 1 }, // north
    .{ .x = 1, .y = 0 }, // east
    .{ .x = 0, .y = -1 }, // south
    .{ .x = -1, .y = 0 }, // west
};

pub fn main() !void {
    const stdout = std.fs.File.stdout().deprecatedWriter();

    const file = try std.fs.cwd().openFile("2025/day1-1.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(std.heap.page_allocator, 1024 * 1024);
    defer std.heap.page_allocator.free(content);

    var x: i32 = 0;
    var y: i32 = 0;
    var dir: usize = 0; // 0=north, 1=east, 2=south, 3=west

    var visited = std.AutoHashMap(i64, void).init(std.heap.page_allocator);
    defer visited.deinit();
    try visited.put(packCoord(0, 0), {});
    var part2_answer: ?i32 = null;

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &[_]u8{ ' ', '\r', '\t' });
        if (trimmed.len == 0) continue;

        const turn = trimmed[0];
        const steps = std.fmt.parseInt(i32, trimmed[1..], 10) catch continue;

        if (turn == 'R') {
            dir = (dir + 1) % 4;
        } else if (turn == 'L') {
            dir = (dir + 3) % 4;
        }

        const dx = directions[dir].x;
        const dy = directions[dir].y;

        for (0..@intCast(steps)) |_| {
            x += dx;
            y += dy;
            if (part2_answer == null) {
                const key = packCoord(x, y);
                if (visited.contains(key)) {
                    part2_answer = absInt(x) + absInt(y);
                } else {
                    try visited.put(key, {});
                }
            }
        }
    }

    try stdout.print("Part 1: {d}\n", .{absInt(x) + absInt(y)});
    if (part2_answer) |p2| {
        try stdout.print("Part 2: {d}\n", .{p2});
    } else {
        try stdout.print("Part 2: no duplicate found\n", .{});
    }
}

fn packCoord(x: i32, y: i32) i64 {
    return @as(i64, x) * 1_000_000 + @as(i64, y);
}

fn absInt(v: i32) i32 {
    return if (v < 0) -v else v;
}
