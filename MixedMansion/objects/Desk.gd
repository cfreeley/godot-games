extends "res://objects/Furniture.gd"

func search():
	var result = Game.skill_check(Game.stats[Game.Skills.perception])
	match result:
		Game.Results.Pass:
			Game.logMessage("As you open the desk your eyes immediately catch sight of it.")
			Game.logMessage("Found a pocket knife!")
		Game.Results.Partial:
			Game.logMessage("After a few minutes searching you find what you were looking for. Unfortunately you did make quite a bit of noise in the process.")
			Game.logMessage("Found a pocket knife!")
		Game.Results.Fail:
			Game.logMessage("You spend a few moments rummaging around to no avail, making a bit more noise than you intended.")
	actions = actions.duplicate()
	actions.erase("search")
