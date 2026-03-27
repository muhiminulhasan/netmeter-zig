//! Network statistics gathering module.
//!
//! Handles querying the Windows IP Helper API (GetIfTable2) to compute
//! current receive and transmit totals across all active network interfaces.

const std = @import("std");
const win32 = @import("win32.zig");

const log = std.log.scoped(.network);

/// Holds the total received and sent bytes across all interfaces.
pub const NetworkTotals = struct {
    recv: u64,
    sent: u64,
};

/// Errors that can occur during network statistics gathering.
pub const NetworkError = error{
    GetIfTable2Failed,
};

/// Retrieves the current network totals by querying active interfaces.
pub fn getNetworkTotals() NetworkError!NetworkTotals {
    var table: ?*win32.MIB_IF_TABLE2 = null;
    const ret = win32.GetIfTable2(&table);
    if (ret != 0 or table == null) {
        log.err("GetIfTable2 failed with code: {d}", .{ret});
        return error.GetIfTable2Failed;
    }
    defer win32.FreeMibTable(@ptrCast(table));

    const num = table.?.NumEntries;
    const rows_ptr: [*]win32.MIB_IF_ROW2 = @ptrCast(@alignCast(@as([*]u8, @ptrCast(table.?)) + @sizeOf(win32.MIB_IF_TABLE2)));

    var best_if_index: u32 = 0;
    // Query the routing table for the interface used to reach the internet (8.8.8.8).
    // 0x08080808 is the IP address 8.8.8.8 in hex.
    const best_ret = win32.GetBestInterface(0x08080808, &best_if_index);
    if (best_ret != 0) {
        log.warn("GetBestInterface failed with code: {d}, falling back to heuristic", .{best_ret});
    }

    var total_recv: u64 = 0;
    var total_sent: u64 = 0;

    for (0..num) |i| {
        const row = rows_ptr[i];

        if (best_ret == 0) {
            // We found the active internet adapter, only track this one
            // to completely exclude virtual adapters, WSL, host-only networks, etc.
            if (row.InterfaceIndex == best_if_index) {
                total_recv += row.InOctets;
                total_sent += row.OutOctets;
            }
        } else {
            // Fallback heuristic if routing query fails
            const is_up = row.OperStatus == 1;
            const is_target_type = row.Type == 6 or row.Type == 71;
            const flags = row.InterfaceAndOperStatusFlags;
            const is_hardware = (flags & 1) != 0;
            const is_filter = (flags & 2) != 0;
            const has_connector = (flags & 4) != 0;

            if (is_up and is_target_type and is_hardware and !is_filter and has_connector) {
                total_recv += row.InOctets;
                total_sent += row.OutOctets;
            }
        }
    }

    return .{ .recv = total_recv, .sent = total_sent };
}
