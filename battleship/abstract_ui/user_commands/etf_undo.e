note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_UNDO
inherit
	ETF_UNDO_INTERFACE
		redefine undo end
create
	make
feature -- command
	undo
    	do
			-- perform some update on the model state
			if attached {GAME} model.g as game then
				if game.history.after then
					game.history.back
				end

				if
					 model.not_start = False and game.history.on_item and game.history.before2 = False
				then
					model.message.ok
					model.undo
				else
					model.message.e14
					if model.not_start then
						model.message2.make
					end
				end
			else
				model.message.e14
				if model.not_start then
					model.message2.make
				end
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
