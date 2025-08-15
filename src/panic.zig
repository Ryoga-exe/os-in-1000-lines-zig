const std = @import("std");
const log = std.log;

pub const panic_fn = panic;

var panicked = false;

fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    @branchHint(.cold);

    log.err("{s}", .{msg});

    if (panicked) {
        log.err("Double panic detected. Halting.", .{});

        // endlessHalt
        while (true) {
            asm volatile ("wfi");
        }
    }

    panicked = true;

    var it = std.debug.StackIterator.init(@returnAddress(), null);
    var ix: usize = 0;
    log.err("=== Stack Trace ===", .{});
    while (it.next()) |frame| : (ix += 1) {
        log.err("#{d:0>2}: 0x{X:0>16}", .{ ix, frame });
    }

    // endlessHalt
    while (true) {
        asm volatile ("wfi");
    }
}
