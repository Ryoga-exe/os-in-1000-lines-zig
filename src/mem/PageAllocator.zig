const std = @import("std");
const PageAllocator = @This();
const Allocator = std.mem.Allocator;
const Alignment = std.mem.Alignment;

next_paddr: usize,
paddr_end: usize,

pub const vtable = Allocator.VTable{
    .alloc = allocate,
    .free = free,
    .resize = resize,
    .remap = remap,
};

fn allocate(ctx: *anyopaque, n: usize, _: Alignment, _: usize) ?[*]u8 {
    const self: *PageAllocator = @ptrCast(@alignCast(ctx));
    if (n == 0) {
        return @ptrFromInt(self.next_paddr);
    }

    const size = std.mem.alignForward(usize, n, page_size);
    const paddr = self.next_paddr;
    const next = paddr + size;

    if (next > self.paddr_end) {
        @panic("out of memory");
    }

    const ptr: [*]u8 = @ptrFromInt(paddr);
    self.next_paddr = next;

    @memset(ptr[0..size], 0);
    return ptr;
}

fn free(ctx: *anyopaque, _: []u8, _: Alignment, _: usize) void {
    _ = ctx; // autofix
    @panic("unimplemented");
}

fn resize(ctx: *anyopaque, _: []u8, _: Alignment, _: usize, _: usize) bool {
    _ = ctx; // autofix
    @panic("unimplemented");
}

fn remap(ctx: *anyopaque, _: []u8, _: Alignment, _: usize, _: usize) ?[*]u8 {
    _ = ctx; // autofix
    @panic("unimplemented");
}

pub fn newUninit() PageAllocator {
    return PageAllocator{
        .next_paddr = undefined,
        .paddr_end = undefined,
    };
}

const page_size = 4096;
