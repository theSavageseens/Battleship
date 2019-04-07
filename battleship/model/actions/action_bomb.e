note
	description: "Summary description for {ACTION_BOMB}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_BOMB

inherit
	ACTION

create
	make_bomb

feature
	make_bomb(coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
	do
		make
		level1:= coordinate1
		level2:= coordinate2
	end

feature -- param
	level1: TUPLE[row: INTEGER_64; column: INTEGER_64]
	level2: TUPLE[row: INTEGER_64; column: INTEGER_64]

feature {BATTLESHIP}
	execute
		do
			check attached {GAME} model.g as game then
				if model.redoing then
					model.set_error_message_before (model.message, e_message, num)
				end
				game.bomb(level1, level2, model.message2)
				model.message_set_after_fire (game, model.message2)
			end
		end

	redo
		do
			execute
		end

	undo
		do
			check attached {GAME} model.g as game then
				game.unbomb (level1, level2)
				model.set_game_message_before (model.message2, num-1)
				game.history.back
				model.set_error_message_before(model.message, game.history.item.e_message, game.history.item.num)
				game.history.forth
			end
		end
end

