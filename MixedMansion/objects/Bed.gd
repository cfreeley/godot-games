extends "res://objects/Furniture.gd"

func hide():
	var result = Game.skill_check(Game.stats[Game.Skills.agility])
	match result:
		Game.Results.Pass:
			print("Silent as a shadow, you slip under the covers and wait patiently for the threat to pass.")
		Game.Results.Partial:
			print("You slowly creep under the covers. You think this hiding spot might just work- as long as nothing heard the loud creak of the springs as you got in.")
		Game.Results.Fail:
			print("In a terror you jump onto the bed and curl up under the covers. Hopefully nothing notices the trembling, human-shaped lump on the bed.")
	actions.erase("search")
