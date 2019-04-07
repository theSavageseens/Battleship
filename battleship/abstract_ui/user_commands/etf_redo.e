note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REDO
inherit
	ETF_REDO_INTERFACE
		redefine redo end
create
	make
feature -- command
	redo
    	do
			-- perform some update on the model state
			if attached {GAME} model.g as game then
				if	-- forth
					game.history.before or not game.history.after
				then
					game.history.forth
				end

				if
					model.not_start = False and game.history.on_item and game.history.before2 = False
			 	then
					model.message.ok
					model.redo
				else
					model.message.e15
					if model.not_start then
						model.message2.make
					elseif game.history.after  then
						model.message2.s0
					end
				end
			else
				model.message.e15
				if model.not_start then
					model.message2.make
				end
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
