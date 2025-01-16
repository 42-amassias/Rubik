const std = @import("std");

pub fn Cube(comptime n: u8) type {
	return struct {
		const Self = @This();

		pub const face_count: u32 = 6 * @as(u32, n) * @as(u32, n);

		pub const PackedCube = [(@bitSizeOf(@typeInfo(Color).Enum.tag_type) * face_count + 7) / 8]u8;
		pub const CubeFaces = [6][n][n]Color;

		pub const Color = enum(u3) {
			WHITE,	// UP
			GREEN,	// LEFT
			RED,	// FRONT
			BLUE,	// RIGHT
			ORANGE,	// BACK
			YELLOW,	// DOWN

			pub fn format(self: Color, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
				switch (self) {
					.WHITE => try writer.writeAll("W"),
					.GREEN => try writer.writeAll("G"),
					.RED => try writer.writeAll("R"),
					.BLUE => try writer.writeAll("B"),
					.ORANGE => try writer.writeAll("O"),
					.YELLOW => try writer.writeAll("Y"),
				}
			}
		};

		pub const FaceSide = enum(u8) {
			UP,
			LEFT,
			FRONT,
			RIGHT,
			BACK,
			DOWN,
		};

		pub const Movement = struct {
			pub const MovementSide = enum {
				UP,
				LEFT,
				FRONT,
				RIGHT,
				BACK,
				DOWN,
				MHOR, // MIDDLE HORIZONTAL
				MVER, // MIDDLE VERTICAL
				MTRA, // MIDDLE TRANSVERSAL
			};

			pub const FormatError = error {
				BadFormat,
			};

			revert: bool,
			side: MovementSide,
			shift: u7,

			const MAX_MOVEMENT_STRING_SIZE = 5;

			pub fn init(_side: MovementSide, _revert: bool, _shift: u7) Movement {
				return .{
					.revert = _revert,
					.side = _side,
					.shift = _shift,
				};
			}

			pub fn from_string(str: []const u8) FormatError!Movement {
				if (str.len < 1) return FormatError.BadFormat;
				const char = str[0];
				const revert = str[str.len - 1] == '\'';
				const shift = if (str.len - @intFromBool(revert) <= 1) 0 else std.fmt.parseInt(u7, str[1..str.len - @intFromBool(revert)], 10) catch return FormatError.BadFormat;
				return Movement.init(switch (char) {
					'U' => .UP,
					'L' => .LEFT,
					'F' => .FRONT,
					'R' => .RIGHT,
					'B' => .BACK,
					'D' => .DOWN,
					'E' => .MHOR,
					'M' => .MVER,
					'S' => .MTRA,
					else => return FormatError.BadFormat,
				}, revert, shift);
			}

			pub fn read(reader: anytype) !Movement {
				const char: u8 = try reader.readByte();
				const shift = try reader.readInt();
				std.debug.print("c : {s} shift : {d}", .{char, shift});
				return Movement.init(.BACK, false, 0);
			}

			fn to_char(self: Movement) u8 {
				return switch (self.side) {
					.UP => 'U',
					.LEFT => 'L',
					.FRONT => 'F',
					.RIGHT => 'R',
					.BACK => 'B',
					.DOWN => 'D',
					.MHOR => 'E',
					.MVER => 'M',
					.MTRA => 'S',
				};
			}

			// THIS RETURN A POINTER TO THE STACKFRAME AND THIS IS BROKEN OBVIOUSLY
			pub fn to_string(self: Movement) ![]u8 {
				var buffer: [MAX_MOVEMENT_STRING_SIZE]u8 = undefined;
				return if (self.shift == 0) try std.fmt.bufPrint(std.mem.asBytes(&buffer), "{c}{s}", .{
					self.to_char(),
					if (self.revert) "'" else "",
				})
				else try std.fmt.bufPrint(std.mem.asBytes(&buffer), "{c}{d}{s}", .{
					self.to_char(),
					self.shift,
					if (self.revert) "'" else "",
				});
			}

			pub fn write(self: Movement, writer: anytype) !void {
				try writer.writeByte(self.to_char());
				if (self.shift != 0) try writer.print("{d}", .{self.shift});
				if (self.revert) try writer.writeAll("'");
			}

			pub fn format(self: Movement, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
				try self.write(writer);
			}
		};

		const solved_state = CubeFaces{
			.{.{Color.WHITE} ** n} ** n,
			.{.{Color.GREEN} ** n} ** n,
			.{.{Color.RED} ** n} ** n,
			.{.{Color.BLUE} ** n} ** n,
			.{.{Color.ORANGE} ** n} ** n,
			.{.{Color.YELLOW} ** n} ** n,
		};
		const orientation_ref: [3][3]i2 = .{.{0, 1, 0}, .{1, 0, 0},.{0, 0, 1}};

		cube_faces: CubeFaces = solved_state,
		orientation: [3][3]i2 = orientation_ref,

		pub fn init() Self {
			return .{
			};
		}

		pub fn deinit(self: *Self) void {
			std.debug.print("{any}", .{self.cube_faces});
		}


		pub fn as_linear_face(self: *Self) *[face_count]Color {
			return @as(*[face_count]Color, @ptrCast(&self.cube_faces));
		}

		pub fn cas_linear_face(self: Self) *const [face_count]Color {
			return @as(*const [face_count]Color, @ptrCast(&self.cube_faces));
		}

		pub fn unpack(packed_cube: PackedCube) Self {
			var self = Self.init();
			const FaceType = @typeInfo(Color).Enum.tag_type;
			var bit_offset: usize = 0;
			// linear raw array of the cube faces
			for (@as(*[face_count]FaceType, @ptrCast(self.as_linear_face()))) |*face| {
				face.* = std.mem.readPackedIntNative(FaceType, &packed_cube, bit_offset);
				bit_offset += @bitSizeOf(FaceType);
			}
			return self;
		}

		pub fn pack(self: Self) PackedCube {
			return pack_cube_faces(self.cube_faces);
		}

		pub fn pack_cube_faces(cf: CubeFaces) PackedCube {
			var packed_cube: PackedCube = undefined;
			const FaceType = @typeInfo(Color).Enum.tag_type;
			var bit_offset: usize = 0;
			// linear raw array of the cube faces
			const linear_face = @as(*const [face_count]FaceType, @ptrCast(&cf));
			for (linear_face.*) |face|
			{
				std.mem.writePackedIntNative(FaceType, &packed_cube, bit_offset, face);
				bit_offset += @bitSizeOf(FaceType);
			}
			return packed_cube;
		}

		pub fn solved(self: Self) bool {
			for (0..6) |s| {
				const color = self.cube_faces[s][0][0];
				for (0..n) |h| {
					for (0..n) |w| {
						if (self.cube_faces[s][h][w] != color) return false;
					}
				}
			}
			return true;
		}

		fn direction_to_side(orientation: [3]i2) FaceSide {
			if (orientation[0] == 1) return FaceSide.FRONT;
			if (orientation[0] == -1) return FaceSide.BACK;
			if (orientation[1] == 1) return FaceSide.UP;
			if (orientation[1] == -1) return FaceSide.DOWN;
			if (orientation[2] == 1) return FaceSide.RIGHT;
			if (orientation[2] == -1) return FaceSide.LEFT;
			unreachable ;
		}

		pub fn rel_to_abs_side(self: Self, dir: FaceSide) FaceSide {
			return switch (dir) {
				.UP => self.relative_up(),
				.DOWN => self.relative_down(),
				.FRONT => self.relative_front(),
				.BACK => self.relative_back(),
				.RIGHT => self.relative_right(),
				.LEFT => self.relative_left(),
			};
		}

		pub fn relative_up(self: Self) FaceSide {
			return direction_to_side(self.orientation[0]);
		}
		pub fn relative_down(self: Self) FaceSide {
			return direction_to_side(.{-self.orientation[0][0], -self.orientation[0][1], -self.orientation[0][2]});
		}
		pub fn relative_front(self: Self) FaceSide {
			return direction_to_side(self.orientation[1]);
		}
		pub fn relative_back(self: Self) FaceSide {
			return direction_to_side(.{-self.orientation[1][0], -self.orientation[1][1], -self.orientation[1][2]});
		}
		pub fn relative_right(self: Self) FaceSide {
			return direction_to_side(self.orientation[2]);
		}
		pub fn relative_left(self: Self) FaceSide {
			return direction_to_side(.{-self.orientation[2][0], -self.orientation[2][1], -self.orientation[2][2]});
		}

		/// Describe a line movement
		const LineMovement = struct {
			face: FaceSide,
			start: [2]u8,
			inc: [2]i2,
			/// inc2 is for the edges move for 4x4 5x5 6x6...
			inc2: [2]i2,
		};

		// The absolutes movements

		const up_line_movement = [4]LineMovement{
			.{.face = FaceSide.LEFT,	.start = .{0, 0}, .inc = .{0, 1}, .inc2 = .{1, 0}},
			.{.face = FaceSide.BACK,	.start = .{0, 0}, .inc = .{0, 1}, .inc2 = .{1, 0}},
			.{.face = FaceSide.RIGHT,	.start = .{0, 0}, .inc = .{0, 1}, .inc2 = .{1, 0}},
			.{.face = FaceSide.FRONT,	.start = .{0, 0}, .inc = .{0, 1}, .inc2 = .{1, 0}},
		};
		const left_line_movement = [4]LineMovement{
			.{.face = FaceSide.UP, .start = .{0, 0}, .inc = .{1, 0}, .inc2 = .{0, 1}},
			.{.face = FaceSide.BACK, .start = .{n - 1, n - 1}, .inc = .{-1, 0}, .inc2 = .{0, -1}},
			.{.face = FaceSide.DOWN, .start = .{0, 0}, .inc = .{1, 0}, .inc2 = .{0, 1}},
			.{.face = FaceSide.FRONT, .start = .{0, 0}, .inc = .{1, 0}, .inc2 = .{0, 1}},
		};
		const front_line_movement = [4]LineMovement{
			.{.face = FaceSide.UP,	.start = .{n - 1, 0}, .inc = .{0, 1}, .inc2 = .{-1, 0}},
			.{.face = FaceSide.RIGHT,	.start = .{0, 0}, .inc = .{1, 0}, .inc2 = .{0, 1}},
			.{.face = FaceSide.DOWN,	.start = .{0, n - 1}, .inc = .{0, -1}, .inc2 = .{1, 0}},
			.{.face = FaceSide.LEFT,	.start = .{n - 1, n - 1}, .inc = .{-1, 0}, .inc2 = .{0, -1}},
		};
		const right_line_movement = [4]LineMovement{
			.{.face = FaceSide.UP, .start = .{0, n - 1}, .inc = .{1, 0}, .inc2 = .{0, -1}},
			.{.face = FaceSide.BACK, .start = .{n - 1, 0}, .inc = .{-1, 0}, .inc2 = .{0, 1}},
			.{.face = FaceSide.DOWN, .start = .{0, n - 1}, .inc = .{1, 0}, .inc2 = .{0, -1}},
			.{.face = FaceSide.FRONT, .start = .{0, n - 1}, .inc = .{1, 0}, .inc2 = .{0, -1}},
		};
		const back_line_movement = [4]LineMovement{
			.{.face = FaceSide.UP,	.start = .{0, 0}, .inc = .{0, 1}, .inc2 = .{1, 0}},
			.{.face = FaceSide.RIGHT,	.start = .{0, n - 1}, .inc = .{1, 0}, .inc2 = .{0, -1}},
			.{.face = FaceSide.DOWN,	.start = .{n - 1, n - 1}, .inc = .{0, -1}, .inc2 = .{-1, 0}},
			.{.face = FaceSide.LEFT,	.start = .{n - 1, 0}, .inc = .{-1, 0}, .inc2 = .{0, 1}},
		};
		const down_line_movement = [4]LineMovement{
			.{.face = FaceSide.LEFT,	.start = .{n - 1, 0}, .inc = .{0, 1}, .inc2 = .{-1, 0}},
			.{.face = FaceSide.FRONT,	.start = .{n - 1, 0}, .inc = .{0, 1}, .inc2 = .{-1, 0}},
			.{.face = FaceSide.RIGHT,	.start = .{n - 1, 0}, .inc = .{0, 1}, .inc2 = .{-1, 0}},
			.{.face = FaceSide.BACK,	.start = .{n - 1, 0}, .inc = .{0, 1}, .inc2 = .{-1, 0}},
		};

		const movements: [6][4]LineMovement = .{
			up_line_movement,
			left_line_movement,
			front_line_movement,
			right_line_movement,
			back_line_movement,
			down_line_movement,
		};

		fn exec_line_movement(self: *Self, movement: [4]LineMovement, shift: u8, revert: bool) void {
			const old_cube_faces = self.cube_faces;
			inline for (0..4) |k| {
				const mov1 = movement[k];
				const mov2 = movement[(k + 1) % 4];
				var pos1 = mov1.start;
				var pos2 = mov2.start;
				// apply shifting
				pos1[0] = @truncate(@as(u16, @bitCast(@as(i16, pos1[0]) + @as(i16, mov1.inc2[0]) * shift)));
				pos1[1] = @truncate(@as(u16, @bitCast(@as(i16, pos1[1]) + @as(i16, mov1.inc2[1]) * shift)));
				pos2[0] = @truncate(@as(u16, @bitCast(@as(i16, pos2[0]) + @as(i16, mov2.inc2[0]) * shift)));
				pos2[1] = @truncate(@as(u16, @bitCast(@as(i16, pos2[1]) + @as(i16, mov2.inc2[1]) * shift)));
				for (0..n) |_| {
					if (!revert) self.cube_faces[@intFromEnum(self.rel_to_abs_side(mov2.face))][pos2[0]][pos2[1]] = old_cube_faces[@intFromEnum(self.rel_to_abs_side(mov1.face))][pos1[0]][pos1[1]]
					else self.cube_faces[@intFromEnum(self.rel_to_abs_side(mov1.face))][pos1[0]][pos1[1]] = old_cube_faces[@intFromEnum(self.rel_to_abs_side(mov2.face))][pos2[0]][pos2[1]];
					pos1[0] = @truncate(@as(u16, @bitCast(@as(i16, pos1[0]) + mov1.inc[0])));
					pos1[1] = @truncate(@as(u16, @bitCast(@as(i16, pos1[1]) + mov1.inc[1])));
					pos2[0] = @truncate(@as(u16, @bitCast(@as(i16, pos2[0]) + mov2.inc[0])));
					pos2[1] = @truncate(@as(u16, @bitCast(@as(i16, pos2[1]) + mov2.inc[1])));
				}
			}
		}

		fn rotate_side(self: *Self, side: FaceSide, revert: bool) void {
			const old_cube_faces = self.cube_faces;
			for (0..n) |h| {
				for (0..n) |w| {
					const nw = n - 1 - h;
					const nh = w;
					if (!revert) self.cube_faces[@intFromEnum(side)][nh][nw] = old_cube_faces[@intFromEnum(side)][h][w]
					else self.cube_faces[@intFromEnum(side)][h][w] = old_cube_faces[@intFromEnum(side)][nh][nw];
				}
			}
		}

		pub fn exec_movement(self: *Self, move: Movement) void {
			if ((move.side == .MHOR or move.side == .MVER or move.side == .MTRA) and n % 2 == 0) unreachable;
			self.exec_rel(switch (move.side) {
				.UP		=> FaceSide.UP,
				.LEFT	=> FaceSide.LEFT,
				.FRONT	=> FaceSide.FRONT,
				.RIGHT	=> FaceSide.RIGHT,
				.BACK	=> FaceSide.BACK,
				.DOWN	=> FaceSide.DOWN,
				.MHOR	=> unreachable,
				.MVER	=> unreachable,
				.MTRA	=> unreachable,
			}, move.shift, move.revert);
		}

		fn exec_rel(self: *Self, side: FaceSide, shift: u7, revert: bool) void {
			const abs_side = self.rel_to_abs_side(side);
			// Rotate the face if needed
			if (shift == 0) self.rotate_side(abs_side, revert);
			// Line movement
			self.exec_line_movement(movements[@intFromEnum(abs_side)], shift, revert);
		}

		pub fn exec_up(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.UP, shift, revert);
		}

		pub fn exec_left(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.LEFT, shift, revert);
		}

		pub fn exec_front(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.FRONT, shift, revert);
		}

		pub fn exec_right(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.RIGHT, shift, revert);
		}

		pub fn exec_back(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.BACK, shift, revert);
		}

		pub fn exec_down(self: *Self, shift: u7, revert: bool) void {
			self.exec_rel(FaceSide.DOWN, shift, revert);
		}

		pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
			for (0..n) |h| {
				for (0..6) |f| {
					for (0..n) |w| {
						try writer.print("{}", .{self.cube_faces[f][h][w]});
					}
					try writer.writeAll(" ");
				}
				try writer.writeAll("\n");
			}
			try writer.print("Solved state : {}\n", .{self.solved()});
		}
	};
}

const expect = std.testing.expect;

test "basic 2x2 Rubik's cube test" {
	const Rubik = Cube(2);
	var cube = Rubik.init();
	try expect(cube.solved());
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_up(true);
	cube.exec_right(true);
	cube.exec_up(true);
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_right(true);
	try expect(!cube.solved());
	const packed_cube = cube.pack();
	const copied_cube = Rubik.unpack(packed_cube);
	try expect(std.mem.eql(Rubik.Color, cube.cas_linear_face(), copied_cube.cas_linear_face()));
	for (0..5) |_| {
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_up(true);
		cube.exec_right(true);
		cube.exec_up(true);
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_right(true);
	}
	try expect(cube.solved());
}

test "basic 3x3 Rubik's cube test" {
	const Rubik = Cube(3);
	var cube = Rubik.init();
	try expect(cube.solved());
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_up(true);
	cube.exec_right(true);
	cube.exec_up(true);
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_right(true);
	try expect(!cube.solved());
	const packed_cube = cube.pack();
	const copied_cube = Rubik.unpack(packed_cube);
	try expect(std.mem.eql(Rubik.Color, cube.cas_linear_face(), copied_cube.cas_linear_face()));
	for (0..5) |_| {
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_up(true);
		cube.exec_right(true);
		cube.exec_up(true);
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_right(true);
	}
	try expect(cube.solved());
}

test "basic 4x4 Rubik's cube test" {
	const Rubik = Cube(4);
	var cube = Rubik.init();
	try expect(cube.solved());
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_up(true);
	cube.exec_right(true);
	cube.exec_up(true);
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_right(true);
	try expect(!cube.solved());
	const packed_cube = cube.pack();
	const copied_cube = Rubik.unpack(packed_cube);
	try expect(std.mem.eql(Rubik.Color, cube.cas_linear_face(), copied_cube.cas_linear_face()));
	for (0..5) |_| {
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_up(true);
		cube.exec_right(true);
		cube.exec_up(true);
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_right(true);
	}
	try expect(cube.solved());
}

test "basic 7x7 Rubik's cube test" {
	const Rubik = Cube(7);
	var cube = Rubik.init();
	try expect(cube.solved());
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_up(true);
	cube.exec_right(true);
	cube.exec_up(true);
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_right(true);
	try expect(!cube.solved());
	const packed_cube = cube.pack();
	const copied_cube = Rubik.unpack(packed_cube);
	try expect(std.mem.eql(Rubik.Color, cube.cas_linear_face(), copied_cube.cas_linear_face()));
	for (0..5) |_| {
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_up(true);
		cube.exec_right(true);
		cube.exec_up(true);
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_right(true);
	}
	try expect(cube.solved());
}

test "hard Rubik's cube test" {
	const Rubik = Cube(250);
	var cube = Rubik.init();
	try expect(cube.solved());
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_up(true);
	cube.exec_right(true);
	cube.exec_up(true);
	cube.exec_right(false);
	cube.exec_up(true);
	cube.exec_right(true);
	try expect(!cube.solved());
	const packed_cube = cube.pack();
	const copied_cube = Rubik.unpack(packed_cube);
	try expect(std.mem.eql(Rubik.Color, cube.cas_linear_face(), copied_cube.cas_linear_face()));
	for (0..5) |_| {
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_up(true);
		cube.exec_right(true);
		cube.exec_up(true);
		cube.exec_right(false);
		cube.exec_up(true);
		cube.exec_right(true);
	}
	try expect(cube.solved());
}
