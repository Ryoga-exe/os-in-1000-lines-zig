const std = @import("std");
const builtin = @import("builtin");

// see:
// RISC-V Supervisor Binary Interface Specification, Chapter 3. Binary Encoding, Table 1. Standard SBI Errors
// https://github.com/riscv-non-isa/riscv-sbi-doc/blob/master/src/binary-encoding.adoc
pub const SbiError = error{
    Failed, // SBI_ERR_FAILED,
    NotSupported, // SBI_ERR_NOT_SUPPORTED
    InvalidParam, // SBI_ERR_INVALID_PARAM
    Denied, // SBI_ERR_DENIED
    InvalidAddress, // SBI_ERR_INVALID_ADDRESS
    AlreadyAvailable, // SBI_ERR_ALREADY_AVAILABLE
    AlreadyStarted, // SBI_ERR_ALREADY_STARTED
    AlreadyStopped, // SBI_ERR_ALREADY_STOPPED
    NoShmem, // SBI_ERR_NO_SHMEM
    InvalidState, // SBI_ERR_INVALID_STATE
    BadRange, // SBI_ERR_BAD_RANGE
    Timeout, // SBI_ERR_TIMEOUT
    Io, // SBI_ERR_IO
    DeniedLocked, // SBI_ERR_DENIED_LOCKED
    Unknown,
};

fn call(
    arg0: usize,
    arg1: usize,
    arg2: usize,
    arg3: usize,
    arg4: usize,
    arg5: usize,
    fid: usize,
    eid: usize,
) SbiError!usize {
    const arch = builtin.target.cpu.arch;

    var value: usize = undefined;

    const err: isize = switch (arch) {
        .riscv32 => asm volatile (
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
        ),
        .riscv64 => asm volatile (
            \\ ecall
            \\ sd a1, 0(%[valp])
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
        ),
        else => @compileError(""),
    };

    return switch (err) {
        0 => value, // SBI_SUCCESS
        -1 => SbiError.Failed,
        -2 => SbiError.NotSupported,
        -3 => SbiError.InvalidParam,
        -4 => SbiError.Denied,
        -5 => SbiError.InvalidAddress,
        -6 => SbiError.AlreadyAvailable,
        -7 => SbiError.AlreadyStarted,
        -8 => SbiError.AlreadyStopped,
        -9 => SbiError.NoShmem,
        -10 => SbiError.InvalidState,
        -11 => SbiError.BadRange,
        -12 => SbiError.Timeout,
        -13 => SbiError.Io,
        -14 => SbiError.DeniedLocked,
        else => SbiError.Unknown,
    };
}

pub const Console = struct {
    const Self = @This();

    pub fn putchar(_: Self, ch: u8) SbiError!void {
        _ = try call(@as(usize, ch), 0, 0, 0, 0, 0, 0, 1);
    }

    pub fn puts(self: Self, s: []const u8) SbiError!void {
        for (s) |c| {
            try self.putchar(c);
        }
    }

    pub fn write(self: Self, s: []const u8) SbiError!usize {
        try self.puts(s);
        return s.len;
    }

    pub const Writer = std.io.GenericWriter(Self, SbiError, write);

    pub fn writer(self: Self) Writer {
        return Writer{ .context = self };
    }
};
