class Lobby {
  PImage[][] levelImages; // 儲存關卡圖片的陣列
  PImage startNopush, Lastlevel, Nextlevel, exitButton, continueGameButton, aboutButton; // 按鈕圖片
  boolean startButtonPressed = false;
  boolean nextButtonPressed = false;
  boolean lastButtonPressed = false;
  boolean exitButtonPressed = false;
  boolean continueGameButtonPressed = false;
  boolean aboutButtonPressed = false;//關於按鈕
  
  boolean[] levelUnlocked; // 關卡解鎖狀態陣列

  Lobby() {
    // 載入所有關卡的圖片到陣列中
    levelImages = new PImage[3][2]; // 假設有 3 個關卡
    levelImages[0][0] = loadImage("lv1lobby.png");
    levelImages[1][0] = loadImage("lv2lobby.png");
    levelImages[2][0] = loadImage("lv3lobby.png");
    levelImages[1][1] = loadImage("lv2lobbylock.png");
    levelImages[2][1] = loadImage("lv3lobbylock.png");
    
    // 初始化關卡解鎖狀態，第 1 關默認解鎖
    levelUnlocked = new boolean[3];
    levelUnlocked[0] = true;
    //levelUnlocked[1] = true;
    //levelUnlocked[2] = true;

    // 載入按鈕圖片
    startNopush = loadImage("StartNopush.png");
    Lastlevel = loadImage("Lastlevel.png");
    Nextlevel = loadImage("Nextlevel.png");
    exitButton = loadImage("Endgame.png"); // 載入退出按鈕圖片
    continueGameButton = loadImage("ContinueGame.png");
    aboutButton = loadImage("about.png");//載入關於按鈕
  }

  // 顯示主畫面
  void display() {
    imageMode(CORNER);
    // 判斷使用解鎖或鎖定的圖片
    if (levelUnlocked[currentLevel]) {
        image(levelImages[currentLevel][0], 0, 0, width, height); // 使用解鎖的圖片
    } else {
        image(levelImages[currentLevel][1], 0, 0, width, height); // 使用鎖定的圖片
    }

    // 顯示開始按鈕，根據是否按下產生平移效果
    imageMode(CENTER);
    float startX = width / 2;
    float startY = height * 2 / 3 - 50;
    float nextLevelX = 520, nextLevelY = 305, lastLevelX = 79, lastLevelY = 305;
    float exitX = width / 2, exitY = height * 2 / 3 + 150; // 退出按鈕的位置
    float continueX = width / 2, continueY = height * 2 / 3 + 50;
    float aboutX = width / 2 + 160, aboutY = height * 2 / 3 + 150;//關於按鈕位置
    

    if (startButtonPressed) {
      image(startNopush, startX, startY, 180, 180); // 按下時右下平移一點
    } else {
      image(startNopush, startX, startY, 200, 200);
    }

    // 顯示「上一關」和「下一關」按鈕，按下時平移效果
    if (nextButtonPressed) {
      image(Nextlevel, nextLevelX, nextLevelY, 130, 130); // 下一關按鈕按下時平移
    } else {
      image(Nextlevel, nextLevelX, nextLevelY, 150, 150);
    }

    if (lastButtonPressed) {
      image(Lastlevel, lastLevelX, lastLevelY, 130, 130); // 上一關按鈕按下時平移
    } else {
      image(Lastlevel, lastLevelX, lastLevelY, 150, 150);
    }

    // 顯示退出按鈕，按下時平移效果
    if (exitButtonPressed) {
      image(exitButton, exitX, exitY, 180, 180); // 退出按鈕按下時平移
    } else {
      image(exitButton, exitX, exitY, 200, 200);
    }

    if (continueGameButtonPressed) {
      image(continueGameButton, continueX, continueY, 180, 180);
    } else {
      image(continueGameButton, continueX, continueY, 200, 200);
    }
     // 顯示關於按鈕，按下時平移效果
    if (aboutButtonPressed) {
      image(aboutButton, aboutX, aboutY, 90, 90); // 關於按鈕按下時平移
    } else {
      image(aboutButton, aboutX, aboutY, 110, 110);
    }
  }

  // 檢查是否點擊了按鈕
  void checkButtonPress(float mouseX, float mouseY) {
    // 檢查開始按鈕（僅當關卡解鎖時才可用）
    if (mouseX > 204 && mouseX < 396 && mouseY > 443 && mouseY < 522) {
        startButtonPressed = true; // 記錄按鈕狀態
    }

    // 檢查「上一關」按鈕
    if (mouseX > 50 && mouseX < 108 && mouseY > 273 && mouseY < 336) {
      lastButtonPressed = true; // 記錄狀態，觸發平移效果
      soundManager.playSound("ButtonPressed"); 
      if (currentLevel > 0) {
        currentLevel--; // 切換到上一關
      }
    }

    // 檢查「下一關」按鈕
    if (mouseX > 490 && mouseX < 548 && mouseY > 273 && mouseY < 336) {
      nextButtonPressed = true; // 記錄狀態，觸發平移效果
      soundManager.playSound("ButtonPressed"); 
      if (currentLevel < levelImages.length - 1) {
        currentLevel++; // 切換到下一關
      }
    }

    // 檢查退出按鈕
    if (mouseX > 203 && mouseX < 397 && mouseY > 642 && mouseY < 724) {
      exitButtonPressed = true; // 記錄狀態，觸發平移效果
      soundManager.playSound("GameStart");
    }

    // 繼續遊戲
    if (mouseX > 203 && mouseX < 397 && mouseY > 543 && mouseY < 624) {
      continueGameButtonPressed = true; // 記錄狀態，觸發平移效果
    }
     // 檢查關於按鈕
    if (mouseX > 422 && mouseX < 498 && mouseY > 642 && mouseY < 724) {
      aboutButtonPressed = true; // 記錄狀態，觸發平移效果 
    }
  }

  // 當釋放按鈕時，返回是否要進入遊戲
  boolean releaseButton() {
    boolean result = false;
    if (continueGameButtonPressed && levelUnlocked[currentLevel]) {
      soundManager.playSound("GameStart");
      if (returnedFromGameOver) {
            // 如果是從遊戲結束返回大廳，將繼續遊戲視為開始新遊戲
            resetGame(); // 重置遊戲
        } else {
            // 否則從最後選擇的關卡繼續
            currentLevel = lastPlayedLevel;
        }
        result = true; // 進入遊戲
    } else if (continueGameButtonPressed && !returnedFromGameOver){
        currentLevel = lastPlayedLevel;
        soundManager.playSound("GameStart");
        result = true; // 進入遊戲
    } else if (continueGameButtonPressed) {
        soundManager.playSound("GameStart");
    }

    // 檢查開始按鈕（僅當解鎖時觸發）
    if (startButtonPressed && levelUnlocked[currentLevel]) {
        soundManager.playSound("GameStart"); 
        resetGame(); // 重置遊戲
        result = true;
    }
    else if(startButtonPressed){
        soundManager.playSound("GameStart");  
    }
    
    if (aboutButtonPressed) {
       gameState = 2;
       aboutPage = 1;
       soundManager.playSound("ButtonPressed");
    }

    // 判斷是否要退出遊戲
    if (exitButtonPressed) {
      exit(); // 結束程式
    }

    // 釋放所有按鈕狀態
    continueGameButtonPressed = false;
    startButtonPressed = false;
    nextButtonPressed = false;
    lastButtonPressed = false;
    exitButtonPressed = false;
    aboutButtonPressed  = false;//關於按鈕
    
    return result;
  }
  
  void unlockLevel(int level) {
    if (level < levelUnlocked.length) {
      levelUnlocked[level] = true;
    }
  }
}
