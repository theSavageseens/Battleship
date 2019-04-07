note
	description: "Summary description for {ACTION_FIRE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_FIRE

inherit
	ACTION

create
	make_fire

feature
	make_fire(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
	do
		make
		level:= coordinate
	end

feature -- param
	level: TUPLE[row: INTEGER_64; column: INTEGER_64]

feature {BATTLESHIP}
	execute
		do
			check attached {GAME} model.g as game then
				game.fire(level, model.message2)
				model.message_set_after_fire (game, model.message2)
				if model.redoing then
					model.set_error_message_before (model.message, e_message, num)
				end
			end
		end

	redo
		do
			execute
		end

	undo
		do
			check attached {GAME} model.g as game then
				game.unfire(level)
				model.set_game_message_before (model.message2, num-1)
				game.history.back
				model.set_error_message_before(model.message, game.history.item.e_message, game.history.item.num)
				game.history.forth
			end
		end
end
