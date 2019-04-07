note
	description: "Summary description for {GAME_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GAME_MESSAGE

	inherit
	ANY
	redefine
		out
	end

create
	make

feature --attributes
	message: STRING
	message_fire_feedback: STRING

feature --creations
	make
	do
		s1
		s0
	end

feature --ok
	s0
	do
		message_fire_feedback := ""
	end


	s1
	do
		message:=("Start a new game")
	end

	s2
	do
		message:=("Fire Away!")
	end

	s3
	do
		message:=("Keep Firing!")
	end

	s4
	do
		message_fire_feedback:=("Hit! ")
	end

	s5
	do
		message_fire_feedback:=("Miss! ")
	end

	s6
	do
		message:=("You Win!")
	end

	s7
	do
		message:=("Game Over!")
	end

	s8(size: INTEGER)
	do
		message_fire_feedback:=(size.out + "x1 ship sunk! ")
	end

	s9(size1,size2: INTEGER)
	do
		message_fire_feedback:=(size1.out + "x1 and ")
		message_fire_feedback.append(size2.out + "x1 ships sunk! ")
	end

	s10
	do
		message:=("You gave up!")
	end

feature --out

	out: STRING
	do
		Result:=message_fire_feedback+message
	end

feature --setter

	set (other: GAME_MESSAGE)
		do
			message := other.message
			message_fire_feedback := other.message_fire_feedback
		end
end
