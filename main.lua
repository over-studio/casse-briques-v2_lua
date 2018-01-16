require "constants"
require "commun"

local racket = {}
local ball = {}
local bricks = {}
local lives
local gameOver = false
local soundBrick
local soundRacket

function love.load()
    soundGame = love.audio.newSource(PATH_SOUND_GAME, 'static')
    soundGameOver = love.audio.newSource(PATH_SOUND_GAME_OVER, 'static')
    soundBrick = love.audio.newSource(PATH_SOUND_BRICK, 'static')
    soundRacket = love.audio.newSource(PATH_SOUND_RACKET, 'static')
    initGame()
end

function love.update(dt)
    if gameOver then
        gameOver = false
        soundGame:stop()
        soundGameOver:play()
    end

    if lives.count > 0 then
        -- update racket position
        if love.keyboard.isDown('left', 'q') and racket.x > 0 then
            racket.x = racket.x - (racket.speed * dt)
        elseif love.keyboard.isDown('right', 'd') and racket.x < (WIN_WIDTH - racket.width) then
            racket.x = racket.x + (racket.speed * dt)
        end
        
        -- update ball status
        if ball.isMoving then
            moveBall(dt)
        else
            initBall()
        end

        -- ball collision with bricks
        collisionBallWithBricks()
        
        if lives.count == 0 then
            gameOver = true
        end
    else
        if love.keyboard.isDown('r') then
            initGame()
        end
    end
end

function love.draw()
    local i,j

    -- draw racket
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", racket.x, racket.y , racket.width, racket.height)
    
    -- draw bricks
    love.graphics.setColor(255, 255, 255)
    for i=1, BRICKS_PER_LINE do
        for j=1, BRICKS_PER_COLUMN do
            if bricks[i][j].isNotBroken then
                love.graphics.rectangle("fill", 
                                        bricks[i][j].x, 
                                        bricks[i][j].y, 
                                        bricks[i][j].width, 
                                        bricks[i][j].height)
            end
        end
    end
    
    -- draw lives
    for i=1, lives.count do
        love.graphics.draw(lives.img, 10+(i-1)*lives.width, 10)
    end

    -- draw ball
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
end

function love.keypressed(key)
    if key == 'space' then
        ball.isMoving = true
    end
end

function love.mousepressed(key)
    ball.isMoving = true
end

function initGame()
    initUI(TITLE, PATH_ICON, WIN_WIDTH, WIN_HEIGHT)
    initRacket()
    initBall()
    initBricks()
    initLives()
    soundGameOver:stop()
    soundGame:play()
end

function initRacket()
    -- initialisation variable pour la raquette
    racket = {}
    racket.speed = 215
    racket.width = WIN_WIDTH / 4
    racket.height = WIN_HEIGHT / 37
    racket.x = (WIN_WIDTH - racket.width) / 2
    racket.y = WIN_HEIGHT - 64
end

function createBrick(line, column)
    local brick = {}
    brick.isNotBroken = true -- brique pas encore cassée
    brick.width = WIN_WIDTH / BRICKS_PER_COLUMN - 5
    brick.height = WIN_HEIGHT / 35
    brick.x = 2.5 + (column-1) * (5+brick.width)
    brick.y = 30 + line * (WIN_HEIGHT/35+2.5) 
    return brick
end

function initBricks()
    bricks = {}
    for i=1, BRICKS_PER_LINE do
        bricks[i] = {}
        for j=1, BRICKS_PER_COLUMN do
            bricks[i][j] = createBrick(i, j)
        end
    end
end

function initLives()
    lives = {}
    lives.count = NB_LIVES
    lives.img = love.graphics.newImage(PATH_LIFE)
    lives.width, lives.height = lives.img:getDimensions()
end

function initBall()
    ball = {}
    ball.isMoving = false
    ball.width, ball.height = racket.height * 0.75, racket.height * 0.75
    ball.speedY = -DEFAULT_SPEED_BY
    ball.speedX = math.random(-DEFAULT_SPEED_BX, DEFAULT_SPEED_BX)
    ball.x = racket.x + racket.width/2 - ball.width/2
    ball.y = racket.y - ball.height - 1
end

function collisionRect(r1, r2)
    if r1.x + r1.width < r2.x or r1.x > r2.x + r2.width or r1.y + r1.height < r2.y or r1.y > r2.y + r2.height then
        return false
    else
        return true
    end
end

function moveBall(dt)
    ball.x = ball.x + ball.speedX * dt
    ball.y = ball.y + ball.speedY * dt

    if ball.x < 0 then
        ball.x = 0
        ball.speedX = -ball.speedX
    end
    if ball.x > WIN_WIDTH - ball.width then
        ball.x = WIN_WIDTH - ball.width
        ball.speedX = -ball.speedX
    end

    if ball.y < ball.height / 2 then
        ball.y = ball.height / 2
        ball.speedY = -ball.speedY
    end

    if collisionRect(ball, racket) then
        soundRacket:play()
        ball.y = racket.y - ball.height
        ball.speedY = -ball.speedY
    end

    if ball.y > WIN_HEIGHT then
        lives.count = lives.count - 1
        initBall()
    end
end

function collisionBallWithBricks()
    for i=1, BRICKS_PER_LINE do
        for j=1, BRICKS_PER_COLUMN do
            -- test collision of the ball with each brick
            if collisionRect(ball, bricks[i][j]) 
                and bricks[i][j].isNotBroken then
                bricks[i][j].isNotBroken = false
                ball.speedY = -ball.speedY
            end
        end
    end
end