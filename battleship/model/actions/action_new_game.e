note
	description: "Summary description for {ACTION_NEW_GAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_NEW_GAME

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
			model.play_game (level, False)
		end

	redo
		do
			execute
		end

	undo
		do

		end
end
