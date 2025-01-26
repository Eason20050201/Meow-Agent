class Agent {
  // 位置和基本屬性
  float x, y;                        // 角色的位置 (x, y) 座標
  float size;                        // 角色的大小
  PVector velocity;                  // 速度向量，用於儲存角色的移動速度
  PVector acceleration;              // 加速度向量，用於更新速度
  float maxSpeed = 10;               // 角色的最大速度限制
  float accelerationMagnitude = 0.5; // 加速度的大小
  float friction = 0.9;              // 摩擦係數，降低速度以模擬摩擦
  int lives = 500;                   // 角色的生命值
  int maxLives = 500;                // 角色的最大生命值

  // 武器屬性
  Weapon weapon;                    // 武器，應與不同攻擊方式結合
  boolean showWeaponChoice = false; // 用來控制顯示武器選擇
  ArrayList<Weapon> weaponList = new ArrayList<>();
  ArrayList<Weapon> weaponChoices = new ArrayList<>(); // 儲存升級後的武器選項

  // 圖片和動畫屬性
  PImage standingImage;            // 角色站立時的圖片
  PImage walkImage1;               // 角色行走時的圖片
  int walkFrameCounter = 0;        // 計數器，用於切換步伐動畫
  boolean facingRight = true;      // 判斷角色的面向方向

  // 能量條屬性
  float energy = 0;                // 當前能量值
  int energyLevel = 1;             // 能量等級
  float maxEnergy = 100;           // 每個等級所需的最大能量

  // 初始化角色的位置、大小、圖片等屬性
  Agent(float startX, float startY, float s, PImage standing, PImage walk1) {
    x = startX;
    y = startY;
    size = s;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    standingImage = standing;
    walkImage1 = walk1;
  }

  // 重設角色狀態
  void reset() {
    x = width / 2;
    y = height / 2;
    velocity.set(0, 0);
    acceleration.set(0, 0);
    lives = maxLives;          // 重置生命值
    energy = 0;                // 重置能量
    energyLevel = 1;           // 重置能量等級
    maxEnergy = 80;           // 重置能量最大值
    bossDefeatedCount = 0;     // 重置 Boss 數量

    // 初始化各種武器，每個武器都會傳入相應的圖片、傷害、攻擊間隔
    normalAttack = new NormalAttack  (1000, bulletImg, enemies, 50);            // 普攻 傷害 50  間隔 1 秒
    cdGuide      = new cdGuideWeapon (1000, agent, guardianImg, enemies, 10);   // 守護 傷害 10  間隔 1 秒
    football     = new IngameFootball(1000, footballImg, 300);                  // 足球 傷害 300 間隔 1 秒
    poison       = new IngamePoison  (2000, bottleImg, poisonImg, 5);           // 毒藥 傷害 5   間隔 2 秒
    powerCircle  = new PowerCircle   (1000, agent, 150, powerCircleImage, 5);   // 力場 傷害 5  間隔 1 秒
    lightning    = new Lightning     (3000, enemies, lightningImage, 300, 100); // 雷電 傷害 300 間隔 3 秒 範圍 100
    
    weaponList.clear();                 // 清除武器列表
    
    // 重置所有武器的等级
    for (Weapon weapon : weaponList) {
      weapon.resetLevel();
    }
    
    agent.weaponList.add(normalAttack); // 設置初始武器為 normalAttack，可以根據需求替換為其他武器
    //agent.weaponList.add(powerCircle);  // 測試用
   
    //agent.weaponList.add(poison);
    //agent.weaponList.add(football);
    //agent.weaponList.add(cdGuide);
    //agent.weaponList.add(lightning);

    showWeaponChoice = false;           // 隱藏武器選擇介面
    println("角色重置完成！");
  }

  // 返回已經打敗的 Boss 數量
  int getBossDefeatedCount() {
    return bossDefeatedCount;
  }

  // 顯示角色的圖片
  void display() {
    imageMode(CENTER);
    pushMatrix();
    translate(x, y); // 將畫布移至角色位置

    // 根據面向翻轉角色
    if (!facingRight) {
      scale(-1, 1); // 水平翻轉
    }

    // 切換站立或步伐圖片
    if (velocity.mag() > 0.1) {
      if ((walkFrameCounter / 10) % 2 == 0) { // 每 10 幀切換步伐
        image(walkImage1, 0, 0, size, size);
      } else {
        image(standingImage, 0, 0, size, size);
      }
      walkFrameCounter++;
    } else {
      image(standingImage, 0, 0, size, size); // 靜止時顯示站立圖片
      walkFrameCounter = 0;
    }

    popMatrix();
  }

  // 應用外部力量以改變角色的加速度
  void applyForce(PVector force) {
    // 根據力的方向更新面向
    if (force.x < 0) {
      facingRight = true;
    } else if (force.x > 0) {
      facingRight = false;
    }
    acceleration.add(force);  // 將力添加到加速度向量
  }

  // 更新角色的運動狀態
  void update() {
    velocity.add(acceleration);  // 加速度影響速度
    velocity.limit(maxSpeed);    // 限制速度不超過最大值
    x += velocity.x;             // 更新位置
    y += velocity.y;

    velocity.mult(friction);     // 應用摩擦力，逐漸減速

    // 若速度接近零，將其設為零以避免浮點數誤差
    if (velocity.mag() < 0.01) {
      velocity.set(0, 0);
    }

    acceleration.mult(0);        // 重置加速度

    // 邊界檢查，確保角色不會超出地圖範圍
    x = constrain(x, 0, mapWidth);
    y = constrain(y, 0, mapHeight);
  }

  // 顯示能量條和等級
  void displayEnergyBar() {
    pushMatrix(); // 保存當前畫布狀態，避免受偏移影響

    float energyBarWidth = width * 2 / 3; // 能量條寬度為畫面寬度的 2/3
    float energyFillWidth = map(energy, 0, maxEnergy, 0, energyBarWidth);
    float energyBarX = (width - energyBarWidth) / 2; // 中間顯示
    float energyBarY = 20; // 距離畫面頂部 20 像素

    // 畫出能量條背景
    fill(200);
    rect(energyBarX, energyBarY, energyBarWidth, 20);

    // 畫出能量條填充
    fill(0, 255, 0);
    rect(energyBarX, energyBarY, energyFillWidth, 20);

    // 顯示能量等級文字
    fill(0);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Level: " + energyLevel, energyBarX + energyBarWidth / 2, energyBarY + 10);
    
    // 顯示時間
    fill(0);
    textSize(26);
    textAlign(CENTER, TOP);
    text(getFormattedTime(), width / 2, energyBarY + 35);
    
    popMatrix(); // 恢復畫布狀態
  }

  // 增加能量，並檢查是否需要提升等級
  void collectEnergy(String type) {
    if (type.equals("green")) {
      energy += 15;
    } else if (type.equals("yellow")) {
      energy += 30;
    } else if (type.equals("blue")) {
      energy += 60; // BlueExp 提供最高的能量
    } else if (type.equals("Boss")) {
      energy += maxEnergy;
    }
  
    if (energy >= maxEnergy) {
      soundManager.playSound("Upgrade", 1); 
      
      energyLevel++;
      energy -= maxEnergy;
      maxEnergy *= 1.2;
      if(spawnRate >= 16){
        spawnRate -= 1;
      }
  
      // 暫停遊戲並顯示武器選擇
      showWeaponChoice = true;
      showUpgradeQuiz(); // 顯示升級問題
      generateWeaponChoices(); // 生成三個隨機武器選項
    }
  }


  void generateWeaponChoices() {
    // 定義所有可用的武器類
    ArrayList<Class<? extends Weapon>> allWeaponClasses = new ArrayList<>(Arrays.asList(
      NormalAttack.class,   // 普通攻擊類
      IngameFootball.class, // 足球類
      IngamePoison.class,   // 毒藥類
      cdGuideWeapon.class,  // 守護武器類
      PowerCircle.class,    // 能量圈類
      Lightning.class       // 閃電類
      ));

    // 隨機打亂武器類列表
    Collections.shuffle(allWeaponClasses);

    // 準備存儲武器選擇
    weaponChoices = new ArrayList<>();
    agent.weaponChoices.clear();

    // 迭代武器類列表，直到收集到 3 個不同的武器
    for (int i = 0; i < allWeaponClasses.size() && weaponChoices.size() < 3; i++) {
      Class<? extends Weapon> weaponClass = allWeaponClasses.get(i);

      // 檢查當前選擇中是否已包含該武器類，避免重複
      boolean alreadyInChoices = false;
      for (Weapon w : weaponChoices) {
        if (w.getClass() == weaponClass) {
          alreadyInChoices = true;
          break;
        }
      }

      if (!alreadyInChoices) {
        // 創建武器實例並添加到選擇列表
        Weapon weaponInstance = createWeaponInstance(weaponClass);
        if (weaponInstance != null) {
          weaponChoices.add(weaponInstance);
        }
      }
    }
  }

  // 輔助方法，用於根據武器類創建實例
  Weapon createWeaponInstance(Class<? extends Weapon> weaponClass) {
    if (weaponClass == NormalAttack.class) {
      return normalAttack; // 普通攻擊
    } else if (weaponClass == IngameFootball.class) {
      return football;      // 足球攻擊
    } else if (weaponClass == IngamePoison.class) {
      return poison; // 毒藥攻擊
    } else if (weaponClass == cdGuideWeapon.class) {
      return cdGuide; // 守護武器
    } else if (weaponClass == PowerCircle.class) {
      return powerCircle; // 能量圈攻擊
    } else if (weaponClass == Lightning.class) {
      return lightning; // 閃電攻擊
    }
    return null;
  }

  boolean hasWeapon(Weapon weapon) {
    for (Weapon w : weaponList) {
      if (w.getClass() == weapon.getClass()) {
        return true;
      }
    }
    return false;
  }

  // 添加或升級武器的方法
  void addOrUpgradeWeapon(Weapon newWeapon) {
    boolean alreadyOwned = false;

    for (Weapon weapon : weaponList) {
      if (weapon.getClass() == newWeapon.getClass()) {
        alreadyOwned = true;
        weapon.levelUp(); // 調用已有武器的 levelUp() 方法
        println("已經擁有武器，進行升級：");
        break;
      }
    }

    if (!alreadyOwned) {
      weaponList.add(newWeapon); // 如果未拥有，添加到列表
      println("獲得新武器：" + newWeapon.getClass().getSimpleName());
    }

    // 輸出當前武器列表
    println("當前武器列表：");
    for (Weapon weapon : weaponList) {
      println("- " + weapon.getClass().getSimpleName());
    }
  }

  Weapon getWeaponByClass(Class<? extends Weapon> weaponClass) {
    for (Weapon weapon : weaponList) {
      if (weapon.getClass() == weaponClass) {
        return weapon;
      }
    }
    return null;
  }


  void displayHealthBar(float offsetX, float offsetY) {
    float healthBarWidth = 50; // 血量條的寬度
    float healthBarHeight = 6; // 血量條的高度
    float healthBarX = x + offsetX - healthBarWidth / 2; // 根據偏移修正 X 座標
    float healthBarY = y + offsetY + size / 2 + 10;      // 根據偏移修正 Y 座標，顯示在角色下方

    // 背景條（灰色）
    strokeWeight(1);
    stroke(0);
    rectMode(CORNER);
    fill(200);
    rect(healthBarX, healthBarY, healthBarWidth, healthBarHeight);

    // 生命值條（紅色）
    float healthFillWidth = map(lives, 0, maxLives, 0, healthBarWidth); // 根據生命值計算填充寬度
    fill(255, 0, 0);
    rect(healthBarX, healthBarY, healthFillWidth, healthBarHeight);
  }

  // 當角色與敵人碰撞時，每次生命 -1 
  void loseLife() {
    lives--;
    if( lives % 20 == 0 )
      soundManager.playSound("PlayerHurt", 0.5f);
  }

  // 檢查角色是否還有生命值
  boolean isAlive() {
    return lives > 0;
  }
}

// 目前生命
/*void displayLives() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text("Lives : " + agent.lives, 5, 35);
}*/

class GreenExp {
  float x, y;
  PImage image;

  GreenExp(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.image = img;
  }

  void display() {
    imageMode(CENTER);
    image(image, x, y, 30, 30); // GreenExp 大小為 30x30
  }
}

class YellowExp {
  float x, y;
  PImage image;

  YellowExp(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.image = img;
  }

  void display() {
    imageMode(CENTER);
    image(image, x, y, 40, 40); // YellowExp 大小為 40x40，比 GreenExp 大
  }
}

class BlueExp {
  float x, y;
  PImage image;

  BlueExp(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.image = img;
  }

  void display() {
    imageMode(CENTER);
    image(image, x, y, 44, 44); // BlueExp 大小為 50x50，比 YellowExp 大
  }
}

void spawnExp() {
  // 設定每幀 1% 的機率生成一個 greenexp
  if (random(1) < 0.03) {
    float x = random(mapWidth);
    float y = random(mapHeight);
    greenExps.add(new GreenExp(x, y, greenExpImg));
  }
}

void checkEnergyCollection(Agent agent) {
  // 檢查角色是否碰觸到 greenexp
  for (int i = greenExps.size() - 1; i >= 0; i--) {
    GreenExp exp = greenExps.get(i);
    float distance = dist(agent.x, agent.y, exp.x, exp.y);

    if (distance < (agent.size / 2 + 15)) { // 碰觸範圍，15 為綠色能量道具半徑
      agent.collectEnergy("green"); // 增加綠色能量
      greenExps.remove(i);          // 收集後移除該能量道具
    }
  }

  // 檢查角色是否碰觸到 yellowexp
  for (int i = yellowExps.size() - 1; i >= 0; i--) {
    YellowExp exp = yellowExps.get(i);
    float distance = dist(agent.x, agent.y, exp.x, exp.y);

    if (distance < (agent.size / 2 + 20)) { // 碰觸範圍，20 為黃色能量道具半徑
      agent.collectEnergy("yellow"); // 增加黃色能量
      yellowExps.remove(i);          // 收集後移除該能量道具
    }
  }

  // 檢查角色是否碰觸到 blueexp
  for (int i = blueExps.size() - 1; i >= 0; i--) {
    BlueExp exp = blueExps.get(i);
    float distance = dist(agent.x, agent.y, exp.x, exp.y);

    if (distance < (agent.size / 2 + 22)) { // 碰觸範圍，25 為藍色能量道具半徑
      agent.collectEnergy("blue"); // 增加藍色能量
      blueExps.remove(i);          // 收集後移除該能量道具
    }
  }
}
