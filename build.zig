const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vk_dep = b.dependency("vulkan_headers", .{});
    const vma_dep = b.dependency("vma", .{});

    const lib = b.addStaticLibrary(.{
        .name = "VulkanMemoryAllocator",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    lib.addCSourceFile(.{
        .file = b.path("vk_mem_alloc.cpp"),
        .flags = &.{
            "--std=c++17",
            "-DVMA_STATIC_VULKAN_FUNCTIONS=0",
            "-DVMA_DYNAMIC_VULKAN_FUNCTIONS=1",
        },
    });
    lib.addIncludePath(vma_dep.path("include"));
    lib.addIncludePath(vk_dep.path("include"));
    lib.installHeadersDirectory(vma_dep.path("include"), "", .{});
    b.installArtifact(lib);

    const translate = b.addTranslateC(.{
        .root_source_file = vma_dep.path("include/vk_mem_alloc.h"),
        .target = target,
        .optimize = optimize,
    });
    translate.addIncludePath(vma_dep.path("include"));
    translate.addIncludePath(vk_dep.path("include"));

    const module = translate.addModule("vma");
    module.linkLibrary(lib);
}
