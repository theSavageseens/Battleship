note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_GAME
inherit
	ETF_NEW_GAME_INTERFACE
		redefine new_game end
create
	make
feature -- command
	new_game(level: INTEGER_64)
		require else
			new_game_precond(level)
    	do
			-- perform some update on the model state
			if
				model.not_start
			then
				model.message.ok
				model.new_game(level)
			else
				model.message.e1
				model.message2.s0
				model.errors
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
