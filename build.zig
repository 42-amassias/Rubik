const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const exe = b.addExecutable(.{
		.name = "rubik",
		.root_source_file = b.path("src/main.zig"),
		.target = target,
		.optimize = optimize,
	});

	b.installArtifact(exe);

	const run_cmd = b.addRunArtifact(exe);

	// Allow passing args via `zig build run -- arg1 arg2`
	if (b.args) |args| {
		run_cmd.addArgs(args);
	}

	const run_step = b.step("run", "Run the truc");
	run_step.dependOn(&run_cmd.step);
}
