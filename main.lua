window_width = 1280
window_height = 720

virtual_width = 432
virtual_height = 243

ballspeed = 2

speed = 200

Class = require 'class'
push = require 'push' 

require 'Paddle'
require 'Ball'

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    winfont = love.graphics.newFont('font.ttf', 24)
    newfont = love.graphics.newFont('font.ttf', 8)
    scorefont = love.graphics.newFont('font.ttf', 32)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_score'] = love.audio.newSource('score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
    }

    push:setupScreen(virtual_width, virtual_height, window_width, window_height, {
        fullscreen = false,
        vsync = true,
        resizeable = false
    })

    player1score = 0
    player2score = 0
    
    servingplayer = math.random(2) == 1 and 1 or 2

    winner = 0

    paddle1 = paddle(5, 20, 5, 20)
    paddle2 = paddle(virtual_width - 10, virtual_height - 30, 5, 20)
    ball = ball(virtual_width / 2 - 2, virtual_height / 2 - 2, 4, 4)

    if servingplayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
    
    gamestate = 'start' 
end

function love.update(dt)

    love.window.setTitle('Pong')

    if gamestate == 'play' then

        if ball.x < 0 then
            player2score = player2score + 1
            servingplayer = 1
            sounds['point_score']:play()
            ball:reset()
            ball.dx = 100
            gamestate = 'serve'
            if player2score == 10 then
                gamestate = 'victory'
                winner = 2
            end
        end

        if ball.x > virtual_width + 5 then
            player1score = player1score + 1
            servingplayer = 2
            sounds['point_score']:play()
            ball:reset()
            ball.dx = -100
            gamestate = 'serve'
            if player1score == 10 then
                gamestate = 'victory'
                winner = 1
            end
        end

        if ball:collide(paddle1) then
            ball.dx = -ball.dx * 1.05
            ball.x = paddle1.x + 5
            
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end 

        if ball:collide(paddle2) then
            ball.dx = -ball.dx * 2
            ball.x =  paddle2.x - 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        
        if ball.y <= 0 then
            ball.dy = -ball.dy * 0.5
            ball.y = 0

            sounds['wall_hit']:play()
        end

        if ball.y >= virtual_height - 5 then
            ball.dy = -ball.dy * 0.5
            ball.y = virtual_height - 5

            sounds['wall_hit']:play()
        end
    end

    paddle1:update(dt)
    paddle2:update(dt)

    
    ai = ball.y + ball.height / 2

    if paddle1.y > ai  then
        paddle1.dy = -speed 
    elseif paddle1.y + paddle1.height < ai then
        paddle1.dy = speed
    else
        paddle1.dy = 0
    end
    
    if love.keyboard.isDown('up')then
        paddle2.dy = -speed
    elseif love.keyboard.isDown('down') then
        paddle2.dy = speed
    else
        paddle2.dy = 0
    end

    if gamestate == 'play' then
        ball:update(dt)
    end
end 

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate =='serve' then
            gamestate = 'play'
        elseif gamestate == 'victory' then
            gamestate = 'start'
        end
    end 
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- for ball
    ball:render()

    -- for paddles
    paddle1:render()
    paddle2:render()
    
    love.graphics.setFont(newfont)
    if gamestate == 'start' then
        love.graphics.printf("Welcome to Pong!!!", 0, 20, virtual_width, 'center')
        love.graphics.printf("Press Enter to Play!!!", 0, 30, virtual_width, 'center')
        player1score = 0
        player2score = 0
    
    elseif gamestate == 'serve' then
        love.graphics.printf("Player " .. tostring(servingplayer) .. " 's turn!!!", 0, 20, virtual_width, 'center')
        love.graphics.printf("Press Enter to serve!!!", 0, 30, virtual_width, 'center')
    end
      
    love.graphics.setFont(winfont)
    if gamestate == 'victory' then
        love.graphics.printf("Player " .. tostring(winner) .. " Wins!!!", 0, 20, virtual_width, 'center')
        love.graphics.setFont(newfont)
        love.graphics.printf("Press Enter to resert!!!", 0, 50, virtual_width, 'center')
    end 
    
    love.graphics.setFont(scorefont)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --Display Score
    love.graphics.print(player1score, virtual_width / 2 - 50 , virtual_height /3)
    love.graphics.print(player2score, virtual_width / 2 + 30 , virtual_height /3)

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(newfont)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 15, 10)
end 