//! Win32 API bindings and types.
//!
//! This module encapsulates all Windows API declarations, types, and constants
//! needed by the application, providing a clean separation from application logic.

const std = @import("std");
const windows = std.os.windows;

// Basic Types
pub const HWND = windows.HWND;
pub const HINSTANCE = windows.HINSTANCE;
pub const HICON = *opaque {};
pub const HBRUSH = *opaque {};
pub const HCURSOR = *opaque {};
pub const HMENU = *opaque {};
pub const HFONT = *opaque {};
pub const HDC = *opaque {};
pub const WPARAM = windows.WPARAM;
pub const LPARAM = windows.LPARAM;
pub const LRESULT = windows.LRESULT;
pub const RECT = windows.RECT;
pub const POINT = windows.POINT;
pub const BOOL = windows.BOOL;
pub const DWORD = windows.DWORD;
pub const UINT = u32;
pub const HANDLE = windows.HANDLE;
pub const LPCWSTR = [*:0]const u16;
pub const HKEY = *opaque {};
pub const LSTATUS = windows.LSTATUS;
pub const COLORREF = u32;
pub const LONG = i32;
pub const BYTE = u8;
pub const LONG_PTR = isize;

// Constants
pub const TRUE: BOOL = 1;
pub const FALSE: BOOL = 0;

pub const WM_DESTROY = 0x0002;
pub const WM_PAINT = 0x000F;
pub const WM_TIMER = 0x0113;
pub const WM_USER = 0x0400;
pub const WM_APP = 0x8000;
pub const WM_TRAYICON = WM_APP + 1;
pub const WM_COMMAND = 0x0111;
pub const WM_RBUTTONUP = 0x0205;
pub const WM_LBUTTONUP = 0x0202;
pub const WM_ERASEBKGND = 0x0014;
pub const WM_NCCREATE = 0x0081;

pub const WS_POPUP = 0x80000000;
pub const WS_VISIBLE = 0x10000000;
pub const WS_EX_LAYERED = 0x00080000;
pub const WS_EX_TOOLWINDOW = 0x00000080;
pub const WS_EX_TOPMOST = 0x00000008;
pub const WS_EX_TRANSPARENT = 0x00000020;
pub const WS_EX_NOACTIVATE = 0x08000000;

pub const GWL_EXSTYLE = -20;
pub const GWLP_USERDATA = -21;

pub const CS_HREDRAW = 0x0002;
pub const CS_VREDRAW = 0x0001;

pub const SW_SHOW = 5;
pub const SW_HIDE = 0;

pub const SWP_NOSIZE = 0x0001;
pub const SWP_NOACTIVATE = 0x0010;
pub const SWP_SHOWWINDOW = 0x0040;
pub const HWND_TOPMOST: ?HWND = @ptrFromInt(@as(usize, @bitCast(@as(isize, -1))));

pub const LWA_COLORKEY: DWORD = 0x00000001;

pub const IDI_APPLICATION = @as(LPCWSTR, @ptrFromInt(32512));
pub const IDC_ARROW = @as(LPCWSTR, @ptrFromInt(32512));

pub const NIM_ADD = 0x00000000;
pub const NIM_DELETE = 0x00000002;
pub const NIF_MESSAGE = 0x00000001;
pub const NIF_ICON = 0x00000002;
pub const NIF_TIP = 0x00000004;
pub const NOTIFYICON_VERSION_4 = 4;

pub const FW_NORMAL = 400;
pub const DEFAULT_CHARSET = 1;
pub const OUT_DEFAULT_PRECIS = 0;
pub const CLIP_DEFAULT_PRECIS = 0;
pub const CLEARTYPE_QUALITY = 5;
pub const VARIABLE_PITCH = 2;
pub const FF_SWISS = 0x20;

pub const DT_RIGHT = 0x00000002;
pub const DT_VCENTER = 0x00000004;
pub const DT_SINGLELINE = 0x00000020;

pub const TRANSPARENT = 1;

pub const HKEY_CURRENT_USER: HKEY = @ptrFromInt(0x80000001);
pub const KEY_READ = 0x20019;
pub const RRF_RT_REG_DWORD = 0x00000010;
pub const REG_DWORD = 4;

pub const ERROR_ALREADY_EXISTS = 183;

pub const TPM_BOTTOMALIGN = 0x0020;
pub const TPM_LEFTALIGN = 0x0000;
pub const TPM_RIGHTBUTTON = 0x0002;
pub const TPM_NONOTIFY = 0x0080;
pub const TPM_RETURNCMD = 0x0100;

pub const MF_STRING = 0x00000000;
pub const MF_SEPARATOR = 0x00000800;

pub const ID_EXIT = 1001;

pub const COLOR_WINDOW = 5;

pub const PM_REMOVE = 0x0001;

pub const SRCCOPY: DWORD = 0x00CC0020;

// Structs
pub const GUID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

pub const MIB_IF_ROW2 = extern struct {
    InterfaceLuid: u64,
    InterfaceIndex: u32,
    InterfaceGuid: GUID,
    Alias: [257]u16,
    Description: [257]u16,
    PhysicalAddressLength: u32,
    PhysicalAddress: [32]u8,
    PermanentPhysicalAddress: [32]u8,
    Mtu: u32,
    Type: u32,
    TunnelType: u32,
    MediaType: u32,
    PhysicalMediumType: u32,
    AccessType: u32,
    DirectionType: u32,
    InterfaceAndOperStatusFlags: u32,
    OperStatus: u32,
    AdminStatus: u32,
    MediaConnectState: u32,
    NetworkGuid: GUID,
    ConnectionType: u32,
    TransmitLinkSpeed: u64,
    ReceiveLinkSpeed: u64,
    InOctets: u64,
    InUcastPkts: u64,
    InNUcastPkts: u64,
    InDiscards: u64,
    InErrors: u64,
    InUnknownProtos: u64,
    InUcastOctets: u64,
    InMulticastOctets: u64,
    InBroadcastOctets: u64,
    OutOctets: u64,
    OutUcastPkts: u64,
    OutNUcastPkts: u64,
    OutDiscards: u64,
    OutErrors: u64,
    OutUcastOctets: u64,
    OutMulticastOctets: u64,
    OutBroadcastOctets: u64,
    OutQLen: u64,
};

pub const MIB_IF_TABLE2 = extern struct {
    NumEntries: u32,
    pad: u32 = 0,
};

pub const NOTIFYICONDATAW = extern struct {
    cbSize: DWORD = @sizeOf(NOTIFYICONDATAW),
    hWnd: ?HWND = null,
    uID: UINT = 0,
    uFlags: UINT = 0,
    uCallbackMessage: UINT = 0,
    hIcon: ?HICON = null,
    szTip: [128]u16 = [_]u16{0} ** 128,
    dwState: DWORD = 0,
    dwStateMask: DWORD = 0,
    szInfo: [256]u16 = [_]u16{0} ** 256,
    uVersion_or_uTimeout: UINT = 0,
    szInfoTitle: [64]u16 = [_]u16{0} ** 64,
    dwInfoFlags: DWORD = 0,
    guidItem: GUID = .{ .Data1 = 0, .Data2 = 0, .Data3 = 0, .Data4 = .{0} ** 8 },
    hBalloonIcon: ?HICON = null,
};

pub const WNDCLASSEXW = extern struct {
    cbSize: UINT = @sizeOf(WNDCLASSEXW),
    style: UINT = 0,
    lpfnWndProc: ?*const fn (HWND, UINT, WPARAM, LPARAM) callconv(.winapi) LRESULT = null,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: ?HINSTANCE = null,
    hIcon: ?HICON = null,
    hCursor: ?HCURSOR = null,
    hbrBackground: ?HBRUSH = null,
    lpszMenuName: ?LPCWSTR = null,
    lpszClassName: ?LPCWSTR = null,
    hIconSm: ?HICON = null,
};

pub const MSG = extern struct {
    hwnd: ?HWND = null,
    message: UINT = 0,
    wParam: WPARAM = 0,
    lParam: LPARAM = 0,
    time: DWORD = 0,
    pt: POINT = .{ .x = 0, .y = 0 },
};

pub const PAINTSTRUCT = extern struct {
    hdc: ?HDC = null,
    fErase: BOOL = 0,
    rcPaint: RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 },
    fRestore: BOOL = 0,
    fIncUpdate: BOOL = 0,
    rgbReserved: [32]BYTE = [_]BYTE{0} ** 32,
};

pub const LOGFONTW = extern struct {
    lfHeight: LONG = 0,
    lfWidth: LONG = 0,
    lfEscapement: LONG = 0,
    lfOrientation: LONG = 0,
    lfWeight: LONG = 0,
    lfItalic: BYTE = 0,
    lfUnderline: BYTE = 0,
    lfStrikeOut: BYTE = 0,
    lfCharSet: BYTE = 0,
    lfOutPrecision: BYTE = 0,
    lfClipPrecision: BYTE = 0,
    lfQuality: BYTE = 0,
    lfPitchAndFamily: BYTE = 0,
    lfFaceName: [32]u16 = [_]u16{0} ** 32,
};

pub const CREATESTRUCTW = extern struct {
    lpCreateParams: ?*anyopaque,
    hInstance: ?HINSTANCE,
    hMenu: ?HMENU,
    hwndParent: ?HWND,
    cy: i32,
    cx: i32,
    y: i32,
    x: i32,
    style: LONG,
    lpszName: ?LPCWSTR,
    lpszClass: ?LPCWSTR,
    dwExStyle: DWORD,
};

// External Functions
pub extern "user32" fn RegisterClassExW(*const WNDCLASSEXW) callconv(.winapi) u16;
pub extern "user32" fn CreateWindowExW(DWORD, LPCWSTR, LPCWSTR, DWORD, i32, i32, i32, i32, ?HWND, ?HMENU, ?HINSTANCE, ?*anyopaque) callconv(.winapi) ?HWND;
pub extern "user32" fn ShowWindow(?HWND, i32) callconv(.winapi) BOOL;
pub extern "user32" fn UpdateWindow(?HWND) callconv(.winapi) BOOL;
pub extern "user32" fn GetMessageW(*MSG, ?HWND, UINT, UINT) callconv(.winapi) BOOL;
pub extern "user32" fn TranslateMessage(*const MSG) callconv(.winapi) BOOL;
pub extern "user32" fn DispatchMessageW(*const MSG) callconv(.winapi) LRESULT;
pub extern "user32" fn PostQuitMessage(i32) callconv(.winapi) void;
pub extern "user32" fn DefWindowProcW(HWND, UINT, WPARAM, LPARAM) callconv(.winapi) LRESULT;
pub extern "user32" fn SetTimer(?HWND, usize, UINT, ?*anyopaque) callconv(.winapi) usize;
pub extern "user32" fn KillTimer(?HWND, usize) callconv(.winapi) BOOL;
pub extern "user32" fn InvalidateRect(?HWND, ?*const RECT, BOOL) callconv(.winapi) BOOL;
pub extern "user32" fn BeginPaint(HWND, *PAINTSTRUCT) callconv(.winapi) ?HDC;
pub extern "user32" fn EndPaint(HWND, *const PAINTSTRUCT) callconv(.winapi) BOOL;
pub extern "user32" fn GetClientRect(?HWND, *RECT) callconv(.winapi) BOOL;
pub extern "user32" fn FindWindowW(?LPCWSTR, ?LPCWSTR) callconv(.winapi) ?HWND;
pub extern "user32" fn FindWindowExW(?HWND, ?HWND, ?LPCWSTR, ?LPCWSTR) callconv(.winapi) ?HWND;
pub extern "user32" fn GetWindowRect(?HWND, *RECT) callconv(.winapi) BOOL;
pub extern "user32" fn SetWindowPos(?HWND, ?HWND, i32, i32, i32, i32, UINT) callconv(.winapi) BOOL;
pub extern "user32" fn SetLayeredWindowAttributes(?HWND, COLORREF, BYTE, DWORD) callconv(.winapi) BOOL;
pub extern "user32" fn GetWindowLongW(?HWND, i32) callconv(.winapi) LONG;
pub extern "user32" fn SetWindowLongW(?HWND, i32, LONG) callconv(.winapi) LONG;
pub extern "user32" fn GetWindowLongPtrW(?HWND, i32) callconv(.winapi) LONG_PTR;
pub extern "user32" fn SetWindowLongPtrW(?HWND, i32, LONG_PTR) callconv(.winapi) LONG_PTR;
pub extern "user32" fn LoadIconW(?HINSTANCE, LPCWSTR) callconv(.winapi) ?HICON;
pub extern "user32" fn LoadCursorW(?HINSTANCE, LPCWSTR) callconv(.winapi) ?HCURSOR;
pub extern "user32" fn DestroyIcon(?HICON) callconv(.winapi) BOOL;
pub extern "user32" fn CreatePopupMenu() callconv(.winapi) ?HMENU;
pub extern "user32" fn AppendMenuW(?HMENU, UINT, usize, ?LPCWSTR) callconv(.winapi) BOOL;
pub extern "user32" fn TrackPopupMenu(?HMENU, UINT, i32, i32, i32, ?HWND, ?*const RECT) callconv(.winapi) BOOL;
pub extern "user32" fn DestroyMenu(?HMENU) callconv(.winapi) BOOL;
pub extern "user32" fn SetForegroundWindow(?HWND) callconv(.winapi) BOOL;
pub extern "user32" fn GetCursorPos(*POINT) callconv(.winapi) BOOL;
pub extern "user32" fn PeekMessageW(*MSG, ?HWND, UINT, UINT, UINT) callconv(.winapi) BOOL;
pub extern "user32" fn PostMessageW(?HWND, UINT, WPARAM, LPARAM) callconv(.winapi) BOOL;
pub extern "user32" fn GetDpiForWindow(?HWND) callconv(.winapi) UINT;
pub extern "user32" fn FillRect(?HDC, *const RECT, ?HBRUSH) callconv(.winapi) i32;
pub extern "user32" fn DrawTextW(?HDC, [*:0]const u16, i32, *RECT, UINT) callconv(.winapi) i32;

pub extern "shell32" fn Shell_NotifyIconW(DWORD, *NOTIFYICONDATAW) callconv(.winapi) BOOL;

pub extern "gdi32" fn CreateFontIndirectW(*const LOGFONTW) callconv(.winapi) ?HFONT;
pub extern "gdi32" fn SelectObject(?HDC, ?*anyopaque) callconv(.winapi) ?*anyopaque;
pub extern "gdi32" fn DeleteObject(?*anyopaque) callconv(.winapi) BOOL;
pub extern "gdi32" fn SetTextColor(?HDC, COLORREF) callconv(.winapi) COLORREF;
pub extern "gdi32" fn SetBkMode(?HDC, i32) callconv(.winapi) i32;
pub extern "gdi32" fn CreateSolidBrush(COLORREF) callconv(.winapi) ?HBRUSH;
pub extern "gdi32" fn CreateCompatibleDC(?HDC) callconv(.winapi) ?HDC;
pub extern "gdi32" fn CreateCompatibleBitmap(?HDC, i32, i32) callconv(.winapi) ?*anyopaque;
pub extern "gdi32" fn DeleteDC(?HDC) callconv(.winapi) BOOL;
pub extern "gdi32" fn BitBlt(?HDC, i32, i32, i32, i32, ?HDC, i32, i32, DWORD) callconv(.winapi) BOOL;

pub extern "kernel32" fn CreateMutexW(?*anyopaque, BOOL, LPCWSTR) callconv(.winapi) ?HANDLE;
pub extern "kernel32" fn GetLastError() callconv(.winapi) DWORD;
pub extern "kernel32" fn CloseHandle(HANDLE) callconv(.winapi) BOOL;
pub extern "kernel32" fn GetModuleHandleW(?LPCWSTR) callconv(.winapi) ?HINSTANCE;
pub extern "kernel32" fn QueryPerformanceCounter(*i64) callconv(.winapi) BOOL;
pub extern "kernel32" fn QueryPerformanceFrequency(*i64) callconv(.winapi) BOOL;

pub extern "advapi32" fn RegOpenKeyExW(HKEY, LPCWSTR, DWORD, DWORD, *?HKEY) callconv(.winapi) LSTATUS;
pub extern "advapi32" fn RegQueryValueExW(?HKEY, LPCWSTR, ?*DWORD, ?*DWORD, ?[*]BYTE, ?*DWORD) callconv(.winapi) LSTATUS;
pub extern "advapi32" fn RegCloseKey(?HKEY) callconv(.winapi) LSTATUS;

pub extern "iphlpapi" fn GetIfTable2(*?*MIB_IF_TABLE2) callconv(.winapi) DWORD;
pub extern "iphlpapi" fn FreeMibTable(?*anyopaque) callconv(.winapi) void;
pub extern "iphlpapi" fn GetBestInterface(dwDestAddr: u32, pdwBestIfIndex: *u32) callconv(.winapi) DWORD;
