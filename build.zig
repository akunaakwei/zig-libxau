const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const xau_dep = b.dependency("xau", .{});
    const xorgproto_dep = b.dependency("xorgproto", .{
        .target = target,
        .optimize = optimize,
    });
    const xorgproto = xorgproto_dep.artifact("xorgproto");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = if (linkage == .dynamic) true else null,
    });
    mod.linkLibrary(xorgproto);
    mod.addIncludePath(xau_dep.path("include"));
    mod.addCSourceFiles(.{
        .root = xau_dep.path("."),
        .files = &sources,
    });

    const lib = b.addLibrary(.{
        .name = "xau",
        .root_module = mod,
        .linkage = linkage,
    });
    lib.installHeadersDirectory(xau_dep.path("include"), ".", .{});
    b.installArtifact(lib);
}

const sources = .{
    "AuDispose.c",
    "AuFileName.c",
    "AuGetAddr.c",
    "AuGetBest.c",
    "AuLock.c",
    "AuRead.c",
    "AuUnlock.c",
    "AuWrite.c",
};
