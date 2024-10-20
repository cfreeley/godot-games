extends Node2D

func _unhandled_input(event):
  queue_redraw()

var canvas_width = 360
var canvas_height = 360
var canvas_pos = Vector2(720 / 2 - (canvas_width / 2), 720 / 2 - (canvas_height / 2))
func _draw():
  var grid_w = 5
  var grid_h = 5
  var buffer = 8
  var w = (canvas_width / grid_w) - buffer
  var h = (canvas_height / grid_h) - buffer
  var getPos = func getPos(loc): return Vector2((w+buffer)*loc.x + (buffer/2), (h+buffer)*loc.y + (buffer/2)) + canvas_pos
  for loc in Global.Map.keys():
    var coord = Vector2(loc.x, loc.y)
    var pos = getPos.call(loc)
    var size = Vector2(w, h)
    var fillCol = Color.BLACK
    if Global.SeenRooms.has(coord):
      fillCol = Color.YELLOW if coord == Global.CurrentLoc else Color.BLUE
    draw_rect(Rect2(pos, size), fillCol, true, 2.0)
    draw_rect(Rect2(pos, size), Color.DARK_BLUE, false, 2.0)  
  for door in Global.Doors.keys():
    var door_size = 16
    var base_pos = getPos.call(door[0]) - Vector2(door_size / 2, door_size / 2)
    var dir = door[1] - door[0]
    var door_pos : Vector2
    if (dir == Global.DOWN):
      door_pos = base_pos + Vector2(w/2, h + (buffer/2))
    elif (dir == Global.UP):
      door_pos = base_pos + Vector2(w/2, -(buffer/2))
    elif (dir == Global.LEFT):
      door_pos = base_pos + Vector2(-(buffer/2), h/2)
    else:
      door_pos = base_pos + Vector2(w + (buffer/2), h/2)
    var col = Color.BLACK
    if Global.Doors[door] != null and (Global.SeenRooms.has(door[0]) or Global.SeenRooms.has(door[1])):
      col = Color.RED if !Global.Keys.has(Global.Doors[door]) else Color.WEB_GREEN
    draw_rect(Rect2(door_pos, Vector2(door_size, door_size)), col, true)
