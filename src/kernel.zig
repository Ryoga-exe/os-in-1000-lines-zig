extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;

pub export fn kernel_main() callconv(.C) noreturn {
    const start = @intFromPtr(&__bss);
    const end = @intFromPtr(&__bss_end);
    const len: usize = end - start;

    const bss_ptr: [*]u8 = @ptrFromInt(start);
    @memset(bss_ptr[0..len], 0);

    while (true) {}
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
