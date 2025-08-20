const builtin = @import("builtin");
const sbi = @import("sbi.zig");
const csr = @import("csr.zig");

const trap_handler = @import("trap_handler.zig");

pub const std_options = @import("log.zig").default_log_options;
pub const panic = @import("panic.zig").panic_fn;

extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;

pub export fn kernel_main() callconv(.C) noreturn {
    const start = @intFromPtr(&__bss);
    const end = @intFromPtr(&__bss_end);
    const len: usize = end - start;

    const bss_ptr: [*]u8 = @ptrFromInt(start);
    @memset(bss_ptr[0..len], 0);

    const console = sbi.Console{};
    const writer = console.writer();
    writer.print("\n\nHello World!\n", .{}) catch {};

    csr.writeCSR("stvec", @intFromPtr(&trap_handler.kernel_entry));
    asm volatile ("unimp");

    unreachable;
}

pub export fn boot() linksection(".text.boot") callconv(.naked) noreturn {
    asm volatile (
        \\ mv sp, %[stack]
        \\ j kernel_main
        :
        : [stack] "r" (&__stack_top),
        : "memory"
    );
}
