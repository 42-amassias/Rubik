const std = @import("std");

const cube = @import("cube.zig");
const heuristic = @import("heuristic.zig");

const Rubik = cube.Cube(3);

const Heuristic = heuristic.HeuristicDB(Rubik);

pub fn main() !void {
	const stdout_file = std.io.getStdOut().writer();
	const stdin_file = std.io.getStdIn().reader();
	var bw = std.io.bufferedWriter(stdout_file);
	var br = std.io.bufferedReader(stdin_file);
	const stdout = bw.writer();
	const stdin = br.reader();

	// var c = Rubik.init();

	// try stdout.print("{any}\n", .{c});
	// const t = std.time.microTimestamp();
	// const op = 200000;
	// for (0..op/8) |_| {
	// 	c.exec_right(0, false);
	// 	c.exec_movement(Rubik.Movement.init(.RIGHT, true, 0));
	// 	c.exec_movement(Rubik.Movement.init(.RIGHT, false, 0));
	// 	c.exec_up(0, true);
	// 	c.exec_up(0, true);
	// 	c.exec_right(0, true);
	// 	c.exec_up(0, true);
	// 	c.exec_right(0, false);
	// 	c.exec_up(0, true);
	// 	c.exec_right(0, true);
	// }
	// try stdout.print("{d} op/s\n", .{op / (@as(f64, @floatFromInt(std.time.microTimestamp() - t)) / 1000000.0)});
	// try stdout.print("{any}\n", .{c});
	// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	// defer arena.deinit();
	// const allocator = arena.allocator();

	// var db = Heuristic.init(allocator);
	// defer db.deinit();

	// const ttt = try Rubik.Movement.from_string("R2'");

	// std.debug.print("{s}\n", .{try ttt.to_string()});

	var c = Rubik.init();

	var buffer: [8]u8 = undefined;

	while (true) {
		// TODO stream too long
		const str = try stdin.readUntilDelimiterOrEof(&buffer, '\n') orelse break;
		const move = Rubik.Movement.from_string(str) catch {
			std.debug.print("Bad format : {s}\n", .{str});
			continue ;
		};
		c.exec_movement(move);


		try stdout.print("executed command : {}\n", .{move});
		try stdout.print("{}\n", .{c});

		try bw.flush();
	}


	try bw.flush();
}
