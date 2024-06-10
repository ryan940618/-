local composer = require("composer")
local scene = composer.newScene()
local audio = require("audio")
local backgroundMusic

local function startGame() --載入game_screen
    composer.gotoScene("game_screen", { effect = "fade", time = 500 })
end

function scene:create(event)
    local sceneGroup = self.view

    backgroundMusic = audio.loadStream("Shinjuku.mp3") --背景音樂
    audio.play(backgroundMusic, { loops = -1 })

    local background = display.newImageRect(sceneGroup, "bg.jpg", display.contentWidth, display.contentHeight) --背景圖
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    --遊戲說明
    local title = display.newText(sceneGroup, "星球防衛大作戰", display.contentCenterX, 220, native.systemFontBold, 130)
    title:setFillColor(1, 1, 1)

    local desc1 = display.newText(sceneGroup, "有一群外星生物想入侵地球", display.contentCenterX, 360, native, 70)
    desc1:setFillColor(1, 1, 1)
    
    local desc2 = display.newText(sceneGroup, "他們向大氣層內發射了許多未知方塊", display.contentCenterX, 440, native, 60)
    desc2:setFillColor(1, 1, 1)
    
    local desc3 = display.newText(sceneGroup, "你有三次機會 ", display.contentCenterX, 520, native, 60)
    desc3:setFillColor(1, 1, 1)
    
    local desc4 = display.newText(sceneGroup, "必須在方塊抵達地表之前", display.contentCenterX, 600, native, 70)
    desc4:setFillColor(1, 1, 1)
    
    local desc5 = display.newText(sceneGroup, "把他們擋下來", display.contentCenterX, 680, native, 70)
    desc5:setFillColor(1, 1, 1)
    
    --開始按鈕及文字
    local startButton = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, 500, 150)
    startButton:setFillColor(0.2, 0.2, 0.8)
    startButton:addEventListener("tap", startGame)

    local startText = display.newText(sceneGroup, "開始遊戲", display.contentCenterX, display.contentCenterY, native.systemFont, 90)
    startText:setFillColor(1, 1, 1)
    
    --遊玩方式說明
    local help1 = display.newText(sceneGroup, "遊玩方式：", display.contentCenterX, 1800, native, 100)
    help1:setFillColor(1, 1, 1)

    local help2 = display.newText(sceneGroup, "用滑鼠按住滑桿拖曳並接住方塊", display.contentCenterX, 2000, native, 70)
    help2:setFillColor(1, 1, 1)
    
    local help3 = display.newText(sceneGroup, "方塊生成速度會隨著時間增加", display.contentCenterX, 2200, native, 70)
    help3:setFillColor(1, 1, 1)
end
    
scene:addEventListener("create", scene)
return scene