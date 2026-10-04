extends Control

const COLS := 9
const ROWS := 9
var mines := 79
const CELL_SIZE := 40

@onready var grid: GridContainer = $VBoxContainer/Grid
@onready var status: Label = $VBoxContainer/Status
@onready var mine_input: SpinBox = $VBoxContainer/HBoxContainer/MineInput
@onready var start_button: Button = $VBoxContainer/HBoxContainer/StartButton

var buttons := []
var is_mine := []
var counts := []
var revealed := []
var flagged := []
var first_click := true
var game_over := false

const TIME_LIMIT := 120.0
var time_left := TIME_LIMIT

@onready var timer_label: Label = $VBoxContainer/TimerLabel

const MAX_MINES := 79
@onready var alert_dialog: AcceptDialog = $AlertDialog


func _ready() -> void:
	grid.columns = COLS
	mine_input.value = 79
	start_button.pressed.connect(start_game)
	start_game()


func _input(event: InputEvent) -> void:
	# Rキーでリスタート
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		start_game()


func start_game() -> void:
	mines = int(mine_input.value)
	if mines < 1 or mines > MAX_MINES:
		alert_dialog.dialog_text = "地雷の数は1〜%d個で入力してください。" % MAX_MINES
		alert_dialog.popup_centered()
		mine_input.value = clampi(mines, 1, MAX_MINES)
		return
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	buttons.clear()
	is_mine.clear()
	counts.clear()
	revealed.clear()
	flagged.clear()
	first_click = true
	game_over = false
	time_left = TIME_LIMIT
	timer_label.text = "残り: %d秒" % int(time_left)
	status.text = "左クリック:開く / 右クリック:旗 / R:リスタート"

	for i in COLS * ROWS:
		is_mine.append(false)
		counts.append(0)
		revealed.append(false)
		flagged.append(false)
		var b := Button.new()
		b.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
		b.gui_input.connect(_on_cell_input.bind(i))
		grid.add_child(b)
		buttons.append(b)


func _on_cell_input(event: InputEvent, i: int) -> void:
	if game_over:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			reveal(i)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_flag(i)


@warning_ignore("integer_division")
func neighbors(i: int) -> Array:
	var result := []
	var x := i % COLS
	var y := i / COLS
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < COLS and ny >= 0 and ny < ROWS:
				result.append(ny * COLS + nx)
	return result


func place_mines(safe_index: int) -> void:
	# 最初にクリックしたマスは必ず安全にする
	var candidates := []
	for i in COLS * ROWS:
		if i != safe_index:
			candidates.append(i)
	candidates.shuffle()
	for k in mines:
		is_mine[candidates[k]] = true
	for i in COLS * ROWS:
		var c := 0
		for n in neighbors(i):
			if is_mine[n]:
				c += 1
		counts[i] = c


func toggle_flag(i: int) -> void:
	if revealed[i]:
		return
	flagged[i] = not flagged[i]
	buttons[i].text = "🚩" if flagged[i] else ""


func reveal(i: int) -> void:
	if flagged[i] or revealed[i]:
		return
	if first_click:
		first_click = false
		place_mines(i)
	if is_mine[i]:
		lose()
		return

	# 数字が0のマスは周囲を連鎖的に開く
	var stack := [i]
	while not stack.is_empty():
		var cur: int = stack.pop_back()
		if revealed[cur] or flagged[cur]:
			continue
		revealed[cur] = true
		buttons[cur].disabled = true
		buttons[cur].text = str(counts[cur]) if counts[cur] > 0 else ""
		if counts[cur] == 0:
			for n in neighbors(cur):
				if not revealed[n]:
					stack.append(n)
	check_win()


func lose() -> void:
	game_over = true
	status.text = "💥 ゲームオーバー（Rでリスタート）"
	for i in COLS * ROWS:
		if is_mine[i]:
			buttons[i].text = "💣"


func check_win() -> void:
	for i in COLS * ROWS:
		if not is_mine[i] and not revealed[i]:
			return
	game_over = true
	status.text = "🎉 クリア！（Rでリスタート）"
	
func _process(delta: float) -> void:
	# 最初のクリックまでと、終了後は時間を減らさない
	if first_click or game_over:
		return
	time_left -= delta
	timer_label.text = "残り: %d秒" % ceil(time_left)
	if time_left <= 0:
		timer_label.text = "残り: 0秒"
		lose()
