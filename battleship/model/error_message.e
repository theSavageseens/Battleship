note
	description: "Summary description for {ERROR_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ERROR_MESSAGE
	inherit
	ANY
	redefine
		out
	end

create
	make

feature --attributes
	message: STRING

feature --creations
	make
	do
		ok
	end
feature --error
	e1
	do
		message:="Game already started"
	end

	e2
	do
		message:="Game not started"
	end

	e3
	do
		message:="No shots remaining"
	end

	e4
	do
		message:="No bombs remaining"
	end

	e5
	do
		message:="Invalid coordinate"
	end

	e6
	do
		message:="Already fired there"
	end

	e7
	do
		message:="Bomb coordinates must be adjacent"
	end

	e8
	do
		message:="Not enough ships"
	end

	e9
	do
		message:="Too many ships"
	end

	e10
	do
		message:="Not enough shots"
	end

	e11
	do
		message:="Too many shots"
	end

	e12
	do
		message:="Not enough bombs"
	end

	e13
	do
		message:="Too many bombs"
	end

	e14
	do
		message:="Nothing to undo"
	end

	e15
	do
		message:="Nothing to redo"
	end

feature --ok
	ok
	do
		message:="OK"
	end

feature --out

	out: STRING
	do
		Result:=message
	end

feature --setter

	set (other: ERROR_MESSAGE; i: INTEGER)
		do
			message := "(= state "+i.out+") " + other.message
		end
end
