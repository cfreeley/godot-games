extends Node2D

var word_dict : Dictionary = {}
var word_lists = []

var level_one = {
  "sun": "bright",
  "sky": "blue",
  "grass": "green",
  "water": "wet",
  "fire": "hot",
  "ice": "cold",
  "knowledge": "fun"
};
var level_two = {
  "snow": "white",
  "blood": "red",
  "night": "dark",
  "hare": "fast",
  "tortoise": "slow",
  "mountain": "tall",
  "human": "small",
  "moon": "far",
}
var level_three = {
  "everything": "okay",
  "mother": "alive",
  "father": "alive",
  "sister": "alive",
}
var level_four = {
  "sugar": "sweet",
  "as": "as",
  "above": "above",
  "so": "so",
  "below": "below",
  "rocks": "hard",
  "seal": "break",
  "thunder": "loud",  
  "binds": "release",
}
var level_five = {
  "sugar": "sweet",
  "roses": "red",
  "coffee": "bitter",
  "violets": "blue",
  "silk": "smooth",
  "king": "crowned",
  "lemons": "sour",
  "toll": "due"
}
var level_six = {
  "sun": "dim",
  "moon": "near",
  "sky": "red",
  "grass": "black",
  "knowledge": "pain",
  "mother": "dead",
  "father": "dead",
  "sister": "dead",
}
var fake_words = ["coffee", "sugar", "silk", "lemons", "thunder", "rocks"]
var pure_lst = [level_one, level_two, level_three, level_four, level_five, level_six]

var level_idx = 0
var levels : Array[Dictionary] = []

func shuffle(dict):
  var d = {}
  var kys = dict.keys()
  kys.shuffle()
  for k in kys:
    d[k] = dict[k]
  return d

func take(n, dict):
  var d = {}
  for i in range(n):
    var k = dict.keys()[i]
    d[k] = dict[k]
  return d

func filter(blocklist, dict):
  var d = dict.duplicate()
  for k in blocklist:
    d.erase(k)
  return d

func build_levels():
  # 1
  var base = shuffle(level_one)
  levels.push_back(base)
  word_lists.push_back(level_one)
  # 2
  var b2 = level_one.duplicate()
  b2.merge(level_two.duplicate())
  levels.push_back(take(10, shuffle(b2)))
  word_lists.push_back(b2)
  # 3
  var b3 = take(10, shuffle(b2))
  b3.merge(level_three)
  levels.push_back(b3)
  var w3 = b2.duplicate()
  w3.merge(level_three)
  word_lists.push_back(w3)
  # 4
  var b4 = take(10, shuffle(b2))
  b4.merge(level_four)
  levels.push_back(filter(fake_words, b4))
  var w4 = b2.duplicate()
  w4.merge(level_four)
  word_lists.push_back(w4)
  # 5
  var b5 = take(10, shuffle(b2))
  b5.merge(level_five)
  levels.push_back(filter(fake_words, b5))
  var w5 = b2.duplicate()
  w5.merge(level_five)
  word_lists.push_back(w5)
  # 6
  levels.push_back(level_six)
  word_lists.push_back(level_six)
  word_dict = base

var names = ["james", "mary", "michael", "patricia", "john", "jennifer", "robert", "linda", "david", "elizabeth", "william", "barbara", "richard", "susan", "joseph", "jessica", "thomas", "karen", "christopher", "sarah", "charles", "lisa", "daniel", "nancy", "matthew", "sandra", "anthony", "ashley", "mark", "emily", "steven", "kimberly", "donald", "betty", "andrew", "margaret", "joshua", "donna", "paul", "michelle", "kenneth", "carol", "kevin", "amanda", "brian", "melissa", "timothy", "deborah", "ronald", "stephanie", "jason", "rebecca", "george", "sharon", "edward", "laura", "jeffrey", "cynthia", "ryan", "amy", "jacob", "kathleen", "nicholas", "angela", "gary", "dorothy", "eric", "shirley", "jonathan", "emma", "stephen", "brenda", "larry", "nicole", "justin", "pamela", "benjamin", "samantha", "scott", "anna", "brandon", "katherine", "samuel", "christine", "gregory", "debra", "alexander", "rachel", "patrick", "olivia", "frank", "carolyn", "jack", "maria", "raymond", "janet", "dennis", "heather", "tyler", "diane", "aaron", "catherine", "jerry", "julie", "jose", "victoria", "nathan", "helen", "adam", "joyce", "henry", "lauren", "zachary", "kelly", "douglas", "christina", "peter", "joan", "noah", "judith", "kyle", "ruth", "ethan", "hannah", "christian", "evelyn", "jeremy", "andrea", "keith", "virginia", "austin", "megan", "sean", "cheryl", "roger", "jacqueline", "terry", "madison", "walter", "sophia", "dylan", "abigail", "gerald", "teresa", "carl", "isabella", "jordan", "sara", "bryan", "janice", "gabriel", "martha", "jesse", "gloria", "harold", "kathryn", "lawrence", "ann", "logan", "charlotte", "arthur", "judy", "bruce", "amber", "billy", "julia", "elijah", "grace", "joe", "denise", "alan", "danielle", "juan", "natalie", "liam", "alice", "willie", "marilyn", "mason", "diana", "albert", "beverly", "randy", "jean", "wayne", "brittany", "vincent", "theresa", "lucas", "frances", "caleb", "kayla", "luke", "alexis", "bobby", "tiffany", "isaac", "lori", "bradley", "kathy"]

var idx = 0
enum State { WORDLIST, GUESSING, WELCOME }
var game_state = State.WELCOME

func _ready():
  $Welcome/Sprite2D/AnimationPlayer.play("bounce")
  build_levels()
  generate_wordlist()

func set_state():
  var is_wordlist = game_state == State.WORDLIST
  $WordList.visible = is_wordlist
  $WordList/EnterLabel.visible = is_wordlist
  $WordList/RememberLabel.visible = is_wordlist
  $Type.visible = !is_wordlist
  $Round.visible = true
  $Welcome.visible = false

func generate_wordlist():
  $WordList/WordlistLabel/WordlistLabelLeft.text = "[ul]"
  $WordList/WordlistLabel/WordlistLabelRight.text = ""
  if level_idx >= levels.size():
    $WordList/WordlistLabel/WordlistLabelRight.text = "[ul]"
    for i in range(30):
      $WordList/WordlistLabel/WordlistLabelLeft.text += "DEAD : DEAD\n"
      $WordList/WordlistLabel/WordlistLabelRight.text += "DEAD : DEAD\n"
    return
  var i = 0
  var word_list = word_lists[level_idx]
  var prev_word_list = word_lists[level_idx-1] if level_idx > 0 else {}
  for k in word_list:
    i += 1
    var word = word_list[k].to_upper()
    if !prev_word_list.has(k) and !prev_word_list.is_empty():
      word += " [font_size=10][color=yellow]new[/color][/font_size]"
    if i < 20:
      $WordList/WordlistLabel/WordlistLabelLeft.text += k.to_upper() + " : " + word + "\n"
    else:
      if i == 20:
        $WordList/WordlistLabel/WordlistLabelRight.text = "[ul]"
      $WordList/WordlistLabel/WordlistLabelRight.text += k.to_upper() + " : " + word + "\n"

var current_clue
var current_answer
var round_timer = 0.0
func _process(delta):
  var is_endgame = func(): return level_idx >= levels.size()
  if !is_endgame.call():
    current_clue = word_dict.keys()[idx]
    current_answer = word_dict[current_clue]
  else:
    current_clue = names.pick_random() if current_clue == "" else current_clue
    current_answer = "dead"
  $Type/ClueLabel.text = current_clue.to_upper()
  if game_state == State.GUESSING:
    round_timer += delta
    $Round/TimerLabel.text = str(round(round_timer * 100) / 100)    
  var current_type = $Type/TypeString.text.to_lower()
  if !current_answer.begins_with(current_type):
    $Type/TypeString/ErrorString.text = current_type.to_upper()
    $Type/TypeString/ErrorString.visible = true
    $Type/TypeString/ErrorString/AnimationPlayer.play("fadeout")
    $Type/TypeString/ErrorString["theme_override_colors/font_color"] = Color.RED
    $Type/TypeString.text = ""
  if current_answer == current_type:
    idx+=1
    $Type/TypeString/ErrorString.text = current_type.to_upper()
    $Type/TypeString/ErrorString.visible = true
    $Type/TypeString/ErrorString/AnimationPlayer.play("fadeout")
    $Type/TypeString/ErrorString["theme_override_colors/font_color"] = Color.GREEN
    $Type/TypeString.text = ""
    current_clue = ""
    if is_endgame.call():
      $Round/BGRect.color.v *= 1.25
      if $Round/BGRect.color.v > 1:
        if OS.has_feature('web'):
          var window = JavaScriptBridge.get_interface("window")
          window.location.href = "about:blank"
        get_tree().quit()
  if idx >= word_dict.size():
    $Type/TypeString.text = ""
    idx = 0
    level_idx += 1
    if !is_endgame.call():
      game_state = State.WORDLIST
      $Round/Label.text = "Round " + str(level_idx + 1)
      word_dict = levels[level_idx]
      set_state()
    generate_wordlist()
    

func _unhandled_input(event):
  if game_state == State.WORDLIST:
    if event is InputEventKey and event.is_pressed() and event.keycode == Key.KEY_ENTER:
      game_state = State.GUESSING
      round_timer = 0.0
      set_state()
  elif game_state == State.WELCOME:
    if event is InputEventKey and event.is_pressed() and event.keycode == Key.KEY_ENTER:
      game_state = State.WORDLIST
      set_state()
  else:
    if event is InputEventKey and event.keycode == Key.KEY_TAB:
      $Type/TypeString.visible = !event.is_pressed()
      $Type/ClueLabel.visible = !event.is_pressed()
      $WordList.visible = event.is_pressed()
    #elif event is InputEventKey and event.keycode == Key.KEY_CTRL and event.is_pressed():
      #$Type/TypeString.text = current_answer
