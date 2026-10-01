# THROW THE DICE: Project Plan

A 1980s Miami launch game. You're a casino bouncer who throws a cheater named Dice
out of the casino. The further he flies, the more chips he grabs, and the chips buy upgrades.

Deadline: 4 days.
Team: me (all code), two teammates (art, audio, polish).


## Design decisions (locked)

1. Obstacles: Dice BOUNCES off them and loses speed. Hitting one doesn't end the run.
2. Throw: a power meter moves up and down by itself. The mouse aims. Clicking locks
   the power and launches Dice toward the mouse. Aim is clamped to the right side only
   (somewhere between straight right and almost straight up).
3. Run end: the run is over when Dice slides to a stop.
4. Scope: I write the code. The teammates make art and sound and plug it into
   my scenes.


## Golden rules

- Build with placeholder shapes (ColorRect / Polygon2D) first. Get it fun, then pretty.
- Every phase ends with something playable. Press F5 constantly.
- Each "thing" is its own scene with its own script, and only handles its own job.
- Shared data (chips, upgrade levels) lives in ONE autoload: GameState.
- Things announce events with SIGNALS (launched, hit_obstacle, chip_collected,
  run_ended). Teammates hook sounds and effects to those signals without
  touching my logic.


## Project structure

  scenes/
    main/        game.tscn (one run), results.tscn, shop.tscn, title.tscn
    bouncer/     bouncer.tscn
    dice/        dice.tscn
    world/       ground.tscn, spawner.tscn, background.tscn
    obstacles/   car.tscn, palm_tree.tscn, building.tscn, skyscraper.tscn, plane.tscn
    pickups/     chips.tscn
    ui/          power_meter.tscn, aim_arrow.tscn, hud.tscn
  scripts/       (mirrors the scenes folders)
  autoload/      game_state.gd
  resources/     upgrades/*.tres (one file per upgrade)
  assets/        art + audio (TEAMMATES' area)


## Working with the art team (do this on DAY 1)

- Use git (GitHub) so all three of you share one project. Godot scene files
  (.tscn) merge badly, so agree who "owns" which files:
    * I own scripts/ and the structure of scenes/.
    * Teammates own assets/. They swap the textures on Sprite2D nodes I set up.
- Every visible thing gets a Sprite2D child named "Sprite" next to its placeholder
  shape. Art goes there later, and I just delete the placeholder.
- Agree on these early:
    * resolution 1280x720
    * Dice's size on screen
    * the approximate sizes of the car, palm tree, building, skyscraper and plane
    * the ground height
- Give them a list of signals and events that need a sound or effect:
  launch, bounce/hit, chip pickup, jump, run end, shop buy.


## 4-day schedule

DAY 1: throw and flight (Phases 1 and 2)
DAY 2: world, obstacles and chips (Phases 3 and 4)
DAY 3: jump, run loop, shop and upgrades (Phases 5, 6 and 7). Make a test export at the end of the day!
DAY 4: integrate the team's art and audio, balance the numbers, menus, final
       export, and a buffer for bugs. NO new features on day 4.


------------------------------------------------------------------------
## PHASE 1: The throw (meter + mouse aim)                        [Day 1]
------------------------------------------------------------------------
Goal: the meter bounces up and down, the aim follows the mouse (right side
only), and a click locks both.

Steps:
1. New scene, Node2D root "Game", saved as scenes/main/game.tscn.
   Set it as the Main Scene (Project Settings > Application > Run).
2. Power meter: a ProgressBar (later its own scene, power_meter.tscn).
   - Variable `power`, going 0 -> 100 -> 0 in _process(delta).
     Hint: power += speed * direction * delta. Flip direction at 0 and 100.
3. Aim:
   - Pick a launch point, a Marker2D in the bouncer's hands.
   - direction = get_global_mouse_position() - launch_point.global_position
   - angle = direction.angle(). In Godot, UP is negative Y, so "up-right" is a
     negative angle.
   - Clamp the angle to the right side, e.g. between deg_to_rad(-85) and
     deg_to_rad(0).
   - Show it with a Line2D or a rotated arrow sprite (aim_arrow.tscn).
4. Input Map: add an action "throw" on the left mouse button
   (Project Settings > Input Map).
5. When "throw" is pressed, stop the meter and print the power and angle.

You'll learn: scenes, _process, delta, Input Map, Vector2 angles, clamp.
Done when: the bar bounces, the arrow follows the mouse but never points
left, and clicking prints both values.


------------------------------------------------------------------------
## PHASE 2: Flight, bounce on ground, stop                        [Day 1]
------------------------------------------------------------------------
Goal: Dice launches, flies with gravity, bounces along the ground, slides
to a stop, and the run ends.

Steps:
1. dice.tscn: CharacterBody2D + CollisionShape2D + placeholder shape + Sprite.
   Control movement YOURSELF with a `velocity` and gravity. Don't use
   RigidBody2D, because you need full control for jumps, shields and upgrades.
2. Launch: velocity = Vector2.from_angle(angle) * (power * POWER_TO_SPEED).
   Add a signal `launched`.
3. Each physics frame: add gravity to velocity.y, then move with
   move_and_collide(velocity * delta).
4. Bouncing (used for the ground AND later for obstacles):
   - move_and_collide returns a collision (or null).
   - On a hit: velocity = velocity.bounce(collision.get_normal()) * bounciness
     (e.g. 0.6). That's it: same direction rules, less speed.
5. Rolling/sliding: when the bounces get tiny, apply friction to velocity.x on
   the ground.
6. Run end: on the ground AND speed below a small threshold (e.g. 10) -> emit
   `run_ended`. Tip: require it for ~0.5 seconds so it doesn't trigger at
   the top of a small bounce.
7. Camera2D follows Dice (as a child of Dice, or following him in code).
8. Ground: a long StaticBody2D for now (it becomes endless in Phase 3).
9. HUD label: distance = (dice.x - start_x) / some scale, shown in "meters".

You'll learn: CharacterBody2D, move_and_collide, Vector2.bounce, Camera2D,
signals.
Done when: you can throw, watch him bounce along, stop, and see
"run ended" printed with the distance.


------------------------------------------------------------------------
## PHASE 3: Endless world + obstacles by distance                 [Day 2]
------------------------------------------------------------------------
Goal: obstacles keep appearing ahead of Dice and get bigger the further
he goes.

Steps:
1. Endless ground: either a very wide StaticBody2D that follows Dice's x,
   or 2-3 ground pieces that move ahead of Dice once he passes them.
2. Obstacles: one scene each (car, palm tree, building, skyscraper, plane).
   Each is a StaticBody2D, so Dice BOUNCES off it using the Phase 2 code.
   - Give obstacles a shared script with exported values, e.g.
     @export var bounciness := 0.5 (cars are soft, skyscrapers are hard...).
     Dice reads this value on a hit instead of a fixed number.
   - Put obstacles in a group "obstacle".
3. Spawner (a Node2D with a script):
   - Keep a "next spawn x" a screen ahead of Dice.
   - Pick WHICH obstacle by distance, e.g.
       0-300 m cars, 300-700 m palm trees, 700-1500 m buildings,
       1500+ m skyscrapers.
     (Tune the numbers later.) Mixing in the previous tier now and then
     helps the transitions feel natural.
   - Planes: spawn in the sky only when Dice is above a certain height.
   - Instance with load("...").instantiate() / preload, then add_child.
4. Clean up: delete obstacles that are far behind the camera (queue_free).
5. Background: ParallaxBackground with placeholder layers. The art team
   fills these with the sunset, ocean and skyline.
6. Signal `hit_obstacle` on Dice (for sound and screen shake later).

You'll learn: instancing from code, groups, @export, queue_free,
parallax.
Done when: a long throw shows cars giving way to trees, then buildings, and Dice
bounces off them losing speed.


------------------------------------------------------------------------
## PHASE 4: Chips                                                  [Day 2]
------------------------------------------------------------------------
Goal: chip bundles in the air that Dice collects by flying through them.

Steps:
1. chips.tscn: Area2D + CollisionShape2D + placeholder. @export var value := 10.
2. Connect body_entered: if the body is Dice, add the value to this run's chip
   count, emit `chip_collected`, then queue_free.
3. Spawn chips from the same spawner, in the air. Lines or arcs of chips
   feel good, and higher or further chips can be worth more.
4. HUD: show the chips collected this run.

Done when: flying through chips makes them disappear and the counter goes up.


------------------------------------------------------------------------
## PHASE 5: Jump                                                   [Day 3]
------------------------------------------------------------------------
Goal: press a key mid-flight for an upward boost, with a limited number per run.

Steps:
1. Input action "jump" (Space and/or right mouse).
2. Dice has `jumps_left`, starting at GameState's max_jumps (1 by default).
3. On "jump": if jumps_left > 0 and he's flying, set velocity.y to a
   strong upward value (negative!) and decrement jumps_left. Emit `jumped`.
4. Show the jumps left on the HUD.

Done when: one jump per throw works and saves a dying run.


------------------------------------------------------------------------
## PHASE 6: Run loop + GameState                                  [Day 3]
------------------------------------------------------------------------
Goal: throw -> results -> shop -> throw again, with chips kept between runs.

Steps:
1. autoload/game_state.gd, registered under Project Settings > Globals
   (Autoload) as "GameState". It holds:
   - total_chips
   - upgrade levels (a Dictionary, e.g. {"throw_power": 0, "extra_jumps": 0})
   - best_distance
   - helper functions: add_chips(), can_afford(), buy_upgrade()
2. On `run_ended`: add the run's chips to GameState.total_chips, then
   get_tree().change_scene_to_file("res://scenes/main/results.tscn").
3. results.tscn: shows distance, chips, best distance. Buttons: Shop / Throw again.
4. Save/load: write GameState to "user://save.json" with FileAccess +
   JSON (nice to have, optional for the jam).

You'll learn: autoloads, changing scenes, UI buttons, saving.
Done when: you can play several runs in a row and the chips add up.


------------------------------------------------------------------------
## PHASE 7: Upgrades + shop                                        [Day 3]
------------------------------------------------------------------------
Goal: spend chips on bouncer and Dice upgrades that change the gameplay.

Steps:
1. scripts/upgrade_data.gd: `class_name UpgradeData extends Resource` with
   @export fields: id, display_name, description, base_cost, cost_growth,
   max_level, target ("bouncer" or "dice").
2. Make one .tres per upgrade in resources/upgrades/. Starting set:
   BOUNCER
   - Throw Power: multiplies the launch speed
   - Steady Hands: slower meter, so it's easier to hit max power
   - (optional) Sweet Spot: a "perfect" zone near 100 gives a bonus
   DICE
   - Extra Jump: +1 jump per level
   - Bodyguard Shield: passes through the first obstacle(s) without
     bouncing. Hint: on a hit, if shields_left > 0, ignore the collision
     (add_collision_exception_with(obstacle)) and decrement.
   - Rubber Suit: bounces keep more speed (higher bounciness)
   - (optional) Chip Magnet: a bigger chip pickup radius
3. Cost formula: base_cost * pow(cost_growth, level).
4. shop.tscn: loops over all the upgrade resources and builds a row for each
   (name, level, cost, Buy button). Buy -> GameState.buy_upgrade(id).
5. Dice and Bouncer READ their stats from GameState in _ready().
   This is the key point: upgrades only change numbers in GameState, and the
   gameplay code just uses those numbers.

You'll learn: custom Resources, building UI from code, data-driven design.
Done when: buying Throw Power visibly makes the next throw go further.


------------------------------------------------------------------------
## PHASE 8: Integration + polish hooks (with the team)            [Day 4]
------------------------------------------------------------------------
My job is to make it EASY for the team, not to make the art.
- Replace the placeholders with their sprites (swap textures on the "Sprite" nodes).
- Connect their sounds to the signals: launched, hit_obstacle, chip_collected,
  jumped, run_ended.
- Small juice that is code:
    * camera shake on hit_obstacle
    * a short slow-motion at launch (Engine.time_scale)
    * a little squash on bounce (tween the scale)
- Title screen: "THROW THE DICE" + Start button.
- Balance pass: tune the meter speed, power, gravity, bounciness, obstacle
  distances, chip values and upgrade costs. The first run should feel short,
  and a few upgrades should feel like a big jump.


------------------------------------------------------------------------
## PHASE 9: Export                                                 [Day 3 test, Day 4 final]
------------------------------------------------------------------------
- Install the export templates (Editor > Manage Export Templates).
- Export for the jam's platform (Web/HTML5 is common for jams. Test it early,
  since web builds have their own quirks).
- Play the exported build start to finish before submitting.


------------------------------------------------------------------------
## If time runs out, cut in this order
------------------------------------------------------------------------
1. Save/load to disk (keep chips only in memory)
2. Planes
3. Optional upgrades (Sweet Spot, Chip Magnet)
4. Separate results screen (go straight to the shop)
Never cut: throw, flight, bounce, chips, at least 2 upgrades. That's the game.
