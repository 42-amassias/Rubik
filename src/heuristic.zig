const std = @import("std");

const Cube = @import("cube.zig").Cube;

pub fn HeuristicDB(comptime T: type) type {
	return struct {
		const Self = @This();

		const HashMap = std.AutoHashMap(T.CubeFaces, i32);

		allocator: std.mem.Allocator,
		data: HashMap,

		pub fn init(allocator: std.mem.Allocator) Self {
			return .{
				.allocator = allocator,
				.data = HashMap.init(allocator),
			};
		}

		pub fn deinit(self: *Self) void {
			self.data.deinit();
		}
	};
}


