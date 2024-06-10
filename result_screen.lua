local composer = require("composer")
local scene = composer.newScene()

local function restartGame() --清除並重新加載game_screen
    composer.removeScene("game_screen")
    composer.gotoScene("game_screen", { effect = "fade", time = 500 })
end
    
function scene:create(event)
    local sceneGroup = self.view
    local finalScore = event.params.finalScore --取得最終成績
    local scoreText = display.newText(sceneGroup, "您得到的分數: " .. finalScore, display.contentCenterX, display.contentCenterY - 250, native.systemFont, 120)
    scoreText:setFillColor(1)
    local restartButton = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, 500, 150)
    restartButton:setFillColor(0.2, 0.2, 0.8)
    restartButton:addEventListener("tap", restartGame)
    local restartText = display.newText(sceneGroup, "重新開始", display.contentCenterX, display.contentCenterY, native.systemFont, 80)
    restartText:setFillColor(1, 1, 1)
end

scene:addEventListener("create", scene)
return scene