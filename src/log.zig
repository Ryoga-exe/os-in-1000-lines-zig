const std = @import("std");
const sbi = @import("sbi.zig");

fn log(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime fmt: []const u8,
    args: anytype,
) void {
    _ = level;
    _ = scope;

    const console = sbi.Console{};
    std.fmt.format(console.writer(), fmt ++ "\r\n", args) catch unreachable;
}

pub const default_log_options = std.Options{
    .logFn = log,
};
