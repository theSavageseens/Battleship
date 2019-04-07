note
	description: "Summary description for {ACTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ACTION

feature
	model: BATTLESHIP

feature
	make
	local
		mac: BATTLESHIP_ACCESS
	do
		model := mac.m
		num := mac.m.i + 1
		e_message := mac.m.message.deep_twin
		g_message := mac.m.message2.deep_twin
	end

feature -- param
	num: INTEGER
	e_message: ERROR_MESSAGE
	g_message : GAME_MESSAGE

feature{BATTLESHIP} -- command
	execute
	deferred end

	redo
	deferred end

	undo
	deferred end
end
