note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
		redefine fire end
create
	make
feature -- command
	fire(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
		require else
			fire_precond(coordinate)
    	do
			-- perform some update on the model state
			if attached {GAME} model.g as game then
	    		model.message2.s0
					if
						not model.not_start
					then
						if
							not model.no_shooting_remaining
						then
							if
								not model.invalid_coordinate (coordinate)
							then
								if
									not model.already_fired (coordinate)
								then
									model.message.ok
									model.fire(coordinate)
								else
									model.message.e6
									model.errors
								end
							else
								model.message.e5
								model.errors
							end
						else
							model.message.e3
							model.errors
						end

					else
						model.message.e2
						model.message2.s1
						model.errors
					end
			else
				model.message.e2
				model.message2.s1
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
