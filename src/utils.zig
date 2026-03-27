//! Utility functions for strings, conversions, and formatting.

const std = @import("std");
const win32 = @import("win32.zig");

/// Converts a comptime UTF-8 string to a null-terminated wide string (LPCWSTR) at compile time.
pub fn L(comptime str: []const u8) [*:0]const u16 {
    return std.unicode.utf8ToUtf16LeStringLiteral(str);
}

test "formatSpeed" {
    var buf: [64]u8 = undefined;
    
    // 100 bytes/sec = 800 bps
    try std.testing.expectEqualStrings("800 bps", formatSpeed(&buf, 100.0));
    
    // 1000 bytes/sec = 8000 bps = 8.0 Kbps
    try std.testing.expectEqualStrings("8.0 Kbps", formatSpeed(&buf, 1000.0));
    
    // 1,000,000 bytes/sec = 8,000,000 bps = 8.0 Mbps
    try std.testing.expectEqualStrings("8.0 Mbps", formatSpeed(&buf, 1000000.0));
    
    // 1,000,000,000 bytes/sec = 8,000,000,000 bps = 8.0 Gbps
    try std.testing.expectEqualStrings("8.0 Gbps", formatSpeed(&buf, 1000000000.0));
}

test "utf8ToUtf16" {
    var out: [64]u16 = undefined;
    
    const result1 = utf8ToUtf16("Hello", &out);
    try std.testing.expectEqual(@as(usize, 5), result1.len);
    try std.testing.expectEqual(@as(u16, 'H'), result1[0]);
    
    const result2 = utf8ToUtf16("↓", &out);
    try std.testing.expectEqual(@as(usize, 1), result2.len);
    try std.testing.expectEqual(@as(u16, 0x2193), result2[0]);
}

/// Formats network speed into a human-readable string (bps, Kbps, Mbps).
pub fn formatSpeed(buf: []u8, bytes_per_sec: f64) []const u8 {
    const bits_per_sec = bytes_per_sec * 8.0;
    if (bits_per_sec < 1000.0) {
        return std.fmt.bufPrint(buf, "{d:.0} bps", .{bits_per_sec}) catch "? bps";
    } else if (bits_per_sec < 1000.0 * 1000.0) {
        return std.fmt.bufPrint(buf, "{d:.1} Kbps", .{bits_per_sec / 1000.0}) catch "? Kbps";
    } else if (bits_per_sec < 1000.0 * 1000.0 * 1000.0) {
        return std.fmt.bufPrint(buf, "{d:.1} Mbps", .{bits_per_sec / (1000.0 * 1000.0)}) catch "? Mbps";
    } else {
        return std.fmt.bufPrint(buf, "{d:.1} Gbps", .{bits_per_sec / (1000.0 * 1000.0 * 1000.0)}) catch "? Gbps";
    }
}

/// Converts UTF-8 string to UTF-16 wide string at runtime.
pub fn utf8ToUtf16(utf8: []const u8, out: []u16) [:0]const u16 {
    const len = std.unicode.utf8ToUtf16Le(out[0 .. out.len - 1], utf8) catch 0;
    out[len] = 0;
    return out[0..len :0];
}
