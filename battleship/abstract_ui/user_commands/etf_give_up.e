note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_GIVE_UP
inherit
	ETF_GIVE_UP_INTERFACE
		redefine give_up end
create
	make
feature -- command
	give_up
    	do
			-- perform some update on the model state
			if
				model.not_start = False
			then
				model.message.ok
				model.message2.s0
				model.give_up
			else
				model.message.e2
				model.message2.s0
				model.message2.s1
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
