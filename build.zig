const std = @import("std");

pub fn build(b: *std.Build) void {
    const out_dir = "build";

    const cwd = std.fs.cwd();
    _ = cwd.makeDir(out_dir) catch {};

    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86, .os_tag = .freestanding } });
    const optimize = b.standardOptimizeOption(.{});

    const drivers_mod = b.createModule(.{
        .root_source_file = b.path("src/drivers/mod.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kernel_exe = b.addExecutable(.{
        .name = "kfs.bin",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/kernel/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    kernel_exe.is_linking_libc = false;
    kernel_exe.root_module.addImport("drivers", drivers_mod);
    kernel_exe.setLinkerScript(b.path("linker.ld"));
    kernel_exe.addAssemblyFile(b.path("src/arch/i386/boot.s"));

    const install_kernel = b.addInstallFile(kernel_exe.*.getEmittedBin(), "iso/boot/kfs.bin");
    const install_step = b.step("install_kern", "Install kernel to iso/ dir");
    install_step.dependOn(&install_kernel.step);

    const iso_cmd = b.addSystemCommand(&[_][]const u8{
        "grub-mkrescue",
        "-o",
        out_dir ++ "/kfs.iso",
        "iso",
    });
    iso_cmd.step.dependOn(install_step);
    b.default_step.dependOn(&iso_cmd.step);

    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "qemu-system-i386",
        "-m",
        "128M",
        "-cdrom",
        "build/kfs.iso",
        "-serial",
        "stdio",
    });
    run_cmd.step.dependOn(&iso_cmd.step);

    const run_step = b.step("run", "Run the kernel in QEMU");
    run_step.dependOn(&run_cmd.step);
}
