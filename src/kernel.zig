const builtin = @import("builtin");
const sbi = @import("sbi.zig");

extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;

pub export fn kernel_main() callconv(.C) noreturn {
    const console = sbi.Console{};
    const writer = console.writer();
    writer.print("\n\nHello World!\n", .{}) catch {};

    while (true) {
        asm volatile ("wfi");
    }
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
