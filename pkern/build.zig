const std = @import("std");

pub fn build(b: *std.Build) void {
    const out_dir = "build";

    const cwd = std.fs.cwd();
    _ = cwd.makeDir(out_dir) catch {};

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const drivers_mod = b.createModule(.{
        .root_source_file = b.path("src/drivers/mod.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/kernel/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    kernel_mod.addImport("drivers", drivers_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "pkern",
        .root_module = drivers_mod,
    });
    b.installArtifact(lib);

    const kernel_exe = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_mod,
    });
    b.installArtifact(kernel_exe);

    const asm_cmd = b.addSystemCommand(&[_][]const u8{
        "nasm",
        "-f", "elf32",
        "src/arch/i386/boot.asm",
        "-o", out_dir ++ "/boot.o",
    });
    asm_cmd.step.dependOn(&kernel_exe.step);

    const link_cmd = b.addSystemCommand(&[_][]const u8{
        "ld",
        "-m", "elf_i386",
        "-T", "linker.ld",
        "-o", out_dir ++ "/kfs.bin",
        out_dir ++ "/boot.o",
        out_dir ++ "/kernel.o",
    });
    link_cmd.step.dependOn(&asm_cmd.step);

    const iso_cmd = b.addSystemCommand(&[_][]const u8{
        "grub-mkrescue",
        "-o",
        out_dir ++ "/kfs.iso",
        "iso",
    });
    iso_cmd.step.dependOn(&link_cmd.step);

    b.default_step.dependOn(&iso_cmd.step);

    const run_cmd = b.addRunArtifact(kernel_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}
