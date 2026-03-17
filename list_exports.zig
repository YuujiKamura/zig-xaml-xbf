const std = @import("std");

fn rvaToOffset(rva: u32, data: []const u8, num_sections: u16, section_header_offset: u32) u32 {
    for (0..num_sections) |i| {
        const off = section_header_offset + @as(u32, @intCast(i)) * 40;
        const va = std.mem.readInt(u32, data[off + 12 ..][0..4], .little);
        const vs = std.mem.readInt(u32, data[off + 8 ..][0..4], .little);
        if (rva >= va and rva < va + vs) {
            return rva - va + std.mem.readInt(u32, data[off + 20 ..][0..4], .little);
        }
    }
    return 0;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("C:\\Users\\yuuji\\.nuget\\packages\\microsoft.windowsappsdk\\1.6.250108002\\tools\\x64\\GenXbf.dll", .{});
    defer file.close();

    const data = try file.readToEndAlloc(std.heap.page_allocator, 20 * 1024 * 1024);
    defer std.heap.page_allocator.free(data);

    const pe_offset = std.mem.readInt(u32, data[0x3C..][0..4], .little);
    const optional_header = pe_offset + 4 + 20;

    const magic = std.mem.readInt(u16, data[optional_header..][0..2], .little);
    const is_pe32plus = magic == 0x20b;

    const data_directories = optional_header + (if (is_pe32plus) @as(u32, 112) else @as(u32, 96));
    const export_rva = std.mem.readInt(u32, data[data_directories..][0..4], .little);

    if (export_rva == 0) {
        std.debug.print("No exports found\n", .{});
        return;
    }

    const section_header_offset = optional_header + (if (is_pe32plus) @as(u32, 240) else @as(u32, 224));
    const num_sections = std.mem.readInt(u16, data[pe_offset + 6 ..][0..2], .little);

    const export_offset = rvaToOffset(export_rva, data, num_sections, section_header_offset);
    if (export_offset == 0) return error.ExportSectionNotFound;

    const num_names = std.mem.readInt(u32, data[export_offset + 24 ..][0..4], .little);
    const names_rva = std.mem.readInt(u32, data[export_offset + 32 ..][0..4], .little);
    const names_offset = rvaToOffset(names_rva, data, num_sections, section_header_offset);

    std.debug.print("Exports ({d} names):\n", .{num_names});
    for (0..num_names) |i| {
        const name_rva = std.mem.readInt(u32, data[names_offset + i * 4 ..][0..4], .little);
        const name_offset = rvaToOffset(name_rva, data, num_sections, section_header_offset);
        const name = std.mem.span(@as([*:0]const u8, @ptrCast(data[name_offset..].ptr)));
        std.debug.print("- {s}\n", .{name});
    }
}
