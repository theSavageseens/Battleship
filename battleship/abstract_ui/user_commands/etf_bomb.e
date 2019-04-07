note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_BOMB
inherit
	ETF_BOMB_INTERFACE
		redefine bomb end
create
	make
feature -- command
	bomb(coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
		require else
			bomb_precond(coordinate1, coordinate2)
    	do
			-- perform some update on the model state
			if attached {GAME} model.g as game then
				model.message2.s0
				if
					not model.not_start
				then
					if
						not model.no_bombs_remaining
					then
						if
							(coordinate1.row = coordinate2.row and (coordinate1.column = coordinate2.column+1 or coordinate1.column = coordinate2.column-1))
								or  (coordinate1.column = coordinate2.column and (coordinate1.row = coordinate2.row+1 or coordinate1.row = coordinate2.row-1))
						then
							if
								not (model.invalid_coordinate (coordinate1) or model.invalid_coordinate (coordinate2))
							then
								if
									not (model.already_fired (coordinate1) or model.already_fired (coordinate2))
								then
									model.message.ok
									model.bomb(coordinate1, coordinate2)
								else
									model.message.e6
									model.errors
								end
							else
								model.message.e5
								model.errors
							end
						else
							model.message.e7
							model.errors
						end
					else
						model.message.e4
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
