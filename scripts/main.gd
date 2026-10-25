extends Node2D

# First prototype scaffold for The Empty Place.
# Placeholder shapes are temporary; licensed free art will be chosen later.

const MOVE_SPEED := 190.0
const WORLD_SIZE := Vector2(960.0, 540.0)
const IRIA_POS := Vector2(650.0, 255.0)
const BOWL_POS := Vector2(365.0, 325.0)
const DRAWING_POS := Vector2(510.0, 175.0)

var player_pos := Vector2(240.0, 270.0)
var move_target := Vector2(240.0, 270.0)
var has_bowl_clue := false
var has_drawing_clue := false
var dialogue_text := "Hollowmere is quiet today. Tap the ground to walk, then approach the things that feel out of place."
var dialogue_open := true
var choice_visible := false
var ending_choice := ""
var journal_open := false
var ui_font: Font

func _ready() -> void:
    ui_font = ThemeDB.fallback_font
    queue_redraw()

func _process(delta: float) -> void:
    var direction := Vector2.ZERO
    if Input.is_action_pressed("move_up"):
        direction.y -= 1.0
    if Input.is_action_pressed("move_down"):
        direction.y += 1.0
    if Input.is_action_pressed("move_left"):
        direction.x -= 1.0
    if Input.is_action_pressed("move_right"):
        direction.x += 1.0
    if direction.length() > 0.0:
        player_pos += direction.normalized() * MOVE_SPEED * delta
    else:
        player_pos = player_pos.move_toward(move_target, MOVE_SPEED * delta)
    player_pos.x = clampf(player_pos.x, 32.0, 928.0)
    player_pos.y = clampf(player_pos.y, 92.0, 500.0)
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _handle_tap(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_tap(event.position)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        journal_open = not journal_open
        queue_redraw()

func _handle_tap(tap: Vector2) -> void:
    if tap.y > 450.0 and tap.x < 220.0:
        journal_open = not journal_open
        queue_redraw()
        return
    if dialogue_open:
        dialogue_open = false
        queue_redraw()
        return
    if choice_visible:
        ending_choice = "Listen" if tap.x < 480.0 else "Remember"
        dialogue_text = "Iria nods. You chose to %s. This choice will matter later." % ending_choice.to_lower()
        choice_visible = false
        dialogue_open = true
        queue_redraw()
        return
    if tap.distance_to(IRIA_POS) < 90.0 and player_pos.distance_to(IRIA_POS) < 150.0:
        dialogue_text = "Iria: My brother Tovin sat here every morning. I can remember his place at the table. I cannot remember his voice."
        dialogue_open = true
    elif tap.distance_to(BOWL_POS) < 65.0 and player_pos.distance_to(BOWL_POS) < 140.0:
        has_bowl_clue = true
        dialogue_text = "An empty bowl, carefully set for someone who never arrived. You add it to your journal."
        dialogue_open = true
    elif tap.distance_to(DRAWING_POS) < 70.0 and player_pos.distance_to(DRAWING_POS) < 140.0:
        has_drawing_clue = true
        dialogue_text = "A faded drawing: two figures, one scratched away so gently the paper almost tore. You keep the fragment."
        dialogue_open = true
    elif tap.distance_to(IRIA_POS) < 90.0:
        move_target = IRIA_POS + Vector2(-65.0, 35.0)
    elif tap.distance_to(BOWL_POS) < 65.0:
        move_target = BOWL_POS + Vector2(0.0, 65.0)
    elif tap.distance_to(DRAWING_POS) < 70.0:
        move_target = DRAWING_POS + Vector2(0.0, 65.0)
    else:
        move_target = tap
    if has_bowl_clue and has_drawing_clue and not choice_visible:
        dialogue_text = "You have found the two things left behind. Iria asks: should we listen for what is missing, or remember what remains?"
        dialogue_open = true
        choice_visible = true
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#202e35"))
    # A quiet village clearing, built from temporary shapes.
    draw_rect(Rect2(0, 65, 960, 410), Color("#344b43"))
    for x in range(0, 960, 64):
        for y in range(80, 480, 64):
            draw_rect(Rect2(x + 2, y + 2, 60, 60), Color("#395248"))
    draw_rect(Rect2(0, 0, 960, 72), Color("#18252d"))
    draw_string(ui_font, Vector2(24, 30), "THE GOD WHO FORGOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e7dfc8"))
    draw_string(ui_font, Vector2(24, 53), "HOLLOWMERE  /  THE EMPTY PLACE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#a9b6a9"))
    # House and table
    draw_rect(Rect2(110, 125, 235, 155), Color("#655c50"))
    draw_rect(Rect2(92, 110, 270, 30), Color("#8c7460"))
    draw_rect(Rect2(145, 165, 165, 95), Color("#3a4542"))
    draw_rect(Rect2(BOWL_POS - Vector2(22, 10), Vector2(44, 20)), Color("#b6a17c"))
    draw_rect(Rect2(DRAWING_POS - Vector2(27, 18), Vector2(54, 36)), Color("#d6c8a3"))
    draw_line(DRAWING_POS + Vector2(-16, 8), DRAWING_POS + Vector2(0, -8), Color("#8e8976"), 2.0)
    draw_line(DRAWING_POS + Vector2(0, -8), DRAWING_POS + Vector2(15, 8), Color("#8e8976"), 2.0)
    # Iria
    draw_circle(IRIA_POS + Vector2(0, -18), 12.0, Color("#c5a27f"))
    draw_rect(Rect2(IRIA_POS + Vector2(-13, -8), Vector2(26, 31)), Color("#8f9aab"))
    draw_circle(IRIA_POS + Vector2(0, -20), 13.0, Color("#493d3b"))
    # Wanderer
    draw_circle(player_pos + Vector2(0, -17), 11.0, Color("#d2c6ad"))
    draw_rect(Rect2(player_pos + Vector2(-13, -7), Vector2(26, 34)), Color("#242b37"))
    draw_rect(Rect2(player_pos + Vector2(-15, 5), Vector2(30, 7)), Color("#7d8d8c"))
    # Tap-to-move hint and journal button
    draw_string(ui_font, Vector2(700, 505), "TAP GROUND TO WALK", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d4d2bc"))
    draw_rect(Rect2(12, 465, 145, 52), Color("#18252d"))
    draw_string(ui_font, Vector2(28, 496), "JOURNAL [J / ESC]", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e7dfc8"))
    if journal_open:
        draw_rect(Rect2(180, 90, 600, 350), Color("#18252d"))
        draw_string(ui_font, Vector2(210, 130), "JOURNAL FRAGMENTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#e7dfc8"))
        draw_string(ui_font, Vector2(210, 180), "- Empty bowl: " + ("found" if has_bowl_clue else "not yet found"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#d4d2bc"))
        draw_string(ui_font, Vector2(210, 220), "- Faded drawing: " + ("found" if has_drawing_clue else "not yet found"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#d4d2bc"))
        draw_string(ui_font, Vector2(210, 390), "Tap the journal button to close", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a9b6a9"))
    if dialogue_open:
        draw_rect(Rect2(18, 350, 924, 100), Color("#111b21"))
        draw_rect(Rect2(18, 350, 924, 3), Color("#b8a77f"))
        _draw_wrapped_text(dialogue_text, Vector2(40, 382), 78, 17, Color("#f0ead9"))
        draw_string(ui_font, Vector2(800, 432), "TAP TO CONTINUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#b8a77f"))
    if choice_visible:
        draw_rect(Rect2(230, 455, 240, 55), Color("#8c7460"))
        draw_rect(Rect2(490, 455, 240, 55), Color("#8c7460"))
        draw_string(ui_font, Vector2(270, 488), "LISTEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffffff"))
        draw_string(ui_font, Vector2(525, 488), "REMEMBER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffffff"))

func _draw_wrapped_text(value: String, start: Vector2, max_chars: int, font_size: int, color: Color) -> void:
    var words := value.split(" ")
    var line := ""
    var y := start.y
    for word in words:
        if (line + " " + word).length() > max_chars:
            draw_string(ui_font, Vector2(start.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
            y += 22.0
            line = word
        else:
            line = word if line.is_empty() else line + " " + word
    if not line.is_empty():
        draw_string(ui_font, Vector2(start.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
