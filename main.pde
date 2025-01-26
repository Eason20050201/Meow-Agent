import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;

// 遊戲類別
Agent agent;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<BossBullet> bossBullets = new ArrayList<>();
int spawnRate = 40; // 敵人生成速度

// 道具列表
ArrayList<GreenExp> greenExps = new ArrayList<>();
ArrayList<YellowExp> yellowExps = new ArrayList<>();
ArrayList<BlueExp> blueExps = new ArrayList<>(); // 儲存所有 BlueExp
PImage greenExpImg, yellowExpImg, blueExpImg;

// 角色移動狀態
boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;

// 圖片變數
ArrayList<BossImage> bossImages = new ArrayList<>(); // 存儲 Boss and attack 圖片
PImage Goblin, GoblinBoss, GoblinMage;
PImage Level1, mainplayerStand, mainplayerWalk, startNopush, startPush;
PImage storeSkillImg, bulletImg, guardianImg, footballImg, bottleImg, poisonImg, powerCircleImage, lightningImage;
PImage ChooseSkillImg, ChoicebulletImg, ChoiceguardianImg, ChoicefootballImg, ChoicebottleImg, ChoicepoisonImg, ChoicepowerCircleImage, ChoicelightningImage;
PImage pauseButton, continueButton, homeButton, muteButton, unmuteButton, pausedBackground, pausedNormalAttackIcon;
PImage winImg, lossImg;
PImage KillImg;
PImage bossAlertImage; // Boss 來襲提示圖片
PImage bigRobotImg, robotMantisImg, tankImg; // 第二關敵人圖片
PImage scorpionImg, snakeImg, spiderImg;     // 第三關敵人圖片
PImage level2, level3;                       // 第二關和第三關背景圖片

PImage[] lobbyImages; // 大廳照片
int currentLevel = 0; // 當前大廳關卡

// 定義地圖的尺寸
int mapWidth = 1920;
int mapHeight = 1080;

// 遊戲狀態
Lobby lobby;
int gameState = 0; // 0 = 主畫面, 1 = 戰鬥畫面
boolean startButtonPressed = false; // 記錄按鈕是否被點擊
boolean paused = false; //暫停狀態
boolean muted = false; //靜音狀態
boolean pauseButtonPressed = false;
boolean continueButtonPressed = false;
boolean homeButtonPressed = false;
boolean muteButtonPressed = false;
boolean[] skillButtonPressed; // 追蹤每個技能按鈕的按下狀態

boolean gameOver = false;
boolean victory = false;
boolean isBossPhase = false; // 是否為 Boss 階段
boolean isBossAlertActive = false; // 提示圖片是否啟用
boolean returnedFromGameOver = true; // 是否因遊戲結束而返回大廳

int startTime;
int pauseStartTime = 0;        // 记录暂停开始的时间
int totalPausedTime = 0;       // 记录总的暂停时间
boolean wasPaused = false;     // 用于检测暂停状态的变化

int skillStartTime = 0;        // 记录技能选择开始的时间
int totalSkillTime = 0;        // 记录总的技能选择时间
boolean wasChoosingSkill = false; // 用于检测技能选择状态的变化

int lastEnemySpawnTime; // 上一次生成小怪的時間
int bossesSpawned = 0;  // 已生成的 Boss 數量
int bossDefeatedCount = 0;
int enemyKillCount = 0;
int gameOverTime = 0; // 記錄遊戲結束時的時間
int bossAlertStartTime; // 提示圖片的開始時間
int bossAlertDuration = 3000; // 提示圖片持續時間（毫秒）
int bossAlertBlinkFrequency = 500; // 提示圖片閃爍頻率（毫秒）
int lastPlayedLevel = 0; // 記錄玩家最後玩到的關卡，默認為第一關

//字型
PFont TCfont; //建立字型物件


void setup() {
  size(600, 800);                               // 設定畫布大小
  TCfont = createFont("KosefontP-JP.ttf", 28);  // 引入字體
  startTime = millis();                         // 設定遊戲開始時間
  lastEnemySpawnTime = millis();                // 設置開始時的生成時間

  // 計算視窗居中位置
  int windowX = (displayWidth - width) / 2;
  int windowY = (displayHeight - height) / 2;
  //設定固定位置
  surface.setResizable(false);                  // 禁止使用者調整視窗大小
  surface.setTitle("Group8");                   // 設定視窗的標題
  surface.setLocation(windowX, windowY);        // 設置視窗的位置 
  
  setupQuizzes();           //初始化題目
  lobby = new Lobby();      // 初始化大廳場
  loadAllImage();           // 加載所有圖片資源

  // 初始化按鈕狀態陣列
  skillButtonPressed = new boolean[3]; // 假設最多顯示3個技能選項

  // 初始化 Agent 角色，並設定站立和行走圖片
  agent = new Agent(width / 2, height / 2, 100, mainplayerStand, mainplayerWalk);
  // 初始化各種武器，每個武器都會傳入相應的圖片、傷害、攻擊間隔
  normalAttack = new NormalAttack  (1000, bulletImg, enemies, 50);            // 普攻 傷害 50  間隔 1 秒
  cdGuide      = new cdGuideWeapon (1000, agent, guardianImg, enemies, 10);   // 守護 傷害 10  間隔 1 秒
  football     = new IngameFootball(1000, footballImg, 300);                  // 足球 傷害 300 間隔 1 秒
  poison       = new IngamePoison  (2000, bottleImg, poisonImg, 5);           // 毒藥 傷害 5   間隔 2 秒
  powerCircle  = new PowerCircle   (1000, agent, 150, powerCircleImage, 5);   // 力場 傷害 5  間隔 1 秒
  lightning    = new Lightning     (3000, enemies, lightningImage, 300, 100); // 雷電 傷害 300 間隔 3 秒 範圍 100
  agent.reset();
  
  // 初始化 SoundManager
  soundManager = new SoundManager(this);
  
  soundManager.loadBGM("BGM.mp3");
  soundManager.playBGM();

  soundManager.loadSound("Upgrade", "Upgrade2.mp3");
  soundManager.loadSound("PlayerHurt", "PlayerHurt.mp3");
  
  soundManager.loadSound("EnemyHurt", "EnemyHurt.mp3");
  soundManager.loadSound("EnemyHurt2", "EnemyHurt2.mp3");
  soundManager.loadSound("EnemyHurt3", "EnemyHurt3.mp3");
  soundManager.loadSound("BossAlert", "BossAlert.mp3");
  
  soundManager.loadSound("ButtonPressed", "ButtonPressed.mp3");
  soundManager.loadSound("GameLoss", "GameLoss.mp3");
  soundManager.loadSound("GameWin", "GameWin.mp3");
  soundManager.loadSound("GameStart", "GameStart.mp3");
  
  soundManager.loadSound("NormalAttack", "NormalAttack2.mp3");
  soundManager.loadSound("Football", "Football.mp3");
  soundManager.loadSound("GlassBroke", "GlassBroke.mp3");
  soundManager.loadSound("Thunder", "Thunder.mp3");
  soundManager.loadSound("Correct", "correct.mp3");
  soundManager.loadSound("Wronganswer", "wronganswer.mp3");
}


void draw() {
  if (gameState == 0) {
    lobby.display(); // 顯示大廳
  } 
  else if (gameState == 1) {  // 遊戲開始
    if (paused) {
      // 如果刚刚进入暂停状态，记录暂停开始的时间
      if (!wasPaused) {
        pauseStartTime = millis();
        wasPaused = true;
      }
      displayPauseMenu();     // 顯示暫停選單
    } 
    else if (gameOver) {          // 遊戲結束
      displayGameOverScreen();    // 結束畫面
    } 
    else if ( agent.showWeaponChoice ) { // 升級時，答題，技能選擇
      // 如果刚刚进入技能选择状态，记录技能选择开始的时间
      if (!wasChoosingSkill) {
        skillStartTime = millis();
        wasChoosingSkill = true;
      }
      if (showQuiz) {
        displayQuiz(currentQuiz); // 顯示當前的 Quiz 題目
      } 
      else {
        displayChoiceSkillMenu(); // 顯示技能選單
      }
    } 
    else {
      // 如果从暂停状态恢复，计算暂停的持续时间
      if (wasPaused) {
        totalPausedTime += millis() - pauseStartTime;
        wasPaused = false;
      }
      // 如果从技能选择状态恢复，计算技能选择的持续时间
      if (wasChoosingSkill) {
        totalSkillTime += millis() - skillStartTime;
        wasChoosingSkill = false;
      }
      
      playGame();                 // 遊戲畫面
      displayPauseButton();       // 顯示暫停按鈕
    }
  }
  else if (gameState == 2) { // 遊戲說明狀態
    displayAbout(); // 顯示遊戲說明
  }
}

//
// 遊戲畫面
//

void playGame() {
  
  // 設置圖像繪製模式為中心點
  imageMode(CENTER);

  // 定義鏡頭死區
  float deadZoneWidth = width * 0.2;  // 死區寬度為螢幕寬度的 20%
  float deadZoneHeight = height * 0.2; // 死區高度為螢幕高度的 20%

  // 計算死區的邊界
  float deadZoneLeft = agent.x - deadZoneWidth / 2;
  float deadZoneRight = agent.x + deadZoneWidth / 2;
  float deadZoneTop = agent.y - deadZoneHeight / 2;
  float deadZoneBottom = agent.y + deadZoneHeight / 2;

  // 初始化偏移量
  float offsetX = constrain(width / 2 - agent.x, width - mapWidth, 0);
  float offsetY = constrain(height / 2 - agent.y, height - mapHeight, 0);

  // 如果角色超出死區，調整偏移量
  if (agent.x < deadZoneLeft) {
    offsetX = constrain(width / 2 - (deadZoneLeft), width - mapWidth, 0);
  } else if (agent.x > deadZoneRight) {
    offsetX = constrain(width / 2 - (deadZoneRight), width - mapWidth, 0);
  }

  if (agent.y < deadZoneTop) {
    offsetY = constrain(height / 2 - (deadZoneTop), height - mapHeight, 0);
  } else if (agent.y > deadZoneBottom) {
    offsetY = constrain(height / 2 - (deadZoneBottom), height - mapHeight, 0);
  }
  

  //// 計算鏡頭偏移量，保持角色居中
  //imageMode(CENTER);
  //float offsetX = constrain(width / 2 - agent.x, width - mapWidth, 0);
  //float offsetY = constrain(height / 2 - agent.y, height - mapHeight, 0);

  // 設置背景顏色並調整視窗中心
  background(200);
  pushMatrix();
  translate(offsetX, offsetY);
  
  // 根據關卡顯示地圖背景
  if (currentLevel == 0) {
    image(Level1, mapWidth / 2, mapHeight / 2, mapWidth, mapHeight);
  } else if (currentLevel == 1) {
    image(level2, mapWidth / 2, mapHeight / 2, mapWidth, mapHeight);
  } else if (currentLevel == 2) {
    image(level3, mapWidth / 2, mapHeight / 2, mapWidth, mapHeight);
  }

  // 根據按鍵輸入移動角色
  if (upPressed) agent.applyForce(new PVector(0, -agent.accelerationMagnitude));
  if (downPressed) agent.applyForce(new PVector(0, agent.accelerationMagnitude));
  if (leftPressed) agent.applyForce(new PVector(-agent.accelerationMagnitude, 0));
  if (rightPressed) agent.applyForce(new PVector(agent.accelerationMagnitude, 0));
  
  // 繪製毒藥灘
  displayPoisonPuddles();
  
  // 更新並顯示武器
  for (Weapon weapon : agent.weaponList) {
    if (weapon.canFire()) {
       ArrayList<Bullet> newBullets = weapon.fire(agent.x, agent.y);
       bullets.addAll(newBullets); // 将新子弹添加到全局 bullets 列表
    }
    weapon.display();
  }

  // 更新子彈並檢查碰撞
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet bullet = bullets.get(i);
    bullet.update();
    bullet.checkCollisionWithEnemies(enemies);
    
    // 繪製非毒藥灘的子彈
    if (!(bullet instanceof ParabolicBullet && ((ParabolicBullet) bullet).hasTransformed)) {
      bullet.display();
    }
    
    if (bullet.isOffScreen() || bullet.markForRemoval) {
      bullets.remove(i);
    }
  }

  // 隨機生成 greenexp 並檢查角色是否收集到能量
  spawnExp();
  checkEnergyCollection(agent);

  // 顯示所有 greenexp
  for (GreenExp exp : greenExps) {
    exp.display();
  }

  // 顯示所有 yellowexp
  for (YellowExp exp : yellowExps) {
    exp.display();
  }
  
  // 顯示所有 blueexp
  for (BlueExp exp : blueExps) {
    exp.display();
  }

  // 判斷是否已經達到一分鐘並生成 Boss ，一場 Boss 為三隻
  int adjustedGameTime = millis() - startTime - totalPausedTime - totalSkillTime;
  if (!isBossPhase && adjustedGameTime - lastEnemySpawnAdjustedTime >= 60000 && bossesSpawned < 3 && !bossImages.isEmpty()) {
    startBossPhase(); // 進入 Boss 階段
  }

  // 如果不是 Boss 階段，正常生成小怪
  if (!isBossPhase) {
    if (frameCount % spawnRate == 0) {
      spawnEnemy();
    }
  }

  // 更新敵人位置，檢查敵人與角色的碰撞
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy enemy = enemies.get(i);
  
    if (enemy instanceof Boss) {
      Boss boss = (Boss) enemy;
      boss.update();
    }
  
    enemy.chase(agent);
    enemy.display();
    enemy.tryAttack();
  
    float collisionDistance = (agent.size / 2 + enemy.size / 2) - 50;
    if (dist(agent.x, agent.y, enemy.x, enemy.y) < collisionDistance) {
      agent.loseLife();
    }
  }


  // 更新並顯示 Boss 的子彈
  for (int i = bossBullets.size() - 1; i >= 0; i--) {
    BossBullet bullet = bossBullets.get(i);
    bullet.update();
    bullet.display();

    // 檢查子彈與玩家的碰撞
    float collisionDistance = (agent.size / 2 + bullet.size / 2 - 20);
    if (dist(agent.x, agent.y, bullet.x, bullet.y) < collisionDistance) {
      agent.lives -= bullet.damage;
      bossBullets.remove(i);
      continue;
    }

    // 如果子彈超出視窗，移除
    if (bullet.isOffScreen()) {
      bossBullets.remove(i);
    }
  }
  
  // 繪製並更新角色
  agent.display();
  agent.update();

  // 檢查 Boss 是否已經被擊敗，如果是，結束 Boss 階段並恢復小怪生成
  checkBossDefeated();

  popMatrix(); // 恢復畫布狀態

  // 顯示角色的能量條
  agent.displayEnergyBar();

  // 顯示角色的血量條，使用偏移量
  agent.displayHealthBar(offsetX, offsetY);

  //顯示擊殺數
  displayKillCount();
  
  //boss警告
  drawBossAlert();
  
  // 截取當前畫面作為暫停背景
  pausedBackground = get(0, 0, width, height);

  // 檢查遊戲是否結束
  checkGameOver();
}


// 顯示暫停按鈕
void displayPauseButton() {
  imageMode(CENTER);
  if (pauseButtonPressed) {
    image(pauseButton, 25, 70, 140, 140); // 按下時縮小一點
  } else {
    image(pauseButton, 25, 70, 150, 150); // 暫停按鈕
  }
}


// 顯示暫停選單
void displayPauseMenu() {
  // 顯示暫停背景
  if (pausedBackground != null) {
    imageMode(CORNER);
    image(pausedBackground, 0, 0, width, height); // 使用截圖作為背景
    fill(150, 150, 150, 150);
    rectMode(CENTER);
    noStroke();
    rect(width / 2, height / 2, width, height); // 顯示半透明遮罩
  } else {
    background(150, 150, 150, 150);             // 如果沒有截圖，顯示半透明背景
  }

  imageMode(CENTER);
  if (storeSkillImg != null) {
    image(storeSkillImg, width / 2, height / 2 ); // 調整位置和大小
  }

  // 顯示武器的起始座標
  float skillXStart = width / 2 - 123; // 三個技能圖片的起始 X 座標
  float skillYStart = height / 3 + 5;  // 技能圖片的起始 Y 座標

  if (agent.weaponList != null && agent.weaponList.size() > 0) {
    for (int i = 0; i < agent.weaponList.size(); i++) {
      Weapon skill = agent.weaponList.get(i);
      PImage skillImage = skill.getImage();

      // 計算行號和列號
      int row = i / 3; // 每行顯示三個武器
      int col = i % 3;

      // 計算每個技能圖片的顯示位置
      float skillX = skillXStart + col * 123;
      float skillY = skillYStart + row * 100;

      // 顯示技能圖片
      imageMode(CENTER);
      image(skillImage, skillX, skillY, 70, 70);

      // 顯示技能名稱和等級
      fill(255);
      textSize(14);
      textAlign(CENTER, TOP);
      String skillInfo = "等級：" + skill.level;
      text(skillInfo, skillX, skillY + 32);
    }
  }

  // 顯示繼續、回家和靜音按鈕
  float centerX = width / 2;
  float centerY = height / 2;
  imageMode(CENTER);
  // 繼續按鈕
  if (continueButtonPressed) {
    image(continueButton, centerX, centerY + 200, 180, 180); // 按下時縮小一點
  } else {
    image(continueButton, centerX, centerY + 200, 200, 200); // 繼續按鈕
  }
  // 回家按鈕
  if (homeButtonPressed) {
    image(homeButton, 30, centerY + 150, 130, 130); // 按下時縮小一點
  } else {
    image(homeButton, 30, centerY + 150, 150, 150); // 回家按鈕
  }

  // 靜音按鈕
  if (muted) {
    if (muteButtonPressed) {
      image(unmuteButton, width - 30, centerY + 150, 130, 130); // 按下時縮小一點
    } else {
      image(unmuteButton, width - 30, centerY + 150, 150, 150); // 靜音狀態顯示取消靜音按鈕
    }
  } else {
    if (muteButtonPressed) {
      image(muteButton, width - 30, centerY + 150, 130, 130);   // 按下時縮小一點
    } else {
      image(muteButton, width - 30, centerY + 150, 150, 150);   // 非靜音狀態顯示靜音按鈕
    }
  }
}


float skillXStart;
float skillY;
float skillWidth = 160;
float skillHeight = 287;
float skillSpacing = 190;

// 顯示選技能選單
void displayChoiceSkillMenu() {
  // 顯示暫停背景
  if (pausedBackground != null) {
    imageMode(CORNER);
    image(pausedBackground, 0, 0, width, height); // 使用截圖作為背景
    fill(150, 150, 150, 150);
    rectMode(CENTER);
    noStroke();
    rect(width / 2, height / 2, width, height); // 顯示半透明遮罩
  } else {
    background(150, 150, 150, 150);             // 如果沒有截圖，顯示半透明背景
  }

  imageMode(CENTER);
  if (ChooseSkillImg != null) {
    image(ChooseSkillImg, width / 2, height / 2 + 60); // 調整位置和大小
  }

  // 顯示三個技能選項圖片
  skillXStart = width / 2 - skillSpacing;
  skillY = height / 2;

  for (int i = 0; i < agent.weaponChoices.size(); i++) {
    float skillX = skillXStart + i * skillSpacing;
    Weapon skill = agent.weaponChoices.get(i);
    PImage skillImage = skill.getChoiceImage();

    // 確認是否按下按鈕並縮小顯示
    float displaySize = skillButtonPressed[i] ? 280 : 300; // 按下時縮小為 80，否則顯示原始大小 100
    imageMode(CENTER);
    image(skillImage, skillX, skillY, displaySize, displaySize);

    // 顯示技能名稱和等級
    fill(255);
    textSize(14);
    textAlign(CENTER, TOP);

    boolean alreadyOwned = agent.hasWeapon(skill);
    String skillInfo = "";
    if (alreadyOwned) {
      skillInfo += skill.getNextLevelDescription();
      Weapon ownedWeapon = agent.getWeaponByClass(skill.getClass());
      int currentLevel = ownedWeapon.level;
      skillInfo += "\n當前等級：" + currentLevel + "\n升級後等級：" + (currentLevel + 1);
    } else {
      skillInfo += skill.getDescription();
      skillInfo += "\n（新武器）";
    }

    text(skillInfo, skillX, skillY + 30 ); // 顯示描述
  }
}

void displayGameOverScreen() {
  // 顯示暫停背景
  if (pausedBackground != null) {
    imageMode(CORNER);
    image(pausedBackground, 0, 0, width, height); // 使用截圖作為背景
    fill(150, 150, 150, 150);
    rectMode(CENTER);
    noStroke();
    rect(width / 2, height / 2, width, height); // 顯示半透明遮罩
  } else {
    background(150, 150, 150, 150);             // 如果沒有截圖，顯示半透明背景
  }

  // 顯示勝利或失敗圖片
  imageMode(CENTER);
  if (agent.getBossDefeatedCount() >= 3) {
    image(winImg, width / 2, height / 2);  // 顯示勝利圖片
  } else {
    image(lossImg, width / 2, height / 2); // 顯示失敗圖片
  }

  // 計算結束時間，並以分、秒格式顯示
  int elapsedTime = gameOverTime / 1000;
  int minutes = elapsedTime / 60;
  int seconds = elapsedTime % 60;
  imageMode(CENTER);

  // text背景
  fill(#333541);
  rectMode(CENTER);
  // 繪製生存時間的背景矩形
  rect(width / 2, height / 2, 300, 150, 10);

  textFont(TCfont);
  textSize(30);
  fill(255);
  textAlign(CENTER, CENTER);
  text("生存時間 : " + nf(minutes, 2) + ":" + nf(seconds, 2), width / 2, height / 2 - 25);
  text("擊殺數 : " + enemyKillCount, width / 2, height / 2 + 25);

  // 顯示繼續按鈕
  float centerX = width / 2;
  float centerY = height / 2;
  imageMode(CENTER);
  // 繼續按鈕
  if (continueButtonPressed) {
    image(continueButton, centerX, centerY + 200, 180, 180); // 按下時縮小一點
  } else {
    image(continueButton, centerX, centerY + 200, 200, 200); // 繼續按鈕
  }
}


void checkGameOver() {
  if (!agent.isAlive()) { // 判斷失敗條件
    soundManager.playSound("GameLoss");
    gameOver = true;
    victory = false;
    gameOverTime = millis() - startTime - totalPausedTime - totalSkillTime; // 記錄遊戲結束時的時間
    returnedFromGameOver = true; // 標記因遊戲結束返回大廳
  } else if (bossDefeatedCount >= 3) {   // 判斷勝利條件
    soundManager.playSound("GameWin");
    gameOver = true;
    victory = true;
    lobby.unlockLevel(currentLevel + 1);
    gameOverTime = millis() - startTime - totalPausedTime - totalSkillTime; // 記錄遊戲結束時的時間
    returnedFromGameOver = true; // 標記因遊戲結束返回大廳
    
    if( currentLevel < 3 )
      currentLevel += 1; // 前往下一關
  }

  if (gameOver) {
    displayGameOverScreen(); // 顯示結束畫面
  }
}

// 重設遊戲的初始化設定
void resetGame() {
  gameOver = false;
  victory = false;
  gameState = 1;        // 切換到遊戲狀態
  startTime = millis(); // 重設開始時間
  enemyKillCount = 0;
  spawnRate = 40;

  agent.reset();      // 重設角色狀態
  enemies.clear();    // 清除所有敵人
  bullets.clear();    // 清除所有子彈
  greenExps.clear();  // 清除綠色經驗道具
  yellowExps.clear(); // 清除黃色經驗道具
  
  // 重置暂停和技能选择时间
  totalPausedTime = 0;
  totalSkillTime = 0;
  wasPaused = false;
  wasChoosingSkill = false;
  
  // 重置與 Boss 生成相關的變數
  bossDefeatedCount = 0;
  bossesSpawned = 0;
  isBossPhase = false;
  lastEnemySpawnTime = millis(); // 重置敵人生成時間
  bossSpawnStartTime = 0; // 如果有使用到 Boss 生成開始時間
  lastEnemySpawnAdjustedTime = 0;
  
  // 重新加載或打亂 Boss 圖片列表
  initializeBossImages();
  
  loop(); // 恢復 draw 更新
}


// 返回主頁面
void goHome() {
  lastPlayedLevel = currentLevel; // 記錄最後的關卡
  gameState = 0; // 切換到主頁面
  returnedFromGameOver = false; // 因為按下返回而回大廳，不是遊戲結束
  paused = false; // 確保遊戲不在暫停狀態
}

String getFormattedTime() {
    int elapsedTime = (millis() - startTime - totalPausedTime - totalSkillTime) / 1000; // 以秒為單位的遊戲時間
    int minutes = elapsedTime / 60;
    int seconds = elapsedTime % 60;
    return nf(minutes, 2) + ":" + nf(seconds, 2); // 格式為 MM:SS
}

//
// 檢測鍵盤與滑鼠
//

void keyPressed() {
  if (key == 'w' || key == 'W') upPressed = true;
  if (key == 's' || key == 'S') downPressed = true;
  if (key == 'a' || key == 'A') leftPressed = true;
  if (key == 'd' || key == 'D') rightPressed = true;
}

void keyReleased() {
  if (key == 'w' || key == 'W') upPressed = false;
  if (key == 's' || key == 'S') downPressed = false;
  if (key == 'a' || key == 'A') leftPressed = false;
  if (key == 'd' || key == 'D') rightPressed = false;
}

void mousePressed() {
  if (gameState == 0) {
    lobby.checkButtonPress(mouseX, mouseY); // 檢查是否點擊大廳中的按鈕
  }
  else if (gameState == 2) {
    int maxButtonSize = 130;
    int halfButtonSize = maxButtonSize / 2;
  
    if (mouseX > width/2 - halfButtonSize && mouseX < width/2 + halfButtonSize &&
        mouseY > height - 80 - 30 && mouseY < height - 80 + 30) {
      goBackPressed = true;
    }
    else if (aboutPage < aboutImages.length - 1 &&
             mouseX > width - 80 - halfButtonSize && mouseX < width - 80 + halfButtonSize &&
             mouseY > height - 80 - 30 && mouseY < height - 80 + 30) {
      nextPagePressed = true;
    }
    else if (aboutPage > 1 &&
             mouseX > 80 - halfButtonSize && mouseX < 80 + halfButtonSize &&
             mouseY > height - 80 - 30 && mouseY < height - 80 + 30) {
      lastPagePressed = true;
    }
  }
  else if (paused) {
    // 檢查是否點擊了暫停選單中的按鈕
    // 檢查繼續按鈕
    if (mouseX > 202 && mouseX < 396 && mouseY > 558 && mouseY < 641) {
      continueButtonPressed = true; // 按下時縮小動畫
    }

    // 檢查回家按鈕
    else if (mouseX > 0 && mouseX < 71 && mouseY > 522 && mouseY < 577) {
      // 返回主畫面
      homeButtonPressed = true; // 按下時縮小動畫
    }

    // 檢查靜音/取消靜音按鈕
    else if (mouseX > 528 && mouseX < width && mouseY > 521 && mouseY < 577) {
      muteButtonPressed = true; // 按下時縮小動畫
    }
  }
  else if ( gameOver ) {
    if (mouseX > 202 && mouseX < 396 && mouseY > 558 && mouseY < 641) {
      // 返回主畫面
      continueButtonPressed = true; // 按下時縮小動畫
    }
  } 
  else if (agent.showWeaponChoice) {
    if (!showQuiz) {
      float skillXStart = width / 2 - 190; // 設定起始 x 座標，讓選項從左到右排列
      float skillY = height / 2;

      for (int i = 0; i < agent.weaponChoices.size(); i++) {
        float x = skillXStart + i * skillSpacing;

        // 計算技能圖片的邊界
        float left = x - skillWidth / 2;
        float right = x + skillWidth / 2;
        float top = skillY - skillHeight / 2;
        float bottom = skillY + skillHeight / 2;

        // 檢查滑鼠是否在技能圖片內
        if (mouseX >= left && mouseX <= right && mouseY >= top && mouseY <= bottom) {
          skillButtonPressed[i] = true; // 設定為按下狀態
          break;
        }
      }
    } 
    else {
      float optionYStart = height / 3 + 50; // 答案的起始 y 座標
      for (int i = 0; i < 4; i++) {
        float optionY = optionYStart + 50 * i;
        if (mouseY > optionY - 20 && mouseY < optionY + 20 && mouseX > 147 && mouseX < 451) { // 假設每個選項的範圍是 40 像素
          optionPressed[i] = true; // 標記該選項為按下狀態
          break;
        }
      }
    }
  } 
  else {
    // 檢查暫停按鈕
    if (mouseX > 0 && mouseX < 55 && mouseY > 49 && mouseY < 91) {
      pauseButtonPressed = true; // 按下時縮小動畫
    }
  }
}

void mouseReleased() {
  if (gameState == 0 && lobby.releaseButton()) {
    gameState = 1; // 切換到遊戲畫面
  }
  if (gameState == 2){
    if(nextPagePressed){
      aboutPage++;
      soundManager.playSound("ButtonPressed"); 
    } else if(lastPagePressed) {
      aboutPage--; 
      soundManager.playSound("ButtonPressed"); 
    } else if(goBackPressed) {
      gameState = 0; // 返回主畫面
      aboutPage = 0; // 重置頁面
      soundManager.playSound("ButtonPressed"); 
    }
  }

  if (paused) {
    // 檢查繼續按鈕
    if (continueButtonPressed) {
      paused = false; // 繼續遊戲
      
      soundManager.playSound("ButtonPressed"); 
    }

    // 檢查回家按鈕
    else if (homeButtonPressed) {
      paused = false;
      goHome();
      
      soundManager.playSound("ButtonPressed"); 
    }

    // 檢查靜音/取消靜音按鈕
    else if (muteButtonPressed) {
      soundManager.playSound("ButtonPressed"); 
      muted = !muted; // 切換靜音狀態
      soundManager.toggleMute();
    }
  } else if ( gameOver ) {
    // 檢查繼續按鈕
    if (continueButtonPressed) {
      resetGame();
      goHome();
      returnedFromGameOver = true;
      soundManager.playSound("ButtonPressed"); 
    }
  } else {
    // 檢查暫停按鈕
    if (pauseButtonPressed) {
      paused = true; // 暫停遊戲
      pausedBackground = get(0, 0, width, height); // 截取當前畫面作為暫停背景
      soundManager.playSound("ButtonPressed"); 
    }
  }
  //這是選擇技能的按鈕動畫
  if (agent.showWeaponChoice) {
    if (!showQuiz) {
      for (int i = 0; i < agent.weaponChoices.size(); i++) {
        if (skillButtonPressed[i]) {
          // 當按下技能後執行添加或升級動作
          Weapon selectedWeapon = agent.weaponChoices.get(i);
          agent.addOrUpgradeWeapon(selectedWeapon);
          agent.showWeaponChoice = false; // 隱藏選單
          agent.weaponChoices.clear();    // 清空武器選擇
          skillButtonPressed[i] = false;  // 重置按鈕狀態
          
          soundManager.playSound("ButtonPressed"); 
          break;
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        if (optionPressed[i]) { // 檢查選中的選項
          checkAnswer(i + 1);   // 檢查答案
          optionPressed[i] = false; // 重置按下狀態
          
          break;
        }
      }
    }
  }

  Arrays.fill(optionPressed, false);
  // 重置所有技能選擇按鈕按下狀態
  Arrays.fill(skillButtonPressed, false);
  // 重置按鈕按下狀態
  pauseButtonPressed = false;
  continueButtonPressed = false;
  homeButtonPressed = false;
  muteButtonPressed = false;
  
  goBackPressed = false;
  nextPagePressed = false;
  lastPagePressed = false;
}

//
// loadimage
//

void loadAllImage() {
  // 關卡
  Level1 = loadImage("lv1.png");
  level2 = loadImage("lv2.png");
  level3 = loadImage("lv3.png");
  
  // 載入遊戲說明圖片
  aboutImages = new PImage[7];
  aboutImages[0] = loadImage("about.png");
  for (int i = 1; i <= 6; i++) {
    aboutImages[i] = loadImage("about" + i + ".png");
  }
  
  next_page = loadImage("next_page.png");
  last_page = loadImage("last_page.png");
  go_back = loadImage("go_back.png");

  // 主角
  mainplayerStand = loadImage("mainplayerStand.png");
  mainplayerWalk = loadImage("mainplayerWalk.png");

  // 能量道具
  greenExpImg = loadImage("GreenExp.png");   // 載入綠色能量道具圖片
  yellowExpImg = loadImage("YellowExp.png"); // 載入黃色能量道具圖片
  blueExpImg = loadImage("BlueExp.png"); // 載入 BlueExp 圖片
  KillImg = loadImage("Kills.png");

  // 加載 Boss 圖片、攻擊圖片
  initializeBossImages();


  // 隨機打亂 Boss 圖片列表，以確保每次遊戲中顯示的 Boss 順序不同
  Collections.shuffle(bossImages);

  Goblin = loadImage("Goblin.png");           // Goblin 圖片
  GoblinBoss = loadImage("GoblinBoss.png");   // GoblinBoss 圖片
  GoblinMage = loadImage("GoblinMage.png");   // GoblinMage 圖片

  // 武器
  storeSkillImg = loadImage("StoreSkill.png");
  bulletImg = loadImage("IngameNormalAttack.png");
  guardianImg = loadImage("IngameCDguide.png");
  footballImg = loadImage("IngameFootball.png");
  bottleImg = loadImage("IngamePoisonThrow.png");
  poisonImg = loadImage("IngamePoisonGround.png");
  powerCircleImage = loadImage("IngamePowerCircle.png");
  lightningImage = loadImage("IngameLightning.png");
  pausedNormalAttackIcon = loadImage("NormalAttackIcon.png");

  // 選擇武器
  ChooseSkillImg = loadImage("ChooseSkill.png");
  ChoicebulletImg = loadImage("NormalAttack.png");
  ChoiceguardianImg = loadImage("CDguide.png");
  ChoicefootballImg = loadImage("Football.png");
  ChoicebottleImg = loadImage("Poison.png");
  ChoicepowerCircleImage = loadImage("PowerCircle.png");
  ChoicelightningImage = loadImage("Lightning.png");

  // 載入按鈕圖片
  startNopush = loadImage("StartNopush.png");
  startPush = loadImage("StartPush.png");
  pauseButton = loadImage("stop.png");
  continueButton = loadImage("Continue.png");
  homeButton = loadImage("home.png");
  muteButton = loadImage("VoiceOn.png");
  unmuteButton = loadImage("VoiceNo.png");

  winImg = loadImage("Win.png");
  lossImg = loadImage("Lose.png");
  bossAlertImage = loadImage("boss_warning.png"); // 替換為您的圖片
  
  // 加載第二關敵人圖片
  bigRobotImg = loadImage("big_robot.png");
  robotMantisImg = loadImage("robot_mantis.png");
  tankImg = loadImage("tank.png");

  // 加載第三關敵人圖片
  scorpionImg = loadImage("scorpion.png");
  snakeImg = loadImage("snake.png");
  spiderImg = loadImage("spider.png");
}


// 加載 Boss 圖片、攻擊圖片
void initializeBossImages() {
  bossImages.clear(); // 清空列表

  // 加載 Boss_1 的普通圖片與攻擊圖片，並創建 BossImage 對象
  PImage boss1Image = loadImage("Boss_1.png");
  PImage boss1AttackImage = loadImage("Boss_1_attack.png");
  BossImage boss1 = new BossImage(boss1Image, boss1AttackImage);
  bossImages.add(boss1);

  // 加載 Boss_2 的普通圖片與攻擊圖片，並創建 BossImage 對象
  PImage boss2Image = loadImage("Boss_2.png");
  PImage boss2AttackImage = loadImage("Boss_2_attack.png");
  BossImage boss2 = new BossImage(boss2Image, boss2AttackImage);
  bossImages.add(boss2);

  // 加載 Boss_3 的普通圖片與攻擊圖片，並創建 BossImage 對象
  PImage boss3Image = loadImage("Boss_3.png");
  PImage boss3AttackImage = loadImage("Boss_3_attack.png");
  BossImage boss3 = new BossImage(boss3Image, boss3AttackImage);
  bossImages.add(boss3);

  // 加載 Boss_4 的普通圖片與攻擊圖片，並創建 BossImage 對象
  PImage boss4Image = loadImage("Boss_4.png");
  PImage boss4AttackImage = loadImage("Boss_4_attack.png");
  BossImage boss4 = new BossImage(boss4Image, boss4AttackImage);
  bossImages.add(boss4);

  // 隨機打亂 Boss 圖片列表
  Collections.shuffle(bossImages);
}
