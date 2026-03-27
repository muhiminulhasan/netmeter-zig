const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .os_tag = .windows,
        },
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = true,
        .single_threaded = true,
        .unwind_tables = .none,
    });

    const exe = b.addExecutable(.{
        .name = "netmeter",
        .root_module = module,
    });

    exe.subsystem = .Windows;

    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("advapi32");
    exe.linkSystemLibrary("iphlpapi");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the network meter");
    run_step.dependOn(&run_cmd.step);
}
