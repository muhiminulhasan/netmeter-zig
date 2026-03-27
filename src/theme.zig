//! System theme detection module.
//!
//! Checks the Windows registry to determine if the user is using a Light or Dark theme.

const std = @import("std");
const win32 = @import("win32.zig");
const utils = @import("utils.zig");

const log = std.log.scoped(.theme);

/// Checks if the current Windows theme is set to Light mode.
pub fn isLightTheme() bool {
    var hkey: ?win32.HKEY = null;
    const status = win32.RegOpenKeyExW(
        win32.HKEY_CURRENT_USER,
        utils.L("Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"),
        0,
        win32.KEY_READ,
        &hkey,
    );
    if (status != 0) {
        log.warn("Failed to open registry key for theme, defaulting to Dark. Status: {d}", .{status});
        return false;
    }
    defer _ = win32.RegCloseKey(hkey);

    var value: win32.DWORD = 0;
    var value_size: win32.DWORD = @sizeOf(win32.DWORD);
    var reg_type: win32.DWORD = 0;
    const qstatus = win32.RegQueryValueExW(
        hkey,
        utils.L("SystemUsesLightTheme"),
        null,
        &reg_type,
        @ptrCast(&value),
        &value_size,
    );
    if (qstatus != 0) {
        log.warn("Failed to query registry value for theme, defaulting to Dark. Status: {d}", .{qstatus});
        return false;
    }
    return value == 1;
}
