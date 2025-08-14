const builtin = @import("builtin");

extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;

// TODO: enumerate errors
const SbiError = error{
    Failed,
};

fn sbi_call(
    arg0: usize,
    arg1: usize,
    arg2: usize,
    arg3: usize,
    arg4: usize,
    arg5: usize,
    fid: usize,
    eid: usize,
) SbiError!usize {
    var value: usize = undefined;

    // RV32
    const err: isize = asm volatile (
        \\ ecall
        \\ sw a1, 0(%[valp])
        : [err] "={a0}" (-> isize),
        : [a0] "{a0}" (arg0),
          [a1] "{a1}" (arg1),
          [a2] "{a2}" (arg2),
          [a3] "{a3}" (arg3),
          [a4] "{a4}" (arg4),
          [a5] "{a5}" (arg5),
          [a6] "{a6}" (fid),
          [a7] "{a7}" (eid),
          [valp] "r" (&value),
        : "memory"
    );
    if (err == 0) {
        return value;
    }
    // TODO: error
    return SbiError.Failed;
}

fn sbi_console_putchar(ch: u8) SbiError!void {
    _ = try sbi_call(@as(usize, ch), 0, 0, 0, 0, 0, 0, 1);
}

pub export fn kernel_main() callconv(.C) noreturn {
    const s = "\n\nHello World!\n";
    for (s) |c| {
        sbi_console_putchar(c) catch {};
    }

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
