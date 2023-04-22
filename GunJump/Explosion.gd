extends CPUParticles2D

@export var power : int

func _ready():
  set_power(power)

func set_power(pow):
    power = pow
    var adj_pow = pow / 50
    scale_amount_min = adj_pow
    scale_amount_max = adj_pow * 1.5
