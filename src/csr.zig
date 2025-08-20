pub inline fn readCSR(comptime reg: []const u8) usize {
    return asm volatile ("csrr %[ret], " ++ reg
        : [ret] "=&r" (-> usize),
    );
}

pub inline fn writeCSR(comptime reg: []const u8, value: usize) void {
    asm volatile ("csrw " ++ reg ++ ", %[v]"
        :
        : [v] "r" (value),
    );
}
