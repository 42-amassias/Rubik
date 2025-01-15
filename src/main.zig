const std = @import("std");

const cube = @import("cube.zig");

const Rubik = cube.Cube(3);

pub fn main() !void {
	const stdout_file = std.io.getStdOut().writer();
	var bw = std.io.bufferedWriter(stdout_file);
	const stdout = bw.writer();

	var c = Rubik.init();

	try stdout.print("{any}\n", .{c});
	c.exec_right(false);
	c.exec_up(true);
	c.exec_up(true);
	c.exec_right(true);
	c.exec_up(true);
	c.exec_right(false);
	c.exec_up(true);
	c.exec_right(true);
	try stdout.print("{any}\n", .{c});

	try bw.flush();
}
