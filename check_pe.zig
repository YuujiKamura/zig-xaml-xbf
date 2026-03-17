const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("C:\\Users\\yuuji\\.nuget\\packages\\microsoft.windowsappsdk\\1.6.250108002\\tools\\x64\\GenXbf.dll", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    _ = try file.read(&buffer);

    // MZ header
    if (buffer[0] != 'M' or buffer[1] != 'Z') return error.NotPE;

    // PE header offset at 0x3C
    const pe_offset = std.mem.readInt(u32, buffer[0x3C..][0..4], .little);

    // PE signature
    if (buffer[pe_offset] != 'P' or buffer[pe_offset+1] != 'E') return error.NotPE;

    // Machine type at pe_offset + 4
    const machine = std.mem.readInt(u16, buffer[pe_offset+4..][0..2], .little);

    std.debug.print("Machine: 0x{x}\n", .{machine});
    // 0x8664 = x86_64
    // 0x14c = i386
    // 0xaa64 = arm64
}
