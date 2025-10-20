const std = @import("std");
pub const PageAllocator = @import("mem/PageAllocator.zig");

pub var page_allocator_instance = PageAllocator.newUninit();
pub const page_allocator = std.mem.Allocator{
    .ptr = &page_allocator_instance,
    .vtable = &PageAllocator.vtable,
};
