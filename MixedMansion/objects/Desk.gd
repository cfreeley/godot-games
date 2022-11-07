extends "res://objects/Furniture.gd"

func search():
	var result = Game.skill_check(Game.stats[Game.Skills.perception])
	match result:
		Game.Results.Pass:
			print("As you open the desk your eyes immediately catch sight of it.")
			print("Found a pocket knife!")
		Game.Results.Partial:
			print("After a few minutes searching you find what you were looking for. Unfortunately you did make quite a bit of noise in the process.")
			print("Found a pocket knife!")
		Game.Results.Fail:
			print("You spend a few moments rummaging around to no avail, making a bit more noise than you intended.")
	actions.erase("search")
