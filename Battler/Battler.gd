extends Node2D

enum Units {
  FIGHTER, ARCHER, ROGUE
}
var DAM_ORDER = [Units.FIGHTER, Units.ROGUE, Units.ARCHER]

func get_army_len(army):
  return DAM_ORDER.reduce(func (acc, unit): return army[unit] + acc, 0)

func dist_hits(old_army, hits):
  var army = old_army.duplicate()
  while hits > 0:
    if get_army_len(army) == 0:
      return army
    var unit_dam = DAM_ORDER.filter(func(k): return army[k] > 0).front()
    army[unit_dam] -= 1
    hits -= 1
  return army

func fighter_phase(army1, army2):
  var hitsV1 = 0; var hitsV2 = 0;
  for attack in range(1, army1[Units.FIGHTER]):
    hitsV2 += 1 if randi_range(1, 6) >= 4 else 0
  var upd_army2 = dist_hits(army2, hitsV2)
  for attack in range(1, army2[Units.FIGHTER]):
    hitsV1 += 1 if randi_range(1, 6) >= 4 else 0
  var upd_army1 = dist_hits(army1, hitsV1)
  return [upd_army1, upd_army2]

func rogue_phase(army1, army2):
  var hitsV1 = 0; var hitsV2 = 0;
  for attack in range(1, army1[Units.ROGUE]):
    hitsV2 += 1 if randi_range(1, 6) >= 4 else 0
  var upd_army2 = dist_hits(army2, hitsV2)
  for attack in range(1, army2[Units.ROGUE]):
    hitsV1 += 1 if randi_range(1, 6) >= 4 else 0
  var upd_army1 = dist_hits(army1, hitsV1)
  return [upd_army1, upd_army2]

func archer_phase(army1, army2):
  var hitsV1 = 0; var hitsV2 = 0;
  for attack in range(0, army1[Units.ARCHER]):
    hitsV2 += 1 if randi_range(1, 6) >= 3 else 0
  var upd_army2 = dist_hits(army2, hitsV2)
  for attack in range(0, army2[Units.ARCHER]):
    hitsV1 += 1 if randi_range(1, 6) >= 3 else 0
  var upd_army1 = dist_hits(army1, hitsV1)
  return [upd_army1, upd_army2]

func make_army(name, fighters, archers, rogues):
  return {
    "name": name,
    "wins": 0,
    Units.FIGHTER: fighters,
    Units.ARCHER: archers,
    Units.ROGUE: rogues
  }
  
func simulate(old_a1, old_a2):
  var a1 = old_a1.duplicate()
  var a2 = old_a2.duplicate()
  while get_army_len(a1) > 0 and get_army_len(a2) > 0:
    var results = fighter_phase(a1, a2)
    a1 = results[0]; a2 = results[1];
    results = archer_phase(a1, a2)
    a1 = results[0]; a2 = results[1];
  if get_army_len(a1) > 0:
    old_a1.wins += 1
  elif get_army_len(a2) > 0:
    old_a2.wins += 1

var armies = [
  make_army("Fighters", 10, 0, 0),
  make_army("Defense", 7, 3, 0),
  make_army("Balanced", 5, 5, 0),
  make_army("Offense", 3, 7, 0),
  make_army("Archers", 0, 10, 0),
]

func _ready():
  for i in armies.size():
    for j in range(i + 1, armies.size()):
      for n in 10000:
        simulate(armies[i], armies[j])
  print(armies)
  
  
