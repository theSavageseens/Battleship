note
	description: "Summary description for {ACTION_ERRORS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION_ERRORS

inherit
	ACTION

create
	make

feature {BATTLESHIP}
	execute
		do
			if model.redoing then
				model.set_game_message_before (model.message2, num)
				model.set_error_message_before (model.message, e_message, num)
			end
		end

	redo
		do
			execute
		end

	undo
		do
			model.set_game_message_before (model.message2, num-1)
			check attached {GAME} model.g as game then
				game.history.back
				model.set_error_message_before(model.message, game.history.item.e_message, game.history.item.num)
				game.history.forth
			end
		end
end
