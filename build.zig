const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vk_dep = b.dependency("vulkan_headers", .{});
    const vma_dep = b.dependency("vma", .{});

    const lib = b.addLibrary(.{
        .name = "VulkanMemoryAllocator",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    lib.root_module.addCSourceFile(.{
        .file = b.path("vk_mem_alloc.cpp"),
        .flags = &.{
            "--std=c++17",
            "-DVMA_STATIC_VULKAN_FUNCTIONS=0",
            "-DVMA_DYNAMIC_VULKAN_FUNCTIONS=1",
        },
    });
    lib.root_module.addIncludePath(vma_dep.path("include"));
    lib.root_module.addIncludePath(vk_dep.path("include"));
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
