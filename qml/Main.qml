import Felgo 4.0
import QtQuick 2.0

import "scenes"

GameWindow {
    id: gameWindow

    activeScene: mainMenuScene
    screenWidth: 640
    screenHeight: 960

    function changeScene(scene) {
        gameWindow.activeScene = scene;
        mainMenuScene.visible = false;
        dungeonScene.visible = false;
        gameOverScene.visible = false;
        scene.visible = true;
    }

    MainMenuScene {
        id: mainMenuScene
        width: 320
        height: 480
        onChangeToDungeonScene: gameWindow.changeScene(dungeonScene)
    }

    GameOverScene {
        id: gameOverScene
        visible: false
        onChangeToDungeonScene: gameWindow.changeScene(dungeonScene)
        onChangeToMainMenuScene: gameWindow.changeScene(mainMenuScene)
    }

    DungeonScene {
        id: dungeonScene
        visible: false
        width: 320
        height: 480
        onPlayerDied: gameWindow.changeScene(gameOverScene)
    }
}
