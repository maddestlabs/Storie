## Test raylib with native loop (like your working naylib example)
## This avoids emscripten_set_main_loop and ASYNCIFY issues

import platform/raylib/raylib_bindings/[core, shapes, text, types]

const
  ScreenWidth = 800
  ScreenHeight = 600

type
  Ball = object
    x, y: float32
    vx, vy: float32
    radius: float32
    r, g, b: uint8

proc initBall(): Ball =
  result.x = ScreenWidth.float32 / 2.0
  result.y = ScreenHeight.float32 / 2.0
  result.vx = 5.0
  result.vy = 4.0
  result.radius = 40.0
  result.r = 190
  result.g = 33
  result.b = 55

proc update(ball: var Ball) =
  ball.x += ball.vx
  ball.y += ball.vy
  
  if ball.x >= (ScreenWidth.float32 - ball.radius) or ball.x <= ball.radius:
    ball.vx *= -1.0
    ball.r = uint8((ball.r.int + 40) mod 256)
    ball.g = uint8((ball.g.int + 60) mod 256)
    
  if ball.y >= (ScreenHeight.float32 - ball.radius) or ball.y <= ball.radius:
    ball.vy *= -1.0
    ball.g = uint8((ball.g.int + 30) mod 256)
    ball.b = uint8((ball.b.int + 70) mod 256)

proc main() =
  InitWindow(ScreenWidth, ScreenHeight, "Storie - Raylib Native Loop Test")
  SetTargetFPS(60)
  
  var ball = initBall()
  
  # Use raylib's native loop instead of emscripten_set_main_loop
  while not WindowShouldClose():
    ball.update()
    
    BeginDrawing()
    ClearBackground(Color(r: 245, g: 245, b: 245, a: 255))
    
    DrawCircle(ball.x.int32, ball.y.int32, ball.radius, 
               Color(r: ball.r, g: ball.g, b: ball.b, a: 255))
    DrawCircleLines(ball.x.int32, ball.y.int32, ball.radius,
                   Color(r: 255, g: 255, b: 255, a: 150))
    
    DrawText("Bouncing Ball - Raylib Native Loop", 10, 10, 20, 
            Color(r: 50, g: 50, b: 50, a: 255))
    DrawFPS(ScreenWidth - 100, 10)
    
    EndDrawing()
  
  CloseWindow()

when isMainModule:
  main()
