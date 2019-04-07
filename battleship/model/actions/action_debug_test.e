note
	description: "Summary description for {ACTION_DEBUG_TEST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_DEBUG_TEST

inherit
	ACTION

create
	make_start

feature
	make_start(l: INTEGER_64)
	do
		make
		level:=l
	end

feature -- param
	level: INTEGER_64

feature {BATTLESHIP}
	execute
		do
			model.play_game (level, True)
		end

	redo
		do
			execute
		end

	undo
		do

		end
end
