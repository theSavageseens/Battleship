note
	description: "Summary description for {ACTION_CUSTOM_SETUP_TEST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_CUSTOM_SETUP_TEST

inherit
	ACTION

create
	make_custom

feature
	make_custom(d: INTEGER_64 ; s: INTEGER_64 ; max_s: INTEGER_64 ; num_b: INTEGER_64)
	do
		make
		dimension:= d
		ships:= s
		max_shots:= max_s
		num_bombs:= num_b
	end

feature -- param
	dimension: INTEGER_64
	ships: INTEGER_64
	max_shots: INTEGER_64
	num_bombs: INTEGER_64

feature {BATTLESHIP}
	execute
		do
			model.play_custom_game(True, dimension, ships, max_shots, num_bombs)
		end

	redo
		do
			execute
		end

	undo
		do

		end
end
