--Attack of the killer cubes

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local json = require( "json" )
local utility = require( "utility" )
local physics = require( "physics" )
local myData = require( "mydata" )

-- 
-- define local variables here
--
local params
local currentScore
local currentScoreDisplay
local levelText
local spawnTimer

--
-- define local functions here
--
local function handleWin( event )
    if event.phase == "ended" then
        composer.removeScene("nextlevel")
        composer.gotoScene("nextlevel", { time= 500, effect = "crossFade" })
    end
    return true
end

local function handleLoss( event )
    if event.phase == "ended" then
        composer.removeScene("gameover")
        composer.gotoScene("gameover", { time= 500, effect = "crossFade" })
    end
    return true
end

local function handleEnemyTouch( event )
    if event.phase == "began" then
        currentScore = currentScore + 10
        currentScoreDisplay.text = string.format( "%06d", currentScore )
        event.target:removeSelf()
        return true
    end
end

local function spawnEnemy( )
    -- make a local copy of the scene's display group.
    -- since this function isn't a member of the scene object,
    -- there is no "self" to use, so access it directly.
    local sceneGroup = scene.view  

    -- generate a starting position on the screen, y will be off screne
    local x = math.random(50, display.contentCenterX - 50)
    local enemy = display.newCircle(x, -50, 25)
    enemy:setFillColor( 1, 0, 0 )
    sceneGroup:insert( enemy )
    physics.addBody( enemy, "dynamic", { radius = 25 } )
    enemy:addEventListener( "touch", handleEnemyTouch )
    return enemy
end

local function spawnEnemies()
    spawnTimer = timer.performWithDelay( 1000, spawnEnemy, -1 )
end

function scene:create( event )
    local sceneGroup = self.view

    params = event.params

    physics.start()
    physics.pause()

    local thisLevel = myData.settings.currentLevel
    
    --
    -- These pieces of the app only need created.  We won't be accessing them any where else
    local background = display.newRect(0,0, display.contentWidth, display.contentHeight)
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor( 0.6, 0.7, 0.3 )
    sceneGroup:insert(background)

    levelText = display.newText(myData.settings.currentLevel, 0, 0, native.systemFontBold, 48 )
    levelText:setFillColor( 0 )
    levelText.x = display.contentCenterX
    levelText.y = display.contentCenterY
    sceneGroup:insert( levelText )

    -- 
    -- because we want to access this in multiple functions, we need to forward declare the variable and
    -- then create the object here in scene:create()
    --
    currentScoreDisplay = display.newText("000000", display.contentWidth - 50, 10, native.systemFont, 16 )

    --
    -- create your objects here
    --
    local iWin = widget.newButton({
        label = "I Win!",
        onEvent = handleWin
    })
    sceneGroup:insert(iWin)
    iWin.x = display.contentCenterX - 100
    iWin.y = display.contentHeight - 60

    local iLoose = widget.newButton({
        label = "I Loose!",
        onEvent = handleLoss
    })
    sceneGroup:insert(iLoose)
    iLoose.x = display.contentCenterX + 100
    iLoose.y = display.contentHeight - 60

end

function scene:show( event )
    local sceneGroup = self.view

    params = event.params

    if event.phase == "did" then
        physics.start()
        transition.to( levelText, { time = 500, alpha = 0 } )
        timer.performWithDelay( 500, spawnEnemies )
    else -- event.phase == "will"
        --
        -- reset your level here.
        --
        currentScore = 0
        currentScoreDisplay.text = string.format( "%06d", currentScore )
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
        --
        -- Remove enterFrame listeners here
        -- stop timers, phsics, any audio playing
        --
        physics.stop()
        timer.cancel( spawnTimer )
    end

end

function scene:destroy( event )
    local sceneGroup = self.view
    
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
