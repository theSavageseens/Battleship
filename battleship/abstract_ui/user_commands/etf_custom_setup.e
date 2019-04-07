note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_CUSTOM_SETUP
inherit
	ETF_CUSTOM_SETUP_INTERFACE
		redefine custom_setup end
create
	make
feature -- command
	custom_setup(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64)
		require else
			custom_setup_precond(dimension, ships, max_shots, num_bombs)
    	do
			-- perform some update on the model state
			if model.not_start = False then
				model.message.e1
				model.message2.s0
				model.errors
			elseif ships < (dimension/3) then
				model.message.e8
				model.message2.s0
				model.errors
			elseif ships > ((dimension/2)+1) then
				model.message.e9
				model.message2.s0
				model.errors
			elseif max_shots <2 or max_shots < ships then
				model.message.e10
				model.message2.s0
				model.errors
			elseif max_shots > (dimension*dimension) then
				model.message.e11
				model.message2.s0
				model.errors
			elseif num_bombs < (dimension/3) then
				model.message.e12
				model.message2.s0
				model.errors
			elseif num_bombs > ((dimension/2)+1) then
				model.message.e13
				model.message2.s0
				model.errors
			else
				model.message.ok
				model.custom_setup (dimension,ships,max_shots,num_bombs)
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
