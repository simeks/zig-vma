# Vulkan Memory Allocator

Rough Zig build system setup for [Vulkan Memory Allocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator). Builds VMA and provides a Zig module of the auto-translated header file.

## Usage

Outline on how to use with [vulkan-zig](https://github.com/Snektron/vulkan-zig).

### `build.zig.zon`

```zig
{
    .vma = .{
        .url = "git+https://github.com/simeks/zig-vma.git?ref=master#<commit>",
    },
}
```

### `build.zig`

```zig
const vma_dep = b.dependency("vma", .{});
exe.root_module.addImport("vma", vma_dep.module("vma"));
```

### `main.zig`

```zig
const vk = @import("vulkan");
const vma = @import("vma");

// Setup vulkan-zig dispatchs
const apis: []const vk.ApiInfo = &.{};

pub const BaseWrapper = vk.BaseWrapper(apis);
pub const InstanceWrapper = vk.InstanceWrapper(apis);

pub const Instance = vk.InstanceProxy(apis);
pub const Device = vk.DeviceProxy(apis);

pub fn main() !void {
    // Your Vulkan initialization here
    const base_wrapper: BaseWrapper;
    const instance_wrapper: InstanceWrapper;

    const vma_funcs: vma.VmaVulkanFunctions = .{
        .vkGetInstanceProcAddr = @ptrCast(base_wrapper.dispatch.vkGetInstanceProcAddr),
        .vkGetDeviceProcAddr = @ptrCast(instance_wrapper.dispatch.vkGetDeviceProcAddr),
    };

    const physical_device: vk.PhysicalDevice;
    const instance: Instance;
    const device: Device;

    const vma_allocator_info: vma.VmaAllocatorCreateInfo = .{
        .physicalDevice = @ptrFromInt(@intFromEnum(physical_device)),
        .device = @ptrFromInt(@intFromEnum(device.handle)),
        .instance = @ptrFromInt(@intFromEnum(instance.handle)),
        .pVulkanFunctions = &vma_funcs,
    };

    var allocator: vma.VmaAllocator = undefined;
    const res = vma.vmaCreateAllocator(&vma_allocator_info, &allocator);
    if (res != vma.VK_SUCCESS) {
        return error.VmaInitFailed;
    }

    const buffer_create_info: vk.BufferCreateInfo = .{};

    const allocation_create_info: vma.VmaAllocationCreateInfo = .{
        .usage = vma.VMA_MEMORY_USAGE_AUTO,
        .flags = vma.VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT,
    };

    var buffer: vk.Buffer = undefined;
    var allocation: vma.VmaAllocation = undefined;
    const res = vma.vmaCreateBuffer(
        self.allocator,
        @ptrCast(&buffer_create_info),
        &allocation_create_info,
        @ptrCast(&buffer),
        &allocation,
        null,
    );
    if (res != vma.VK_SUCCESS) {
        return error.VmaCreateBufferFailed;
    }
}
```




