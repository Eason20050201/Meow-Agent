int lastEnemySpawnAdjustedTime = 0;
int bossSpawnStartTime = 0;

// 基本敵人類別，包含所有敵人共用的屬性和方法
class Enemy {
  PImage image;           // 敵人的圖片
  float x, y;             // 敵人的位置
  float prevX, prevY;     // 敵人上一幀的位置
  float size;       // 敵人的大小
  float speed = random(1, 3); // 隨機速度
  boolean facingRight = true; // 面向方向
  int health;             // 敵人的血量
  int attackInterval = 5000; // 每次攻擊間隔（毫秒）
  int lastAttackTime = 0;

  Enemy(PImage img, int health, int size) {
    this.image = img;
    this.health = health;
    this.size = size;

    // 隨機選擇敵人生成位置的邊界
    int side = int(random(4));
    if (side == 0) {
      x = 0;
      y = random(mapHeight);
    } else if (side == 1) {
      x = mapWidth;
      y = random(mapHeight);
    } else if (side == 2) {
      x = random(mapWidth);
      y = 0;
    } else {
      x = random(mapWidth);
      y = mapHeight;
    }

    // 初始化上一幀位置
    prevX = x;
    prevY = y;
  }

  // 繪製敵人與血條
  void display() {
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);

    if (facingRight) {
      // 水平翻轉座標系
      scale(-1, 1);
      // 繪製圖片
      image(image, 0, 0, size, size);
    } else {
      // 直接繪製，不翻轉
      image(image, 0, 0, size, size);
    }
    popMatrix();

    // 顯示血條
    displayHealthBar();
  }

  // 繪製血條
  void displayHealthBar() {
    float healthBarWidth = 50;
    float healthBarHeight = 5;
    float healthFillWidth = map(health, 0, getMaxHealth(), 0, healthBarWidth);

    rectMode(CORNER);
    stroke(0);
    strokeWeight(1);
    // 背景條
    fill(255, 0, 0);
    rect(x - healthBarWidth / 2, y - size / 2 - 10, healthBarWidth, healthBarHeight);

    // 血量條
    fill(0, 255, 0);
    rect(x - healthBarWidth / 2, y - size / 2 - 10, healthFillWidth, healthBarHeight);
  }

  // 獲取敵人的最大血量（可被覆寫）
  int getMaxHealth() {
    return 100; // 基本敵人的最大血量
  }

  // 讓敵人追蹤玩家
  void chase(Agent agent) {
    // 計算移動方向
    float dx = agent.x - x;
    float dy = agent.y - y;
    float angle = atan2(dy, dx);

    // 保存當前的位置作為上一幀位置
    prevX = x;
    prevY = y;

    // 更新位置
    x += cos(angle) * speed;
    y += sin(angle) * speed;

    // 根據 x 軸的移動方向更新 facingRight
    if (x - prevX > 0) {
      facingRight = true; // 向右移動，需要翻轉圖片
    } else if (x - prevX < 0) {
      facingRight = false; // 向左移動，圖片無需翻轉
    }
    // 如果 x - prevX == 0，不改變 facingRight 的值
  }
  
  // 通用攻擊檢查
  void tryAttack() {
    if (millis() - lastAttackTime >= attackInterval) {
      attack();
      lastAttackTime = millis();
    }
  }

  // 攻擊行為（子類覆寫）
  void attack() {
    // 默認攻擊為空，可在子類中覆寫
  }
}


// Goblin 類別，掉落 greenexp
class Goblin extends Enemy {
  Goblin(PImage img) {
    super(img, 100 * (bossDefeatedCount + 1), 100); // Goblin 血量 碰撞範圍
  }

  @Override
    int getMaxHealth() {
    return 100 * (bossDefeatedCount + 1);
  }
}


// GoblinMage 類別，掉落 greenexp
class GoblinMage extends Enemy {
  ArrayList<EnemyBullet> mageBalls; // 存放攻擊物件的列表

  GoblinMage(PImage img) {
    super(img, 200 * (bossDefeatedCount + 1), 100); // GoblinMage 血量 碰撞範圍
    mageBalls = new ArrayList<>();
  }
  
  @Override
    int getMaxHealth() {
    return 200 * (bossDefeatedCount + 1);
  }

  @Override
  void display() {
    super.display(); // 繪製敵人
    // 繪製攻擊物件
    for (int i = mageBalls.size() - 1; i >= 0; i--) {
      EnemyBullet ball = mageBalls.get(i);
      ball.update();
      ball.display();

      // 檢查攻擊是否超出螢幕
      if (ball.isOffScreen()) {
        mageBalls.remove(i);
      } else if (ballHitsAgent(ball)) {
        agent.lives-= 1; // 玩家損失生命
        soundManager.playSound("PlayerHurt", 0.5f);
        mageBalls.remove(i);
      }
    }
  }

  void attack() {
      PVector direction = PVector.sub(new PVector(agent.x, agent.y), new PVector(x, y));
      direction.setMag(5);
      mageBalls.add(new EnemyBullet(x, y, direction, loadImage("MageBall.png"), 1));
  }

  boolean ballHitsAgent(EnemyBullet ball) {
    return dist(ball.x, ball.y, agent.x, agent.y) < (agent.size / 2);
  }
}



// GoblinBoss 類別，掉落 yellowexp
class GoblinBoss extends Enemy {
  GoblinBoss(PImage img) {
    super(img, 300 * (bossDefeatedCount + 1), 100); // GoblinBoss 血量 碰撞範圍
  }

  @Override
    int getMaxHealth() {
    return 300 * (bossDefeatedCount + 1);
  }
}

// 第二關的敵人類別
class BigRobot extends Enemy {
  BigRobot(PImage img) {
    super(img, 500 * (bossDefeatedCount + 1), 100); // 設定血量和大小
  }

  @Override
  int getMaxHealth() {
    return 500 * (bossDefeatedCount + 1);
  }
}

class RobotMantis extends Enemy {
  RobotMantis(PImage img) {
    super(img, 400 * (bossDefeatedCount + 1), 100);
  }

  @Override
  int getMaxHealth() {
    return 400 * (bossDefeatedCount + 1);
  }
}

class Tank extends Enemy {
  ArrayList<EnemyBullet> tankBullets; // 存放炮彈的列表

  Tank(PImage img) {
    super(img, 300 * (bossDefeatedCount + 1), 100); // Tank 血量 碰撞範圍
    tankBullets = new ArrayList<>();
  }
  @Override
    int getMaxHealth() {
    return 300 * (bossDefeatedCount + 1);
  }

  @Override
  void display() {
    super.display(); // 繪製敵人
    // 繪製炮彈
    for (int i = tankBullets.size() - 1; i >= 0; i--) {
      EnemyBullet bullet = tankBullets.get(i);
      bullet.update();
      bullet.display();

      // 檢查炮彈是否超出螢幕
      if (bullet.isOffScreen()) {
        tankBullets.remove(i);
      } else if (bulletHitsAgent(bullet)) {
        agent.lives -= 1; // 玩家損失生命
        soundManager.playSound("PlayerHurt", 0.5f);
        tankBullets.remove(i);
      }
    }
  }

  void attack() {
      PVector direction = PVector.sub(new PVector(agent.x, agent.y), new PVector(x, y));
      direction.setMag(3);
      tankBullets.add(new EnemyBullet(x, y, direction, loadImage("tank_attack.png"), 1));
  }

  boolean bulletHitsAgent(EnemyBullet bullet) {
    return dist(bullet.x, bullet.y, agent.x, agent.y) < (agent.size / 2);
  }
}



// 第三關的敵人類別
class Scorpion extends Enemy {
  Scorpion(PImage img) {
    super(img, 900 * (bossDefeatedCount + 1), 100);
  }

  @Override
  int getMaxHealth() {
    return 900 * (bossDefeatedCount + 1);
  }
}

class Snake extends Enemy {
  Snake(PImage img) {
    super(img, 800 * (bossDefeatedCount + 1), 100);
  }

  @Override
  int getMaxHealth() {
    return 800 * (bossDefeatedCount + 1);
  }
}

class Spider extends Enemy {
  ArrayList<EnemyBullet> spiderWebs; // 存放毒網的列表

  Spider(PImage img) {
    super(img, 800 * (bossDefeatedCount + 1), 100); // Spider 血量 碰撞範圍
    spiderWebs = new ArrayList<>();
  }
  
  @Override
    int getMaxHealth() {
    return 800 * (bossDefeatedCount + 1);
  }

  @Override
  void display() {
    super.display(); // 繪製敵人
    // 繪製毒網
    for (int i = spiderWebs.size() - 1; i >= 0; i--) {
      EnemyBullet web = spiderWebs.get(i);
      web.update();
      web.display();

      // 檢查毒網是否超出螢幕
      if (web.isOffScreen()) {
        spiderWebs.remove(i);
      } else if (webHitsAgent(web)) {
        agent.lives -= 1; // 玩家損失生命
        soundManager.playSound("PlayerHurt", 0.5f);
        spiderWebs.remove(i);
      }
    }
  }

  void attack() {
      PVector direction = PVector.sub(new PVector(agent.x, agent.y), new PVector(x, y));
      direction.setMag(4);
      spiderWebs.add(new EnemyBullet(x, y, direction, loadImage("spider_attack.png"), 1));
  }

  boolean webHitsAgent(EnemyBullet web) {
    return dist(web.x, web.y, agent.x, agent.y) < (agent.size / 2);
  }
}



// Boss
class BossImage {
  PImage normalImage;
  PImage attackImage;

  BossImage(PImage normalImage, PImage attackImage) {
    this.normalImage = normalImage;
    this.attackImage = attackImage;
  }
}

int attackDuration = 500;  // 攻擊持續時間
int attackStartTime = 0;   // 攻擊開始時間

class Boss extends Enemy {
  PImage attackImage;
  boolean isAttacking = false;
  int attackInterval = 3000;
  int lastAttackTime = 0;

  ArrayList<BossBullet> bossBullets;

  Boss(PImage img, PImage attackImg) {
    super(img, 5000 * (bossDefeatedCount + 1), 300);  // Boss 血量 碰撞範圍
    this.attackImage = attackImg;
    bossBullets = new ArrayList<BossBullet>();
  }

  @Override
    int getMaxHealth() {
    return 5000 * (bossDefeatedCount + 1);
  }

  @Override
    void display() {
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);

    if (facingRight) {
      scale(-1, 1);
    }

    image(image, 0, 0, 300, 300);

    popMatrix();

    displayHealthBar();
  }

  void update() {
    chase(agent);

    if (millis() - lastAttackTime >= attackInterval) {
      attack();
      lastAttackTime = millis();
    }

    for (int i = bossBullets.size() - 1; i >= 0; i--) {
      BossBullet bullet = bossBullets.get(i);
      bullet.update();
      bullet.display();

      if (bullet.isOffScreen()) {
        bossBullets.remove(i);
      } else if (bulletHitsAgent(bullet)) {
        agent.lives -= bullet.damage;
        soundManager.playSound("PlayerHurt", 0.5f);
        bossBullets.remove(i);
      }
    }
  }

  boolean bulletHitsAgent(BossBullet bullet) {
    float distance = dist(bullet.x, bullet.y, agent.x, agent.y);
    return distance < (bullet.size / 2 + agent.size / 2);
  }

  void attack() {
    PVector direction = PVector.sub(new PVector(agent.x, agent.y), new PVector(x, y));
    direction.setMag(5);

    BossBullet bossBullet = new BossBullet(x, y, direction, attackImage, 20);
    bossBullets.add(bossBullet);
  }
}


class BossBullet {
  float x, y;
  PVector velocity;
  PImage image;
  float size = 50;
  int damage;

  BossBullet(float x, float y, PVector velocity, PImage image, int damage) {
    this.x = x;
    this.y = y;
    this.velocity = velocity;
    this.image = image;
    this.damage = damage;

    // 輸出 Boss 攻擊傷害
    println("BossBullet created with damage: " + damage);
  }

  void update() {
    x += velocity.x;
    y += velocity.y;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    float angle = atan2(velocity.y, velocity.x);
    rotate(angle);
    imageMode(CENTER);
    image(image, 0, 0, size, size);
    popMatrix();
  }

  boolean isOffScreen() {
    return x < 0 || x > mapWidth || y < 0 || y > mapHeight;
  }
}


// 生成 Boss
void spawnBoss() {
  if (!bossImages.isEmpty()) {
    BossImage bossImage = bossImages.remove(0); // 取出一个 BossImage 对象
    Boss newBoss = new Boss(bossImage.normalImage, bossImage.attackImage);
    enemies.add(newBoss);
    bossesSpawned++;
    println("生成了一隻新的 Boss！");
  }
}


// 檢查 Boss 是否已經被擊敗
void checkBossDefeated() {
  // 當 Boss 被擊敗並且敵人清空時，結束 Boss 階段
  if (isBossPhase && bossesSpawned > 0 && enemies.size() == 0) {
    agent.collectEnergy("Boss");
    bossDefeatedCount++;
    endBossPhase();
  }
}

// 啟動 Boss 提示
void startBossAlert() {
  isBossAlertActive = true; // 啟用提示圖片
  bossAlertStartTime = millis(); // 記錄開始時間
}

// 繪製提示圖片（在主遊戲迴圈中調用）
void drawBossAlert() {
  if (isBossAlertActive) {
    imageMode(CENTER);
    int elapsedTime = millis() - bossAlertStartTime;

    if (elapsedTime < bossAlertDuration) {
      // 控制閃爍效果
      if ((elapsedTime / bossAlertBlinkFrequency) % 2 == 0) {
        image(bossAlertImage, width / 2 , height / 3);
      }
    } else {
      // 提示圖片時間結束
      isBossAlertActive = false;
    }
  }
}

// 開始 Boss 階段
void startBossPhase() {
  isBossPhase = true;
  bossSpawnStartTime = getAdjustedGameTime(); // 記錄 Boss 階段的開始時間
  enemies.clear();    // 清除所有敵人
  spawnBoss(); // 生成 Boss
  startBossAlert(); // 啟動 Boss 提示圖片
  soundManager.playSound("BossAlert", 0.8);  // 警報音效
  println("開始 Boss 階段！");
}


// 結束 Boss 階段並恢復小怪生成
void endBossPhase() {
  isBossPhase = false;
  lastEnemySpawnAdjustedTime = getAdjustedGameTime(); // 重置小怪生成的計時
  println("Boss 階段結束，恢復小怪生成。");
}


int getAdjustedGameTime() {
    return millis() - startTime - totalPausedTime - totalSkillTime;
}


// 隨機生成不同類型的敵人
void spawnEnemy() {
  if (currentLevel == 0) {
    // 第一關怪物
    int enemyType = int(random(3));
    if (enemyType == 0) enemies.add(new Goblin(Goblin));
    else if (enemyType == 1) enemies.add(new GoblinBoss(GoblinBoss));
    else if (enemyType == 2) enemies.add(new GoblinMage(GoblinMage));
  } else if (currentLevel == 1) {
    // 第二關怪物
    int enemyType = int(random(3));
    if (enemyType == 0) enemies.add(new BigRobot(bigRobotImg));
    else if (enemyType == 1) enemies.add(new RobotMantis(robotMantisImg));
    else if (enemyType == 2) enemies.add(new Tank(tankImg));
  } else if (currentLevel == 2) {
    // 第三關怪物
    int enemyType = int(random(3));
    if (enemyType == 0) enemies.add(new Scorpion(scorpionImg));
    else if (enemyType == 1) enemies.add(new Snake(snakeImg));
    else if (enemyType == 2) enemies.add(new Spider(spiderImg));
  }
}

void enemyDefeated(Enemy enemy) {
  // 第一關掉落經驗
  if (currentLevel == 0) {
    soundManager.playSound("EnemyHurt", 0.45);
    if (enemy instanceof Goblin || enemy instanceof GoblinMage) {
      // Goblin 和 GoblinMage 掉落 greenexp
      greenExps.add(new GreenExp(enemy.x, enemy.y, greenExpImg));
    } else if (enemy instanceof GoblinBoss) {
      // GoblinBoss 掉落 yellowexp
      yellowExps.add(new YellowExp(enemy.x, enemy.y, yellowExpImg));
    }
  }

  // 第二關掉落經驗
  else if (currentLevel == 1) {
    soundManager.playSound("EnemyHurt2", 0.45);
    if (enemy instanceof Tank) {
      // Tank 掉落 greenexp
      greenExps.add(new GreenExp(enemy.x, enemy.y, greenExpImg));
    } else if (enemy instanceof BigRobot || enemy instanceof RobotMantis) {
      // BigRobot 和 RobotMantis 掉落 greenexp
      yellowExps.add(new YellowExp(enemy.x, enemy.y, yellowExpImg));
    }
  }

  // 第三關掉落經驗
  else if (currentLevel == 2) {
    soundManager.playSound("EnemyHurt3", 0.45);
    if (enemy instanceof Spider|| enemy instanceof Snake) {
      // Scorpion 和 Snake 掉落 yellowexp
      yellowExps.add(new YellowExp(enemy.x, enemy.y, yellowExpImg));
    } else if (enemy instanceof Scorpion) {
      // Spider 掉落 blueexp
      blueExps.add(new BlueExp(enemy.x, enemy.y, blueExpImg));
    }
  }

  // 增加擊殺數
  enemyKillCount++;
}


void displayKillCount() {
  imageMode(CENTER);
  image(KillImg, 25, 110, 50, 50);
  fill(0);  // 設定文字顏色
  textFont(TCfont);
  textSize(20);
  textAlign(LEFT, TOP);
  text(" : " + enemyKillCount, 40, 105);  // 在左上角顯示擊殺數
}

class EnemyBullet {
  float x, y;
  PVector velocity;
  PImage image;
  float size = 30;
  int damage;

  EnemyBullet(float x, float y, PVector velocity, PImage image, int damage) {
    this.x = x;
    this.y = y;
    this.velocity = velocity;
    this.image = image;
    this.damage = damage;
  }

  void update() {
    x += velocity.x;
    y += velocity.y;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    float angle = atan2(velocity.y, velocity.x);
    rotate(angle);
    imageMode(CENTER);
    image(image, 0, 0, size, size);
    popMatrix();
  }

  boolean isOffScreen() {
    return x < 0 || x > mapWidth || y < 0 || y > mapHeight;
  }
}
