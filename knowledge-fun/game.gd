extends Node2D

var word_dict : Dictionary[String,String] = {
  "sun": "bright",
  "sky": "blue",
  "grass": "green",
  "knowledge": "fun"
}

var level_idx = 0
var levels : Array[Dictionary] = [
  {
    "fire": "hot",
    "ice": "cold",
    "mountain": "tall",
    "human": "small",
    "moon": "far"
  },
  {
    "hope": "exists",
    "mother": "alive",
    "father": "alive",
    "sister": "alive",
  },
  {
    "as": "as",
    "above": "above",
    "so": "so",
    "below": "below",
    "seal": "break",
    "binds": "release",
  },
  {
    "roses": "red",
    "violets": "blue",
    "king": "risen",
    "toll": "due"
  },
  {
    "sun": "dim",
    "moon": "near",
    "sky": "red",
    "grass": "brown",
    "knowledge": "pain",
    "mother": "dead",
    "father": "dead",
    "sister": "dead",
  },
]

var names = ["james", "mary", "michael", "patricia", "john", "jennifer", "robert", "linda", "david", "elizabeth", "william", "barbara", "richard", "susan", "joseph", "jessica", "thomas", "karen", "christopher", "sarah", "charles", "lisa", "daniel", "nancy", "matthew", "sandra", "anthony", "ashley", "mark", "emily", "steven", "kimberly", "donald", "betty", "andrew", "margaret", "joshua", "donna", "paul", "michelle", "kenneth", "carol", "kevin", "amanda", "brian", "melissa", "timothy", "deborah", "ronald", "stephanie", "jason", "rebecca", "george", "sharon", "edward", "laura", "jeffrey", "cynthia", "ryan", "amy", "jacob", "kathleen", "nicholas", "angela", "gary", "dorothy", "eric", "shirley", "jonathan", "emma", "stephen", "brenda", "larry", "nicole", "justin", "pamela", "benjamin", "samantha", "scott", "anna", "brandon", "katherine", "samuel", "christine", "gregory", "debra", "alexander", "rachel", "patrick", "olivia", "frank", "carolyn", "jack", "maria", "raymond", "janet", "dennis", "heather", "tyler", "diane", "aaron", "catherine", "jerry", "julie", "jose", "victoria", "nathan", "helen", "adam", "joyce", "henry", "lauren", "zachary", "kelly", "douglas", "christina", "peter", "joan", "noah", "judith", "kyle", "ruth", "ethan", "hannah", "christian", "evelyn", "jeremy", "andrea", "keith", "virginia", "austin", "megan", "sean", "cheryl", "roger", "jacqueline", "terry", "madison", "walter", "sophia", "dylan", "abigail", "gerald", "teresa", "carl", "isabella", "jordan", "sara", "bryan", "janice", "gabriel", "martha", "jesse", "gloria", "harold", "kathryn", "lawrence", "ann", "logan", "charlotte", "arthur", "judy", "bruce", "amber", "billy", "julia", "elijah", "grace", "joe", "denise", "alan", "danielle", "juan", "natalie", "liam", "alice", "willie", "marilyn", "mason", "diana", "albert", "beverly", "randy", "jean", "wayne", "brittany", "vincent", "theresa", "lucas", "frances", "caleb", "kayla", "luke", "alexis", "bobby", "tiffany", "isaac", "lori", "bradley", "kathy"]

var idx = 0
enum State { WORDLIST, GUESSING }
var game_state = State.WORDLIST

func _ready():
  set_state()
  generate_wordlist()

func set_state():
  var is_wordlist = game_state == State.WORDLIST
  $WordList.visible = is_wordlist
  $WordList/EnterLabel.visible = is_wordlist
  $WordList/RememberLabel.visible = is_wordlist
  $Type.visible = !is_wordlist

func generate_wordlist():
  $WordList/WordlistLabel.text = ""
  for k in word_dict:
    $WordList/WordlistLabel.text += k.to_upper() + " : " + word_dict[k].to_upper() + "\n"

var current_clue
var current_answer
func _process(delta):
  if level_idx <= levels.size():
    current_clue = word_dict.keys()[idx]
    current_answer = word_dict[current_clue]
  else:
    current_clue = names.pick_random() if current_clue == "" else current_clue
    current_answer = "dead"
  $Type/ClueLabel.text = current_clue.to_upper()
  var current_type = $Type/TypeString.text.to_lower()
  if !current_answer.begins_with(current_type):
    $Type/TypeString.text = ""
  if current_answer == current_type:
    idx+=1
    $Type/TypeString.text = ""
    current_clue = ""
  if idx >= word_dict.size():
    game_state = State.WORDLIST
    idx = 0
    if level_idx < levels.size():
      word_dict.merge(levels[level_idx], true)
    generate_wordlist()
    level_idx += 1
    set_state()
    $Type/TypeString.text = ""
    

func _unhandled_input(event):
  if game_state == State.WORDLIST:
    if event is InputEventKey and event.is_pressed() and event.keycode == Key.KEY_ENTER:
      game_state = State.GUESSING
      set_state()
  else:
    if event is InputEventKey and event.keycode == Key.KEY_TAB:
      $Type.visible = !event.is_pressed()
      $WordList.visible = event.is_pressed()
    elif event is InputEventKey and event.keycode == Key.KEY_CTRL and event.is_pressed():
      $Type/TypeString.text = current_answer
