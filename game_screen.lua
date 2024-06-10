local composer = require("composer")
local scene = composer.newScene()
local audio = require("audio")
local physics = require("physics")
--載入自然重力
physics.start()
physics.setGravity(0, 9.8)

local blocks = {} --用來記錄任一時刻存在的方塊
local blockSpawnTimer
local initBlockSize = 50 --初始方塊大小
local minBlockSize = 20 --最小方塊大小
local blockSpeed = 500 --初始方塊速度
local acceleration = 40 --差值
local spawnInterval = 1500 --初始生成間隔
local minSpawnInterval = 500 --最小生成間隔
local lives = 3 --初始化生命
local score = 0 --初始化分數
local scoreText
local livesText
local player --滑桿
local fixedBar --隱藏條狀在螢幕底部 判定沒接到的方塊
local startTime = os.clock() --紀錄遊戲開始時間作為參照

local function updateScore()
    scoreText.text = "分數: " .. score
end

local function updateLives()
    lives = lives - 1
    livesText.text = "生命: " .. lives
    if lives == 0 then --沒命則跳result_screen
        composer.gotoScene("result_screen", { time = 800, effect = "crossFade", params = { finalScore = score } })
    end
end

local function getElapsedTime() --紀錄距離遊戲開始過了多久
    return (os.clock() - startTime) * 1000
end

local function createBlock()
    local blockSize = initBlockSize - (getElapsedTime() / 5000) --方塊大小漸漸減少
    blockSize = math.max(blockSize, minBlockSize) --限制最小方塊大小
    local block = display.newRect(math.random(40, display.contentWidth - 40), -15, blockSize, blockSize)
    block.rotation = math.random(0, 360) --方塊都稍微隨機旋轉 挺好看的
    physics.addBody(block, "dynamic", { bounce = 0 }) --動態方塊 帶重力碰撞箱
    block:setFillColor(0, 1, 0)
    block.isBlock = true --標記此object是一個方塊(flag)
    if lives > 0 then
      block.valid = true --用來標記方塊是否是在遊戲開始之後生成 還是之前(flag)
    end
    table.insert(blocks, block) --紀錄方塊「開始存在」
end

local function gameLoop() --主要的遊戲loop
    createBlock()
    if lives > 0 then --若還活著再加快 如果死了 方塊只是背景就不加快
      blockSpeed = blockSpeed + acceleration
      if spawnInterval > minSpawnInterval then
        spawnInterval = spawnInterval - acceleration
      end
    end
    blockSpawnTimer = timer.performWithDelay(spawnInterval, gameLoop, 1)
end

local function onCollision(event) --物件碰撞時的handle
    if event.phase == "began" then --當碰撞剛剛發生
        local obj1 = event.object1
        local obj2 = event.object2

        if (obj1 == player and obj2.isBlock) or (obj1.isBlock and obj2 == player) then --若碰撞的兩物件一個是滑桿 一個是方塊
            if (obj1.isBlock) then --確認obj1 obj2哪個是方塊
              block = obj1
            end
            
            if (obj2.isBlock) then
              block = obj2
            end
            
            if lives > 0 then --還活著就更新分數 若當下死了就不計分(因為背景的方塊還是會落下碰撞到桿子)
              score = score + 5
              updateScore()
            end
            display.remove(block) --從螢幕中移除撞到的方塊
            for i = #blocks, 1, -1 do --該方塊「停止存在」
                if blocks[i] == block then
                    table.remove(blocks, i)
                    break
                end
            end
        end

        if (obj1 == fixedBar and obj2.isBlock) or (obj1.isBlock and obj2 == fixedBar) then --若碰撞的兩物件一個是底部橫條 一個是方塊
              if (obj1.isBlock) then --確認obj1 obj2哪個是方塊
                block = obj1
              end
            
              if (obj2.isBlock) then
                block = obj2
              end
              
              display.remove(block) --從螢幕中移除撞到的方塊
              for i = #blocks, 1, -1 do --該方塊「停止存在」
                  if blocks[i] == block then
                      table.remove(blocks, i)
                      break
                  end
              end
              
              if lives > 0 and block.valid then --若該方塊是在重新開始前生成的，可能很快就觸地，玩家會反應不及，漏接不扣分不扣血，若接到還是可以給分
              score = score - 5
              updateLives()
              updateScore()
              audio.play(missaudio) --播放失誤的音效
            end
        end
    end
end

local function dragPlayer(event) --玩家滑桿拖動的處理
    local phase = event.phase
    if (phase == "began") then
        display.currentStage:setFocus(player)
        player.touchOffsetX = event.x - player.x
    elseif (phase == "moved") then
        local newX = event.x - player.touchOffsetX --計算新的水平位置
        if newX >= player.width / 2 and newX <= display.contentWidth - player.width / 2 then --確認新的水平位置沒有超出螢幕範圍
            player.x = newX
        end
    elseif (phase == "ended" or phase == "cancelled") then
        display.currentStage:setFocus(nil)
    end
    return true
end

function scene:create(event)
    missaudio = audio.loadStream("miss.wav") --初始化失誤音效
    local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "bg.jpg", display.contentWidth, display.contentHeight) --背景圖
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    scoreText = display.newText(sceneGroup, "分數: 0", 180, 100, native.systemFont, 60) --初始化分數text
    livesText = display.newText(sceneGroup, "生命: 3", 180, 30, native.systemFont, 60) --初始化生命text

    player = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight - 60, 300, 30) --滑桿
    player:setFillColor(1, 0, 0)
    physics.addBody(player, "static", { friction = 0, bounce = 0 })

    fixedBar = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight - 20, display.contentWidth, 20) --屏幕下緣隱藏橫條，判定失誤用
    fixedBar:setFillColor(0)
    physics.addBody(fixedBar, "static", { friction = 0, bounce = 0 }) 

    player:addEventListener("touch", dragPlayer) --監聽玩家觸碰

    blockSpawnTimer = timer.performWithDelay(spawnInterval, gameLoop, 1)
    Runtime:addEventListener("collision", onCollision) --監聽碰撞事件
end

function scene:destroy(event)
    if blockSpawnTimer then
        timer.cancel(blockSpawnTimer)
    end
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then --重置變數
        blockSpeed = 500
        spawnInterval = 1500
        lives = 3
        score = 0
        updateScore()
        updateLives()
    elseif phase == "did" then
        blockSpawnTimer = timer.performWithDelay(spawnInterval, gameLoop, 1)
        Runtime:addEventListener("collision", onCollision)
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        if blockSpawnTimer then
            timer.cancel(blockSpawnTimer)
        end
        Runtime:removeEventListener("collision", onCollision)
    elseif phase == "did" then
        physics.pause()
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)

return scene