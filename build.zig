const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const unit_test = b.addTest(.{
		.root_source_file = b.path("src/test.zig"),
		.target = target,
		.optimize = optimize,
	});

	const exe = b.addExecutable(.{
		.name = "rubik",
		.root_source_file = b.path("src/main.zig"),
		.target = target,
		.optimize = optimize,
	});

	b.installArtifact(exe);

	const run_test = b.addRunArtifact(unit_test);

	const run_cmd = b.addRunArtifact(exe);

	// Allow passing args via `zig build run -- arg1 arg2`
	if (b.args) |args| {
		run_cmd.addArgs(args);
	}

	const run_step = b.step("run", "Run the truc");
	const test_step = b.step("test", "Run the unit testing");
	run_step.dependOn(&run_cmd.step);
	test_step.dependOn(&run_test.step);
}
