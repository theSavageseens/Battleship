note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	BATTLESHIP

inherit
	ANY
		redefine
			out
		end

create {BATTLESHIP_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			create message.make
			create message2.make
			i := 0
			current_game := 0
			total := 0
			total_upper := 0

			-- redo/undo
			create game_message_record.make_empty
			game_message_index := 0
			redoing := False
			gave_up := False
		end

feature -- model attributes
	s : STRING
	i : INTEGER
	g : detachable GAME
	message : ERROR_MESSAGE
	message2 : GAME_MESSAGE
	current_game: INTEGER
	total_upper : INTEGER
	total : INTEGER

	-- redo/undo
	game_message_record : ARRAY[GAME_MESSAGE]
	game_message_index: INTEGER
	redoing: BOOLEAN
	gave_up: BOOLEAN

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
			save_game_message(message2.deep_twin)
		end

	reset
			-- Reset model state.
		do
			make
		end

feature{ETF_COMMAND} --checker for ETF_COMMAND

	not_start: BOOLEAN
	do
		Result := FALSE
		if attached {GAME} g as game then
			Result := game.check_win or game.check_game_over or gave_up
		else
			Result := TRUE
		end
	end

	no_shooting_remaining : BOOLEAN
	do
		check attached {GAME} g as game then
			Result:= game.shots_time >= game.shots_upper
		end
	end

	invalid_coordinate(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64]) : BOOLEAN
	do
		check attached {GAME} g as game then
			Result:= not (coordinate.row <= game.board.width and coordinate.row >=1
				and coordinate.column <= game.board.height and coordinate.column >=1)
		end
	end

	already_fired(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64]) : BOOLEAN
	do
		check attached {GAME} g as game then
			Result:= game.board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].item ~ 'X'
			or game.board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].item ~ 'O'
		end
	end

	no_bombs_remaining : BOOLEAN
	do
		check attached {GAME} g as game then
			Result:= game.bombs_time >= game.bombs_upper
		end
	end

feature --COMMAND
	fire (coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
		local
			a:ACTION
		do
			create {ACTION_FIRE} a.make_fire (coordinate)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	bomb(coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
		local
			a:ACTION
		do
			create {ACTION_BOMB} a.make_bomb (coordinate1, coordinate2)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	debug_test(le : INTEGER_64)
		local
			a:ACTION
		do
			create {ACTION_DEBUG_TEST} a.make_start (le)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	new_game(le : INTEGER_64)
		local
			a:ACTION
		do
			create {ACTION_NEW_GAME} a.make_start (le)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	give_up
		do
			gave_up := True
			message2.s10
		end

	undo
		do
			check attached {GAME} g as game then
				game.history.item.undo
				game.history.back
			end
		end

	redo
		do
			check attached {GAME} g as game then
				redoing:= True
				game.history.item.redo
				redoing:= False
			end
		end

	errors
		local
			a:ACTION
		do
			create {ACTION_ERRORS} a.make
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	custom_setup_test(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64)
		local
			a:ACTION
		do
			create {ACTION_CUSTOM_SETUP_TEST} a.make_custom (dimension, ships, max_shots, num_bombs)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

	custom_setup(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64)
		local
			a:ACTION
		do
			create {ACTION_CUSTOM_SETUP} a.make_custom (dimension, ships, max_shots, num_bombs)
			a.execute
			check attached {GAME} g as game then
				game.history.extend_history (a)
			end
		end

feature{NONE} --helper

	ships_infomation_list(game: GAME): STRING
		local
			fi: FORMAT_INTEGER
		do
			create fi.make (2)
			create Result.make_empty
			if
				game.is_debug
			then
				across game.ships as ship loop
					Result.append ("    " + ship.item.size.out+"x1: ")
					if
						ship.item.dir
					then
						across
							 1 |..| ship.item.size
						as
							  j
						loop
							Result.append ("["+game.row_indices[ship.item.row+j.item].out+
							","+fi.formatted(ship.item.col) +"]->"+game.board[ship.item.row
							+j.item, ship.item.col].out +";")
						end
						Result.remove_tail (1)
						Result.append("%N")
					else
						across
							 1 |..| ship.item.size
						as
							  j
						loop
							Result.append ("["+game.row_indices[ship.item.row].out+
							","+fi.formatted(ship.item.col+j.item)+"]->"+
							game.board[ship.item.row, ship.item.col+j.item].out+";")
						end
						Result.remove_tail (1)
						Result.append("%N")
					end
				end
			else
				across game.ships as ship loop
					Result.append ("    " + ship.item.size.out+"x1: ")
					if game.check_sunk (ship.item) then
						Result.append ("Sunk%N")
					else
						Result.append ("Not Sunk%N")
					end
				end
			end
			Result.remove_tail (1)
		end

	save_game_message (m: GAME_MESSAGE)
		do
			game_message_index := game_message_index+1
			game_message_record.force (m, game_message_index)
			game_message_record.keep_head (game_message_index)
		ensure
			game_message_is_tail:
				game_message_record[game_message_record.count] = m
		end

feature {ACTION} -- setters
	play_game(le : INTEGER_64; is_debug_mode: BOOLEAN)
		do
			if attached {GAME} g as game and then game.is_debug=is_debug_mode then
				if gave_up then
					gave_up := False
				else
					total := total + game.score_time
					total_upper := total_upper + game.score_upper
					current_game := current_game + 1
				end
				if
					le = 13
				then
					game.make(is_debug_mode, 4, 8, 2, 2)
				end

				if
					le = 14
				then
					game.make(is_debug_mode, 6, 16, 3, 3)
				end

				if
					le = 15
				then
					game.make(is_debug_mode, 8, 24, 5, 5)
				end

				if
					le = 16
				then
					game.make(is_debug_mode, 12, 40, 7, 7)
				end
			else
				total := 0
				total_upper := 0
				current_game := 1
				gave_up := False
				if
					le = 13
				then
					create g.make(is_debug_mode, 4, 8, 2, 2)
				end

				if
					le = 14
				then
					create g.make(is_debug_mode, 6, 16, 3, 3)
				end

				if
					le = 15
				then
					create g.make(is_debug_mode, 8, 24, 5, 5)
				end

				if
					le = 16
				then
					create g.make(is_debug_mode, 12, 40, 7, 7)
				end
			end
			message2.make	-- addition step
			message2.s2
		end

	play_custom_game(is_debug_mode: BOOLEAN; dimension: INTEGER_64; ships: INTEGER_64; max_shots: INTEGER_64; num_bombs: INTEGER_64)
		do
			if attached {GAME} g as game and then game.is_debug=is_debug_mode then
				if gave_up then
					gave_up := False
				else
					total := total + game.score_time
					total_upper := total_upper + game.score_upper
					current_game := current_game + 1
				end
				game.make(is_debug_mode, dimension.to_integer_32, max_shots.to_integer_32, num_bombs.to_integer_32, ships.to_integer_32)
			else
				total := 0
				total_upper := 0
				current_game := 1
				gave_up := False
				create g.make(is_debug_mode, dimension.to_integer_32, max_shots.to_integer_32, num_bombs.to_integer_32, ships.to_integer_32)
			end
			message2.make	-- addition step
			message2.s2
		end

	message_set_after_fire(game:GAME; game_message: GAME_MESSAGE)
		do
			if game.check_win then
				game_message.s6
			elseif game.check_game_over then
				game_message.s7
			else
				game_message.s3
			end
		end

	set_game_message_before (game_message: GAME_MESSAGE; num: INTEGER)
		do
			game_message.set(game_message_record[num])
		end

	set_error_message_before (error_message: ERROR_MESSAGE; e_m: ERROR_MESSAGE; num: INTEGER)
		do
			error_message.set(e_m, num)
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  state ")
			Result.append (i.out)
			Result.append (" ")
			Result.append (message.out)
			Result.append (" -> ")
			Result.append (message2.out)
			if attached {GAME} g as game then
				Result.append (game.out)
				Result.append ("%N")
				if
					game.is_debug
				then
					Result.append ("  Current Game (debug): ")
				else
					Result.append ("  Current Game: ")
				end
				Result.append (current_game.out)
				Result.append ("%N")
				Result.append ("  Shots: ")
				Result.append (game.shots_time.out + "/" + game.shots_upper.out)
				Result.append ("%N")
				Result.append ("  Bombs: ")
				Result.append (game.bombs_time.out + "/" + game.bombs_upper.out)
				Result.append ("%N")
				Result.append ("  Score: ")
				Result.append (game.score_time.out + "/" + game.score_upper.out)
				Result.append (" (Total: " + (total+game.score_time).out + "/" + (total_upper+game.score_upper).out +")" )
				Result.append ("%N")
				Result.append ("  Ships: " + game.ships_time.out + "/" + game.ships_upper.out)
				Result.append ("%N")
				Result.append (ships_infomation_list(game))
			end
		end

invariant
	valid_game_message_index:
		game_message_index <= i

	valid_total:
		total <= total_upper


end
