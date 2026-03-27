//! Main application logic and state management.
//!
//! Encapsulates the UI state, rendering, and Window procedure logic,
//! avoiding global variables and adhering to SOLID principles.

const std = @import("std");
const win32 = @import("win32.zig");
const network = @import("network.zig");
const theme = @import("theme.zig");
const utils = @import("utils.zig");

const log = std.log.scoped(.app);

/// Represents the entire state of the NetMeter application.
pub const App = struct {
    hwnd: ?win32.HWND = null,
    nid: win32.NOTIFYICONDATAW = .{},
    font: ?win32.HFONT = null,

    last_bytes_recv: u64 = 0,
    last_bytes_sent: u64 = 0,
    last_time: i64 = 0,
    perf_freq: i64 = 1,

    down_speed: f64 = 0,
    up_speed: f64 = 0,

    is_dark: bool = true,
    bg_color: win32.COLORREF = 0x00121212,
    text_color: win32.COLORREF = 0x00FFFFFF,

    width: i32 = 180,
    height: i32 = 40,

    initialized: bool = false,

    /// Initializes a new instance of the App.
    pub fn init() App {
        return .{};
    }

    /// Retrieves the high-resolution performance counter.
    fn getPerformanceCounter() i64 {
        var counter: i64 = 0;
        _ = win32.QueryPerformanceCounter(&counter);
        return counter;
    }

    /// Retrieves the high-resolution performance frequency.
    pub fn getPerformanceFrequency() i64 {
        var freq: i64 = 0;
        _ = win32.QueryPerformanceFrequency(&freq);
        return freq;
    }

    /// Creates the UI font based on DPI settings.
    pub fn createFont(self: *App, hwnd: ?win32.HWND) ?win32.HFONT {
        _ = self;
        var height: win32.LONG = -17;
        if (hwnd) |h| {
            const dpi = win32.GetDpiForWindow(h);
            if (dpi > 0) {
                height = -@as(win32.LONG, @intCast(@as(u32, 17) * dpi / 96));
            }
        }

        var lf: win32.LOGFONTW = .{};
        lf.lfHeight = height;
        lf.lfWeight = win32.FW_NORMAL;
        lf.lfCharSet = win32.DEFAULT_CHARSET;
        lf.lfOutPrecision = win32.OUT_DEFAULT_PRECIS;
        lf.lfClipPrecision = win32.CLIP_DEFAULT_PRECIS;
        lf.lfQuality = win32.CLEARTYPE_QUALITY;
        lf.lfPitchAndFamily = win32.VARIABLE_PITCH | win32.FF_SWISS;

        const face = comptime blk: {
            const name = "Segoe UI";
            var result: [32]u16 = [_]u16{0} ** 32;
            for (name, 0..) |c, i| {
                result[i] = c;
            }
            break :blk result;
        };
        lf.lfFaceName = face;

        return win32.CreateFontIndirectW(&lf);
    }

    /// Updates the theme colors based on Windows settings.
    pub fn updateTheme(self: *App) void {
        if (theme.isLightTheme()) {
            self.is_dark = false;
            self.bg_color = 0x00E6E6E6;
            self.text_color = 0x00000000;
        } else {
            self.is_dark = true;
            self.bg_color = 0x00121212;
            self.text_color = 0x00FFFFFF;
        }
    }

    /// Applies layered window attributes for transparency.
    pub fn applyLayeredWindow(self: *App) void {
        if (self.hwnd) |hwnd| {
            var ex_style = win32.GetWindowLongW(hwnd, win32.GWL_EXSTYLE);
            ex_style |= @as(win32.LONG, @bitCast(@as(u32, win32.WS_EX_LAYERED)));
            _ = win32.SetWindowLongW(hwnd, win32.GWL_EXSTYLE, ex_style);
            _ = win32.SetLayeredWindowAttributes(hwnd, self.bg_color, 0, win32.LWA_COLORKEY);
        }
    }

    /// Automatically positions the window above the system tray.
    pub fn autoPosition(self: *App) void {
        const h_taskbar = win32.FindWindowW(utils.L("Shell_TrayWnd"), null);
        const h_tray = win32.FindWindowExW(h_taskbar, null, utils.L("TrayNotifyWnd"), null);

        if (h_taskbar != null and h_tray != null) {
            var tr_rect: win32.RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 };
            _ = win32.GetWindowRect(h_tray, &tr_rect);

            const tray_top = tr_rect.top;
            const tray_height = tr_rect.bottom - tr_rect.top;

            const x = tr_rect.left - self.width;
            const y = tray_top + @divTrunc(tray_height, 2) - @divTrunc(self.height, 2) - 1;

            _ = win32.SetWindowPos(
                self.hwnd,
                win32.HWND_TOPMOST,
                x,
                y,
                0,
                0,
                win32.SWP_NOSIZE | win32.SWP_NOACTIVATE | win32.SWP_SHOWWINDOW,
            );
        }
    }

    /// Refreshes network statistics and updates calculated speeds.
    pub fn refreshNetworkStats(self: *App) void {
        const now = getPerformanceCounter();
        const totals = network.getNetworkTotals() catch |err| {
            log.err("failed to retrieve network stats: {}", .{err});
            return;
        };

        if (self.initialized) {
            const dt_ticks = now - self.last_time;
            if (dt_ticks > 0) {
                const dt: f64 = @as(f64, @floatFromInt(dt_ticks)) / @as(f64, @floatFromInt(self.perf_freq));
                
                // Task Manager uses exactly a 1-second update interval for its calculations.
                // We update when at least 0.9 seconds have passed to match its behavior.
                if (dt > 0.9) {
                    if (totals.recv >= self.last_bytes_recv) {
                        self.down_speed = @as(f64, @floatFromInt(totals.recv - self.last_bytes_recv)) / dt;
                    } else {
                        self.down_speed = 0;
                    }

                    if (totals.sent >= self.last_bytes_sent) {
                        self.up_speed = @as(f64, @floatFromInt(totals.sent - self.last_bytes_sent)) / dt;
                    } else {
                        self.up_speed = 0;
                    }

                    self.last_bytes_recv = totals.recv;
                    self.last_bytes_sent = totals.sent;
                    self.last_time = now;
                }
                return; // Return here so we don't update time/bytes if dt <= 0.9
            }
        }

        self.last_bytes_recv = totals.recv;
        self.last_bytes_sent = totals.sent;
        self.last_time = now;
        self.initialized = true;
    }

    /// Renders the overlay window with current statistics.
    pub fn paintWindow(self: *App, hwnd: win32.HWND) void {
        var ps: win32.PAINTSTRUCT = .{};
        const hdc_paint = win32.BeginPaint(hwnd, &ps);
        if (hdc_paint == null) return;
        defer _ = win32.EndPaint(hwnd, &ps);

        var client_rect: win32.RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 };
        _ = win32.GetClientRect(hwnd, &client_rect);

        const w = client_rect.right - client_rect.left;
        const h = client_rect.bottom - client_rect.top;

        const mem_dc = win32.CreateCompatibleDC(hdc_paint);
        if (mem_dc == null) return;
        defer _ = win32.DeleteDC(mem_dc);

        const mem_bmp = win32.CreateCompatibleBitmap(hdc_paint, w, h);
        if (mem_bmp == null) return;
        const old_bmp = win32.SelectObject(mem_dc, mem_bmp);
        defer {
            _ = win32.SelectObject(mem_dc, old_bmp);
            _ = win32.DeleteObject(mem_bmp);
        }

        const bg_brush = win32.CreateSolidBrush(self.bg_color);
        _ = win32.FillRect(mem_dc, &client_rect, bg_brush);
        _ = win32.DeleteObject(@ptrCast(bg_brush));

        _ = win32.SetBkMode(mem_dc, win32.TRANSPARENT);
        _ = win32.SetTextColor(mem_dc, self.text_color);

        if (self.font) |f| {
            _ = win32.SelectObject(mem_dc, @ptrCast(f));
        }

        var down_buf: [64]u8 = undefined;
        var up_buf: [64]u8 = undefined;
        const down_str = utils.formatSpeed(&down_buf, self.down_speed);
        const up_str = utils.formatSpeed(&up_buf, self.up_speed);

        var down_display: [128]u8 = undefined;
        var up_display: [128]u8 = undefined;

        const down_text = std.fmt.bufPrint(&down_display, "\xe2\x86\x93 {s}", .{down_str}) catch "? ?";
        const up_text = std.fmt.bufPrint(&up_display, "\xe2\x86\x91 {s}", .{up_str}) catch "? ?";

        var down_wide: [128]u16 = undefined;
        var up_wide: [128]u16 = undefined;

        const down_w = utils.utf8ToUtf16(down_text, &down_wide);
        const up_w = utils.utf8ToUtf16(up_text, &up_wide);

        const margin_right: i32 = 35;
        const margin_bottom: i32 = 4;
        const half_h = @divTrunc(h - margin_bottom, 2);

        var rect_down: win32.RECT = .{
            .left = 0,
            .top = 0,
            .right = w - margin_right,
            .bottom = half_h,
        };
        _ = win32.DrawTextW(mem_dc, down_w.ptr, @intCast(down_w.len), &rect_down, win32.DT_RIGHT | win32.DT_VCENTER | win32.DT_SINGLELINE);

        var rect_up: win32.RECT = .{
            .left = 0,
            .top = half_h,
            .right = w - margin_right,
            .bottom = h - margin_bottom,
        };
        _ = win32.DrawTextW(mem_dc, up_w.ptr, @intCast(up_w.len), &rect_up, win32.DT_RIGHT | win32.DT_VCENTER | win32.DT_SINGLELINE);

        _ = win32.BitBlt(hdc_paint, 0, 0, w, h, mem_dc, 0, 0, win32.SRCCOPY);
    }

    /// Shows the context menu for the system tray icon.
    pub fn showTrayMenu(self: *App, hwnd: ?win32.HWND) void {
        _ = self;
        const menu = win32.CreatePopupMenu();
        if (menu == null) return;
        defer _ = win32.DestroyMenu(menu);

        _ = win32.AppendMenuW(menu, win32.MF_STRING, win32.ID_EXIT, utils.L("Exit Network Meter"));

        var pt: win32.POINT = .{ .x = 0, .y = 0 };
        _ = win32.GetCursorPos(&pt);

        _ = win32.SetForegroundWindow(hwnd);
        _ = win32.TrackPopupMenu(
            menu,
            win32.TPM_BOTTOMALIGN | win32.TPM_LEFTALIGN | win32.TPM_RIGHTBUTTON,
            pt.x,
            pt.y,
            0,
            hwnd,
            null,
        );
        _ = win32.PostMessageW(hwnd, win32.WM_USER, 0, 0);
    }

    /// Main Window Procedure handling messages for this app instance.
    pub fn handleMessage(self: *App, hwnd: win32.HWND, msg: win32.UINT, wParam: win32.WPARAM, lParam: win32.LPARAM) win32.LRESULT {
        switch (msg) {
            win32.WM_TIMER => {
                if (wParam == 1) {
                    self.updateTheme();
                    self.applyLayeredWindow();
                    self.refreshNetworkStats();
                    self.autoPosition();
                    _ = win32.InvalidateRect(hwnd, null, win32.FALSE);
                }
                return 0;
            },
            win32.WM_PAINT => {
                self.paintWindow(hwnd);
                return 0;
            },
            win32.WM_ERASEBKGND => {
                return 1;
            },
            win32.WM_TRAYICON => {
                const event_low: u32 = @truncate(@as(u64, @bitCast(lParam)));
                if (event_low == win32.WM_RBUTTONUP or event_low == win32.WM_LBUTTONUP) {
                    self.showTrayMenu(hwnd);
                }
                return 0;
            },
            win32.WM_COMMAND => {
                const id: u32 = @truncate(wParam);
                if (id == win32.ID_EXIT) {
                    _ = win32.Shell_NotifyIconW(win32.NIM_DELETE, &self.nid);
                    win32.PostQuitMessage(0);
                }
                return 0;
            },
            win32.WM_DESTROY => {
                _ = win32.KillTimer(hwnd, 1);
                _ = win32.Shell_NotifyIconW(win32.NIM_DELETE, &self.nid);
                if (self.font) |f| {
                    _ = win32.DeleteObject(@ptrCast(f));
                    self.font = null;
                }
                win32.PostQuitMessage(0);
                return 0;
            },
            else => return win32.DefWindowProcW(hwnd, msg, wParam, lParam),
        }
    }
};
