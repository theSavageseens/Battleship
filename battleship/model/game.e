note
	description: "Summary description for {GAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GAME

inherit
	ANY
		redefine
			out
		end

create
	make

feature -- random generators

	rand_gen: RANDOM_GENERATOR
			-- random generator for normal mode
			-- it's important to keep this as an attribute
		attribute
			create result.make_random
		end

	debug_gen: RANDOM_GENERATOR
			-- deterministic generator for debug mode
			-- it's important to keep this as an attribute
		attribute
			create result.make_debug
		end

feature -- attributes

	board: ARRAY2[SHIP_ALPHABET]

	row_indices : ARRAY[CHARACTER]
		once
			Result := <<'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'>>
		end

	shots_time : INTEGER

	shots_upper : INTEGER

	bombs_time : INTEGER

	bombs_upper : INTEGER

	ships : ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]]

	is_debug: BOOLEAN

feature -- history
 	history: HISTORY

feature --faker_attributes

	score_time : INTEGER
	do
		across ships as ship loop
			if
				check_sunk(ship.item)
			then
				Result := Result+ship.item.size
			end
		end
	end

	score_upper : INTEGER
	do
		across ships as ship loop
				Result:=Result+ship.item.size
		end
	end

	ships_time : INTEGER
	do
		across ships as ship loop
			if
				check_sunk(ship.item)
			then
				Result:=Result+1
			end
		end
	end

	ships_upper : INTEGER
	do
		Result:=ships.count
	end

feature -- creation

	make(is_debug_mode: BOOLEAN; board_size:INTEGER; shots_limit:INTEGER; bombs_limit: INTEGER; num_ships: INTEGER)
		do
			create history.make
			create board.make_filled (create {SHIP_ALPHABET}.make ('_'), board_size, board_size)
			shots_time := 0
			shots_upper := shots_limit
			bombs_time := 0
			bombs_upper := bombs_limit
			ships := generate_ships(is_debug_mode,board_size,num_ships)
			is_debug := is_debug_mode
			if
				is_debug_mode
			then
				place_new_ships(ships)
			end
		end

feature -- utilities

	generate_ships (is_debug_mode: BOOLEAN; board_size: INTEGER; num_ships: INTEGER): ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]]
			-- places the ships on the board
			-- either deterministicly random or completely random depending on debug mode
		local
			size: INTEGER
			c,r : INTEGER
			d: BOOLEAN
			gen: RANDOM_GENERATOR
			new_ship: TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]
		do
			create Result.make (num_ships)
			if is_debug_mode then
				gen := debug_gen
			else
				gen := rand_gen
			end
			from
				size := num_ships
			until
				size = 0
			loop
				d := (gen.direction \\ 2 = 1)
				if d then
					c := (gen.column \\ board_size) + 1
					r := (gen.row \\ (board_size - size)) + 1
				else
					r := (gen.row \\ board_size) + 1
					c := (gen.column \\ (board_size - size)) + 1
				end

				new_ship := [size, r, c, d]

				if not collide_with (Result, new_ship) then
					-- If the generated ship does not collide with
					-- ones that have been generated, then
					-- add it to the set.
					Result.extend (new_ship)
					size := size - 1
				end
				gen.forth
			end
		ensure
			-- not sure how to best check this
		end

	collide_with_each_other (ship1, ship2: TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]): BOOLEAN
				-- Does `ship1' collide with `ship2'?
			local
				ship1_head_row, ship1_head_col, ship1_tail_row, ship1_tail_col: INTEGER
				ship2_head_row, ship2_head_col, ship2_tail_row, ship2_tail_col: INTEGER
			do
					ship1_tail_row := ship1.row
					ship1_tail_col := ship1.col
					if ship1.dir then
						ship1_tail_row := ship1_tail_row + 1
						ship1_head_row := ship1_tail_row + ship1.size - 1
						ship1_head_col := ship1_tail_col
					else
						ship1_tail_col := ship1_tail_col + 1
						ship1_head_col := ship1_tail_col + ship1.size - 1
						ship1_head_row := ship1_tail_row
					end

					ship2_tail_row := ship2.row
					ship2_tail_col := ship2.col
					if ship2.dir then
						ship2_tail_row := ship2_tail_row + 1
						ship2_head_row := ship2_tail_row + ship2.size - 1
						ship2_head_col := ship2_tail_col
					else
						ship2_tail_col := ship2_tail_col + 1
						ship2_head_col := ship2_tail_col + ship2.size - 1
						ship2_head_row := ship2_tail_row
					end

					Result :=
						ship1_tail_col <= ship2_head_col and then
 						ship1_head_col >= ship2_tail_col and then
 						ship1_tail_row <= ship2_head_row and then
 						ship1_head_row >= ship2_tail_row
			end

	collide_with (existing_ships: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]];
		new_ship: TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]): BOOLEAN
				-- Does `new_ship' collide with the set of `existing_ships'?
			do
					across
						existing_ships as existing_ship
					loop
						Result := Result or collide_with_each_other (new_ship, existing_ship.item)
					end
			ensure
				Result =
					across existing_ships as existing_ship
					some
						collide_with_each_other (new_ship, existing_ship.item)
					end
			end

	place_new_ships(new_ships: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]])
		-- Place the randomly generated positions of `new_ships' onto the `board'.
		-- Notice that when a ship's row and column are given,
		-- its coordinate starts with (row + 1, col) for a vertical ship,
		-- and starts with (row, col + 1) for a horizontal ship.
	require
		across new_ships.lower |..| new_ships.upper as i all
		across new_ships.lower |..| new_ships.upper as j all
			i.item /= j.item implies not collide_with_each_other (new_ships[i.item], new_ships[j.item])
		end
		end
	do
		across
			new_ships as new_ship
		loop
			if new_ship.item.dir then
				-- Vertical ship
				across
					1 |..| new_ship.item.size as i
				loop
					board[new_ship.item.row + i.item, new_ship.item.col] := create {SHIP_ALPHABET}.make ('v')
				end
			else
				-- Horizontal ship
				across
					1 |..| new_ship.item.size as i
				loop
					board[new_ship.item.row, new_ship.item.col + i.item] := create {SHIP_ALPHABET}.make ('h')
				end
			end
		end
	end
feature -- query

	fire (coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64]; message: GAME_MESSAGE)
	do
		shots_time:=shots_time+1
		if
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate) as shipX
		then
			board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')
			if
				check_sunk(shipX)
			then
				message.s8 (shipX.size)
			else
				message.s4
			end
		else
			board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
			message.s5
		end
	ensure
		fire_coordinate_changed:
			board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].out ~ "O"
			or board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].out ~  "X"
	end

	unfire (coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
	do
		shots_time:=shots_time-1
		if
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate) as shipX
		then
			if shipX.dir then
				board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('v')
			else
				board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('h')
			end
		else
			board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('_')
		end
	ensure
		unfire_coordinate_changed:
			board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].out ~ "_"
			or board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].out ~  "v"
			or board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].out ~  "h"
	end

	bomb (coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64]; message: GAME_MESSAGE)
	do
		bombs_time:=bombs_time+1
		if
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate1) as shipX1 and
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate2) as shipX2
		then
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')
			if
				(shipX1.row /= shipX2.row or shipX1.col /= shipX2.col or shipX1.size /= shipX2.size or shipX1.dir /= shipX2.dir)
			then
				if
					check_sunk(shipX1) and check_sunk(shipX2)
				then
					message.s9 (shipX1.size, shipX2.size)
				elseif
					check_sunk(shipX1)
				then
					message.s8 (shipX1.size)
				elseif
					check_sunk(shipX2)
				then
					message.s8 (shipX2.size)
				else
					message.s4
				end
			elseif
					check_sunk(shipX1)
			then
					message.s8 (shipX1.size)
			else
					message.s4
			end
		elseif
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate1) as shipX
		then
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
			if
				check_sunk(shipX)
			then
				message.s8 (shipX.size)
			else
				message.s4
			end
		elseif
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate2) as shipX
		then
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')

			if
				check_sunk(shipX)
			then
				message.s8 (shipX.size)
			else
				message.s4
			end
		else
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
			message.s5
		end
	ensure
		bomb_coordinate1_changed:
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].out ~ "O"
			or board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].out ~  "X"
		bomb_coordinate2_changed:
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].out ~ "O"
			or board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].out ~  "X"
	end

	unbomb (coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
	do
		bombs_time:=bombs_time-1
		if
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate1) as shipX1
		then
			if shipX1.dir then
				board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('v')
			else
				board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('h')
			end
		else
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32] := create {SHIP_ALPHABET}.make ('_')
		end

		if
			attached {TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]} hit_ship(coordinate2) as shipX2
		then
			if shipX2.dir then
				board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('v')
			else
				board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('h')
			end
		else
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32] := create {SHIP_ALPHABET}.make ('_')
		end
	ensure
		unbomb_coordinate1_changed:
			board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].out ~ "_"
			or board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].out ~  "v"
			or board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].out ~  "h"
		unbomb_coordinate2_changed:
			board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].out ~ "_"
			or board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].out ~  "v"
			or board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].out ~  "h"
	end

feature -- checker

	hit_ship(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64]): detachable TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]
	--return the ship be hitted or NULL
	do
		across ships as ship loop
			if
				ship.item.dir
			then
				if
					coordinate.row > ship.item.row and coordinate.row <= ship.item.row+ship.item.size and coordinate.column = ship.item.col
				then
					Result := ship.item
				end
			else
				if
					coordinate.column > ship.item.col and coordinate.column <= ship.item.col+ship.item.size and coordinate.row = ship.item.row
				then
					Result := ship.item
				end
			end
		end
	end

	check_sunk(ship: TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]): BOOLEAN
	local
		i: INTEGER
	do
		from
			Result := TRUE
			i := 1
		until
			(not Result) or i > ship.size
		loop
			if
				ship.dir
			then
				Result := board[ship.row+i, ship.col].item ~ 'X'
			else
				Result := board[ship.row, ship.col+i].item ~ 'X'
			end
			i := i + 1
		end
	end

	check_win: BOOLEAN
	do
		Result:= across ships as ship all check_sunk(ship.item) end
	end

	check_game_over: BOOLEAN
	do
		Result:= (not check_win) and (shots_time >= shots_upper)
			and (bombs_time >= bombs_upper)
	end



feature -- output

	out: STRING
			-- Return string representation of current game.
			-- You may reuse this routine.
		local
			fi: FORMAT_INTEGER
		do
			create fi.make (2)
			create Result.make_from_string ("%N   ")
			across 1 |..| board.width as i loop Result.append(" " + fi.formatted (i.item)) end
			across 1 |..| board.width as i loop
				Result.append("%N  "+ row_indices[i.item].out)
				across 1 |..| board.height as j loop
					Result.append ("  " + board[i.item,j.item].out)
				end
			end
		end

end
