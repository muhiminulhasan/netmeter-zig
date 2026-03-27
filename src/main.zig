//! Entry point for the NetMeter application.
//!
//! Initializes the application, registers the window class, creates the main
//! hidden window (used for the overlay), and runs the message loop.

const std = @import("std");
const win32 = @import("win32.zig");
const network = @import("network.zig");
const utils = @import("utils.zig");
const App = @import("app.zig").App;

const log = std.log.scoped(.main);

/// The global Window Procedure that routes messages to the App instance.
fn wndProc(hwnd: win32.HWND, msg: win32.UINT, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(.winapi) win32.LRESULT {
    // Intercept WM_NCCREATE to store the App pointer in GWLP_USERDATA
    if (msg == win32.WM_NCCREATE) {
        const create_struct: *win32.CREATESTRUCTW = @ptrFromInt(@as(usize, @bitCast(lParam)));
        if (create_struct.lpCreateParams) |lp| {
            _ = win32.SetWindowLongPtrW(hwnd, win32.GWLP_USERDATA, @intCast(@intFromPtr(lp)));
        }
    }

    // Retrieve the App pointer
    const ptr = win32.GetWindowLongPtrW(hwnd, win32.GWLP_USERDATA);
    if (ptr != 0) {
        const app: *App = @ptrFromInt(@as(usize, @bitCast(ptr)));
        return app.handleMessage(hwnd, msg, wParam, lParam);
    }

    // Default processing before WM_NCCREATE has finished
    return win32.DefWindowProcW(hwnd, msg, wParam, lParam);
}

pub fn main() !void {
    // Ensure only one instance of the application is running
    const mutex = win32.CreateMutexW(null, win32.FALSE, utils.L("Global\\NetMeter_AntiAlias_v1"));
    if (win32.GetLastError() == win32.ERROR_ALREADY_EXISTS) {
        log.warn("Application already running. Exiting.", .{});
        return;
    }
    defer if (mutex) |m| {
        _ = win32.CloseHandle(m);
    };

    const hInstance = win32.GetModuleHandleW(null);
    const class_name = utils.L("NetMeterZigClass");

    // Register Window Class
    const wc = win32.WNDCLASSEXW{
        .style = win32.CS_HREDRAW | win32.CS_VREDRAW,
        .lpfnWndProc = wndProc,
        .hInstance = hInstance,
        .hIcon = win32.LoadIconW(null, win32.IDI_APPLICATION),
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = null,
        .lpszClassName = class_name,
        .hIconSm = null,
    };

    if (win32.RegisterClassExW(&wc) == 0) {
        log.err("Failed to register window class.", .{});
        return error.RegisterClassFailed;
    }

    var app = App.init();
    app.perf_freq = App.getPerformanceFrequency();

    // Create the Window
    const ex_style: win32.DWORD = win32.WS_EX_LAYERED | win32.WS_EX_TOOLWINDOW | win32.WS_EX_TOPMOST | win32.WS_EX_TRANSPARENT | win32.WS_EX_NOACTIVATE;
    const hwnd = win32.CreateWindowExW(
        ex_style,
        class_name,
        utils.L("NetMeter"),
        win32.WS_POPUP,
        0,
        0,
        app.width,
        app.height,
        null,
        null,
        hInstance,
        &app, // Pass the App instance pointer via lpParam
    );

    if (hwnd == null) {
        log.err("Failed to create window.", .{});
        return error.CreateWindowFailed;
    }

    app.hwnd = hwnd;
    app.font = app.createFont(hwnd);

    app.updateTheme();
    app.applyLayeredWindow();

    // Initialize System Tray Icon
    app.nid = .{};
    app.nid.cbSize = @sizeOf(win32.NOTIFYICONDATAW);
    app.nid.hWnd = hwnd;
    app.nid.uID = 1;
    app.nid.uFlags = win32.NIF_MESSAGE | win32.NIF_ICON | win32.NIF_TIP;
    app.nid.uCallbackMessage = win32.WM_TRAYICON;
    app.nid.hIcon = win32.LoadIconW(null, win32.IDI_APPLICATION);

    const tip = comptime blk: {
        const text = "Network Meter";
        var result: [128]u16 = [_]u16{0} ** 128;
        for (text, 0..) |c, i| {
            result[i] = c;
        }
        break :blk result;
    };
    app.nid.szTip = tip;

    _ = win32.Shell_NotifyIconW(win32.NIM_ADD, &app.nid);

    // Initial Network Stats
    const initial = network.getNetworkTotals() catch |err| blk: {
        log.warn("Failed to get initial network stats: {}", .{err});
        break :blk network.NetworkTotals{ .recv = 0, .sent = 0 };
    };
    app.last_bytes_recv = initial.recv;
    app.last_bytes_sent = initial.sent;

    var counter: i64 = 0;
    _ = win32.QueryPerformanceCounter(&counter);
    app.last_time = counter;

    _ = win32.ShowWindow(hwnd, win32.SW_SHOW);
    _ = win32.UpdateWindow(hwnd);
    // Set up timer for regular updates (1000ms to exactly match Task Manager)
    _ = win32.SetTimer(hwnd, 1, 1000, null);

    app.autoPosition();

    // Main Message Loop
    var msg: win32.MSG = .{};
    while (win32.GetMessageW(&msg, null, 0, 0) == win32.TRUE) {
        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageW(&msg);
    }
}
