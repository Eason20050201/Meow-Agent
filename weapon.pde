Weapon cdGuide, football, poison, normalAttack, powerCircle, lightning; // 各個武器設為全域變數

// 抽象武器類別，定義所有武器的共用屬性和方法
abstract class Weapon {
  int fireInterval;   // 發射間隔時間（毫秒）
  int lastShotTime;   // 上一次發射的時間
  int damage;         // 武器的傷害值
  int level = 1;      // 武器等級

  // 建構子，用於初始化發射間隔和傷害
  Weapon(int interval, int damage) {
    this.fireInterval = interval;
    this.lastShotTime = 0;
    this.damage = damage;
  }

  // 檢查武器是否可以發射
  boolean canFire() {
    if (millis() - lastShotTime > fireInterval) {
      lastShotTime = millis();
      return true;
    }
    return false;
  }

  // 重置武器等級
  void resetLevel() {
    level = 1;
  }

  // 升級武器等級的抽象方法，由子類別實現
  abstract void levelUp();

  // 發射子彈的抽象方法，由子類別實現
  abstract ArrayList<Bullet> fire(float startX, float startY);

  // 顯示武器效果的抽象方法，由子類別實現
  abstract void display();

  // 獲取武器圖示的抽象方法，由子類別實現
  abstract PImage getImage();

  // 獲取選擇武器時的圖示，由子類別實現
  abstract PImage getChoiceImage();

  // 獲取武器描述的抽象方法，由子類別實現
  abstract String getDescription();

  // 獲取武器下一級描述的抽象方法，由子類別實現
  abstract String getNextLevelDescription();
}



// 基本攻擊武器類別，實現瞄準最近敵人的發射行為
class NormalAttack extends Weapon {
  PImage bulletImage;             // 子彈圖片
  ArrayList<Enemy> enemies;       // 敵人列表

  // 建構子，初始化發射間隔、子彈圖片、敵人列表和傷害
  NormalAttack(int interval, PImage bulletImage, ArrayList<Enemy> enemies, int damage) {
    super(interval, damage);
    this.bulletImage = bulletImage;
    this.enemies = enemies;
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    damage *= 2; // 傷害翻倍
  }

  // 發射子彈，瞄準最近的敵人
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    ArrayList<Bullet> bullets = new ArrayList<Bullet>();
    
    soundManager.playSound("NormalAttack", 0.5f);

    // 找到最近的敵人
    Enemy nearestEnemy = findNearestEnemy(startX, startY);
    if (nearestEnemy != null) {
      // 計算指向敵人的方向
      PVector target = new PVector(nearestEnemy.x, nearestEnemy.y);
      PVector direction = PVector.sub(target, new PVector(startX, startY));
      direction.setMag(5); // 設定子彈速度

      // 創建子彈
      bullets.add(new NormalBullet(startX, startY, direction, bulletImage, damage));
    }

    return bullets;
  }

  // 顯示武器效果（如果需要）
  @Override
  void display() {
    // 基本攻擊武器無需特別顯示效果
  }

  @Override
  PImage getImage() {
    return pausedNormalAttackIcon;
  }

  @Override
  PImage getChoiceImage() {
    return ChoicebulletImg;
  }

  @Override
  String getDescription() {
    return "射出一枚子彈";
  }

  @Override
  String getNextLevelDescription() {
    return "升級傷害翻倍";
  }

  // 找到最近的敵人
  private Enemy findNearestEnemy(float startX, float startY) {
    Enemy nearestEnemy = null;
    float nearestDistance = Float.MAX_VALUE;

    for (Enemy enemy : enemies) {
      float distance = PVector.dist(new PVector(startX, startY), new PVector(enemy.x, enemy.y));
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestEnemy = enemy;
      }
    }
    return nearestEnemy;
  }
}


// 足球武器類別，實現彈射效果
class IngameFootball extends Weapon {
  PImage bulletImage;         // 足球圖片
  int numberOfFootballs = 1;  // 足球數量
  float footballSpeed = 5;    // 足球速度

  // 建構子，初始化發射間隔、足球圖片和傷害
  IngameFootball(int interval, PImage bulletImage, int damage) {
    super(interval, damage);
    this.bulletImage = bulletImage;
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    switch (level) {
      case 2:
        numberOfFootballs++; // 增加足球數量
        break;
      case 3:
      case 4:
        footballSpeed += 2;  // 增加足球速度
        damage += 5;         // 增加傷害
        break;
      case 5:
        numberOfFootballs++; // 再次增加足球數量
        break;
      default:
        // 達到最高等級
        break;
    }
  }

  // 發射足球
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    ArrayList<Bullet> newBullets = new ArrayList<>();
    
    // 播放 Football 音效
    soundManager.playSound("Football", 0.6);
  
    for (int i = 0; i < numberOfFootballs; i++) {
      // 隨機方向發射足球
      float angle = random(0, TWO_PI);
      PVector direction = new PVector(cos(angle), sin(angle));
      direction.setMag(footballSpeed);

      newBullets.add(new BouncingBullet(startX, startY, direction, bulletImage, damage, 3));
    }
    return newBullets;
  }

  // 顯示武器效果（如果需要）
  @Override
  void display() {
    // 足球武器無需特別顯示效果
  }

  @Override
  PImage getImage() {
    return footballImg;
  }

  @Override
  PImage getChoiceImage() {
    return ChoicefootballImg;
  }

  @Override
  String getDescription() {
    return "丟出1個可以\n彈射的足球";
  }

  @Override
  String getNextLevelDescription() {
    String description = "";
    if (level + 1 == 2) {
      description = "增加1個足球";
    } else if (level + 1 == 3 || level + 1 == 4) {
      description = "增加足球飛行速度\n增加足球傷害";
    } else {
      description = "增加1個足球";
    }
    return description;
  }
}


// 毒藥灘獨立顯示
void displayPoisonPuddles() {
  for (Bullet bullet : bullets) {
    if (bullet instanceof ParabolicBullet) {
      ParabolicBullet poisonBullet = (ParabolicBullet) bullet;
      if (poisonBullet.hasTransformed && !poisonBullet.markForRemoval) {
        poisonBullet.display();
      }
    }
  }
}


// 毒藥瓶武器類別，實現拋物線軌跡和毒液池效果
class IngamePoison extends Weapon {
  PImage bottleImage;          // 毒藥瓶圖片
  PImage poisonImage;          // 毒液池圖片
  float poisonSize = 100;      // 毒液池大小
  int numberOfBottles = 2;     // 毒藥瓶數量

  // 建構子，初始化發射間隔、圖片和傷害
  IngamePoison(int interval, PImage bottleImage, PImage poisonImage, int damage) {
    super(interval, damage);
    this.bottleImage = bottleImage;
    this.poisonImage = poisonImage;
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    numberOfBottles++;
    poisonSize += 20;
    damage += 2;
  }

  // 發射毒藥瓶
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    ArrayList<Bullet> bullets = new ArrayList<>();

    for (int i = 0; i < numberOfBottles; i++) {
      // 隨機拋物線方向
      PVector randomDirection = new PVector(random(-4, 4), random(-8, -4));

      bullets.add(new ParabolicBullet(startX, startY, randomDirection, bottleImage, damage, poisonImage, poisonSize));
    }
    return bullets;
  }

  // 顯示武器效果（如果需要）
  @Override
  void display() {
    // 毒藥瓶武器無需特別顯示效果
  }

  @Override
  PImage getImage() {
    return bottleImg;
  }

  @Override
  PImage getChoiceImage() {
    return ChoicebottleImg;
  }

  @Override
  String getDescription() {
    return "丟出2個毒藥瓶";
  }

  @Override
  String getNextLevelDescription() {
    return "增加1個瓶子\n增加毒藥範圍\n傷害增加";
  }
}


// 守衛者武器類別，生成環繞 Agent 旋轉的守衛者
class cdGuideWeapon extends Weapon {
  ArrayList<Guardian> guardians = new ArrayList<>(); // 守衛者列表
  ArrayList<Enemy> enemies;                          // 敵人列表
  Agent agent;                                       // 參考的 Agent
  PImage guardianImage;                              // 守衛者圖片
  float rotationSpeed = 0.05f;                       // 初始旋轉速度

  // 建構子，初始化守衛者和相關參數
  cdGuideWeapon(int interval, Agent agent, PImage guardianImage, ArrayList<Enemy> enemies, int damage) {
    super(interval, damage);
    this.agent = agent;
    this.guardianImage = guardianImage;
    this.enemies = enemies;

    // 初始化兩個守衛者，位於相反的角度
    guardians.add(new Guardian(agent, guardianImage, PI / 2, 150, damage, rotationSpeed));
    guardians.add(new Guardian(agent, guardianImage, -PI / 2, 150, damage, rotationSpeed));
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    damage += 5; // 增加傷害

    // 增加一個守衛者
    int numGuardians = guardians.size();
    float angleIncrement = TWO_PI / (numGuardians + 1);

    // 更新已有守衛者
    for (int i = 0; i < numGuardians; i++) {
      Guardian guardian = guardians.get(i);
      guardian.angle = i * angleIncrement;
      guardian.damage = this.damage;
      guardian.rotationSpeed = this.rotationSpeed;
    }

    // 添加新的守衛者
    float newGuardianAngle = numGuardians * angleIncrement;
    guardians.add(new Guardian(agent, guardianImage, newGuardianAngle, 150, damage, rotationSpeed));

    // 增加旋轉速度
    rotationSpeed += 0.02f;

    // 更新所有守衛者的旋轉速度
    for (Guardian guardian : guardians) {
      guardian.rotationSpeed = this.rotationSpeed;
    }
  }

  // 發射方法，守衛者武器不發射子彈
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    return new ArrayList<Bullet>();
  }

  // 顯示守衛者並檢查碰撞
  @Override
  void display() {
    for (Guardian guardian : guardians) {
      guardian.update();
      guardian.display();
      checkCollisionWithEnemies(guardian);
    }
  }

  @Override
  PImage getImage() {
    return guardianImg;
  }

  @Override
  PImage getChoiceImage() {
    return ChoiceguardianImg;
  }

  @Override
  String getDescription() {
    return "召喚2個環繞自\n身的守衛者";
  }

  @Override
  String getNextLevelDescription() {
    return "增加一個守衛者\n、轉速、傷害";
  }

  // 檢查守衛者與敵人的碰撞
  private void checkCollisionWithEnemies(Guardian guardian) {
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy enemy = enemies.get(i);
      float distance = dist(guardian.getX(), guardian.getY(), enemy.x, enemy.y);

      // 假設碰撞半徑為 50
      if (distance < 50) {
        enemy.health -= guardian.damage;

        if (enemy.health <= 0) {
          enemyDefeated(enemy);
          enemies.remove(i);
        }
      }
    }
  }
}


// 能量力場武器類別，生成環繞 Agent 的能量力場
class PowerCircle extends Weapon {
  Agent agent;                 // 參考的 Agent
  float radius;                // 力場半徑
  PImage circleImage;          // 力場圖片
  float rotationAngle = 0;     // 旋轉角度
  float rotationSpeed = 0.05f; // 旋轉速度

  // 建構子，初始化力場
  PowerCircle(int interval, Agent agent, float initialRadius, PImage circleImage, int damage) {
    super(interval, damage);
    this.agent = agent;
    this.radius = initialRadius;
    this.circleImage = circleImage;
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    radius += 20; // 增加半徑
    damage += 5;  // 增加傷害
  }

  // 發射方法，能量力場不發射子彈
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    return new ArrayList<Bullet>();
  }

  // 顯示能量力場並檢查碰撞
  @Override
  void display() {
    // 顯示力場
    pushMatrix();
    translate(agent.x, agent.y);
    rotate(rotationAngle);
    imageMode(CENTER);
    image(circleImage, 0, 0, radius * 2, radius * 2);
    popMatrix();

    // 更新旋轉角度
    rotationAngle += rotationSpeed;
    if (rotationAngle >= TWO_PI) {
      rotationAngle = 0;
    }

    // 檢查與敵人的碰撞
    checkCollisionWithEnemies();
  }

  @Override
  PImage getImage() {
    return powerCircleImage;
  }

  @Override
  PImage getChoiceImage() {
    return ChoicepowerCircleImage;
  }

  @Override
  String getDescription() {
    return "生成一個持續性\n的能量力場";
  }

  @Override
  String getNextLevelDescription() {
    return "面積增大\n傷害增加";
  }

  // 檢查力場與敵人的碰撞
  void checkCollisionWithEnemies() {
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy enemy = enemies.get(i);
      float distance = dist(agent.x, agent.y, enemy.x, enemy.y);
      float collisionDistance = (radius - 15) + (enemy.size / 3);
      if (distance < collisionDistance) {
        enemy.health -= damage;

        if (enemy.health <= 0) {
          enemyDefeated(enemy);
          enemies.remove(i);
        }
      }
    }
  }
}


// 閃電武器類別，在隨機敵人位置生成閃電效果
class Lightning extends Weapon {
  ArrayList<Enemy> enemies;          // 敵人列表
  PImage lightningImage;             // 閃電圖片
  float lightningDuration = 500;     // 閃電持續時間（毫秒）
  float lightningStartTime = -1;     // 閃電開始時間
  float lightningX, lightningY;      // 閃電位置
  int numberOfBolts = 1;             // 閃電數量
  float attackRadius;                // 攻擊範圍半徑

  // 建構子，初始化閃電武器
  Lightning(int interval, ArrayList<Enemy> enemies, PImage lightningImage, int damage, float radius) {
    super(interval, damage);
    this.enemies = enemies;
    this.lightningImage = lightningImage;
    this.attackRadius = radius;
  }

  // 升級武器
  @Override
  void levelUp() {
    level++;
    switch (level) {
      case 2:
        numberOfBolts++;    // 增加閃電數量
        break;
      case 3:
        attackRadius += 50; // 增加範圍
        break;
      case 4:
        damage += 10;       // 增加傷害
        break;
      case 5:
        numberOfBolts++;    // 再次增加閃電數量
        break;
      default:
        // 達到最高等級
        break;
    }
  }

  // 發射閃電
  @Override
  ArrayList<Bullet> fire(float startX, float startY) {
    for (int n = 0; n < numberOfBolts; n++) {
      if (enemies.size() > 0) {
        int randomIndex = int(random(enemies.size()));
        Enemy targetEnemy = enemies.get(randomIndex);

        lightningStartTime = millis();
        lightningX = targetEnemy.x;
        lightningY = targetEnemy.y;
        
        // 播放 Thunder 音效
        soundManager.playSound("Thunder", 0.5);

        // 對範圍內的敵人造成傷害
        for (int i = enemies.size() - 1; i >= 0; i--) {
          Enemy enemy = enemies.get(i);
          float distance = dist(lightningX, lightningY, enemy.x, enemy.y);

          if (distance <= attackRadius) {
            enemy.health -= damage;

            if (enemy.health <= 0) {
              enemyDefeated(enemy);
              enemies.remove(i);
            }
          }
        }
      }
    }
    return new ArrayList<Bullet>();
  }

  // 顯示閃電效果
  @Override
  void display() {
    if (lightningStartTime > 0 && millis() - lightningStartTime < lightningDuration) {
      imageMode(CENTER);
      image(lightningImage, lightningX, lightningY - 200, 300, 500);
    } else {
      lightningStartTime = -1;
    }
  }

  @Override
  PImage getImage() {
    return lightningImage;
  }

  @Override
  PImage getChoiceImage() {
    return ChoicelightningImage;
  }

  @Override
  String getDescription() {
    return "降落閃電\n範圍傷害";
  }

  @Override
  String getNextLevelDescription() {
    String description = "";
    if (level + 1 == 2) {
      description = "增加一道雷";
    } else if (level + 1 == 3) {
      description = "範圍增加";
    } else if (level + 1 == 4) {
      description = "傷害增加";
    } else {
      description = "增加一道雷";
    }
    return description;
  }
}


// 基本子彈類別
abstract class Bullet {
  float x, y;            // 子彈位置
  float size;            // 子彈大小
  int bulletDamage;      // 子彈傷害
  boolean markForRemoval = false; // 是否需要移除
  PImage bulletImage;    // 子彈圖片

  // 更新子彈位置的抽象方法
  abstract void update();

  // 顯示子彈的抽象方法
  abstract void display();

  // 檢查與敵人碰撞的抽象方法
  abstract void checkCollisionWithEnemies(ArrayList<Enemy> enemies);

  // 檢查子彈是否超出螢幕
  boolean isOffScreen() {
    return x < 0 || x > mapWidth || y < 0 || y > mapHeight;
  }
}


// 普通子彈類別
class NormalBullet extends Bullet {
  PVector velocity; // 子彈速度向量

  // 建構子，初始化子彈
  NormalBullet(float startX, float startY, PVector direction, PImage img, int damage) {
    this.x = startX;
    this.y = startY;
    this.velocity = direction.copy();
    this.velocity.setMag(7);
    this.bulletImage = img;
    this.bulletDamage = damage;
    this.size = 20;
  }

  // 更新子彈位置
  @Override
  void update() {
    x += velocity.x;
    y += velocity.y;
  }

  // 顯示子彈
  @Override
  void display() {
    float angle = atan2(velocity.y, velocity.x);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(bulletImage, 0, 0, size, size);
    popMatrix();
  }

  // 檢查與敵人碰撞
  @Override
  void checkCollisionWithEnemies(ArrayList<Enemy> enemies) {
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy enemy = enemies.get(i);
      if (dist(this.x, this.y, enemy.x, enemy.y) < (this.size / 2 + enemy.size / 2)) {
        enemy.health -= this.bulletDamage;
        if (enemy.health <= 0) {
          enemyDefeated(enemy);
          enemies.remove(i);
        }
        this.markForRemoval = true;
        break;
      }
    }
  }
}


// 彈射子彈類別
class BouncingBullet extends Bullet {
  PVector velocity;   // 子彈速度向量
  int bounceCount;    // 彈射次數

  // 建構子，初始化彈射子彈
  BouncingBullet(float startX, float startY, PVector direction, PImage img, int damage, int maxBounces) {
    this.x = startX;
    this.y = startY;
    this.velocity = direction.copy();
    this.velocity.setMag(7);
    this.bulletImage = img;
    this.bulletDamage = damage;
    this.size = 50;
    this.bounceCount = maxBounces;
  }

  // 更新子彈位置和彈射邏輯
  @Override
  void update() {
    x += velocity.x;
    y += velocity.y;

    if (x < 0 || x > mapWidth) {
      velocity.x *= -1;
      bounceCount--;
    }

    if (y < 0 || y > mapHeight) {
      velocity.y *= -1;
      bounceCount--;
    }
  }

  // 顯示子彈
  @Override
  void display() {
    float angle = atan2(velocity.y, velocity.x);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(bulletImage, 0, 0, size, size);
    popMatrix();
  }

  // 檢查與敵人碰撞
  @Override
  void checkCollisionWithEnemies(ArrayList<Enemy> enemies) {
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy enemy = enemies.get(i);
      if (dist(this.x, this.y, enemy.x, enemy.y) < (this.size / 2 + enemy.size / 2)) {
        enemy.health -= this.bulletDamage;
        if (enemy.health <= 0) {
          enemyDefeated(enemy);
          enemies.remove(i);
        }
        this.markForRemoval = true;
        break;
      }
    }
  }

  // 檢查是否需要移除子彈
  @Override
  boolean isOffScreen() {
    return bounceCount <= 0;
  }
}


// 拋物線子彈類別，生成毒液池
class ParabolicBullet extends Bullet {
  PVector velocity;          // 子彈速度向量
  PImage poisonImage;        // 毒液池圖片
  boolean hasTransformed = false; // 是否已變成毒液池
  float poisonDuration = 3000;    // 毒液池持續時間
  float poisonStartTime;          // 毒液池開始時間
  float poisonRadius;             // 毒液池半徑

  // 建構子，初始化拋物線子彈
  ParabolicBullet(float startX, float startY, PVector direction, PImage img, int damage, PImage poisonImage, float poisonSize) {
    this.x = startX;
    this.y = startY;
    this.velocity = direction.copy();
    this.bulletImage = img;
    this.bulletDamage = damage;
    this.size = poisonSize / 2;
    this.poisonImage = poisonImage;
    this.poisonRadius = poisonSize / 2;
  }

  // 更新子彈位置和毒液池狀態
  @Override
  void update() {
    if (!hasTransformed) {
      velocity.y += 0.2; // 模擬重力
      x += velocity.x;
      y += velocity.y;

      // 檢查子彈是否超出地圖範圍
      if (x < 0 || x > mapWidth || y > mapHeight) {
        this.markForRemoval = true;
      }

      // 檢查垂直速度方向變化
      float stop_y = random(6,11); // 停止的速度
      if (velocity.y >= stop_y) {
        hasTransformed = true;
        poisonStartTime = millis();
        
        soundManager.playSound("GlassBroke", 0.2f);
      }
    } else {
      // 檢查毒液池是否過期
      if (millis() - poisonStartTime >= poisonDuration) {
        this.markForRemoval = true;
      }
    }
  }

  // 顯示子彈或毒液池
  @Override
  void display() {
    imageMode(CENTER);
    if (!hasTransformed) {
      image(bulletImage, x, y, size, size);
    } else {
      image(poisonImage, x, y, poisonRadius * 2, poisonRadius * 2);
    }
  }

  // 檢查與敵人碰撞
  @Override
  void checkCollisionWithEnemies(ArrayList<Enemy> enemies) {
    if (hasTransformed) {
      for (int i = enemies.size() - 1; i >= 0; i--) {
        Enemy enemy = enemies.get(i);
        if (isEnemyInPoison(enemy)) {
          enemy.health -= this.bulletDamage;
          if (enemy.health <= 0) {
            enemyDefeated(enemy);
            enemies.remove(i);
          }
        }
      }
    }
  }

  // 檢查敵人是否在毒液池範圍內
  boolean isEnemyInPoison(Enemy enemy) {
    float distance = dist(this.x, this.y, enemy.x, enemy.y);
    return distance <= poisonRadius + (enemy.size / 2);
  }
}


// 守衛者類別，環繞 Agent 旋轉
class Guardian {
  Agent agent;              // 參考的 Agent
  PImage guardianImage;     // 守衛者圖片
  float angle;              // 當前角度
  float distance;           // 與 Agent 的距離
  int damage;               // 傷害
  float rotationSpeed;      // 旋轉速度

  // 建構子，初始化守衛者
  Guardian(Agent agent, PImage img, float initialAngle, float distance, int damage, float rotationSpeed) {
    this.agent = agent;
    this.guardianImage = img;
    this.angle = initialAngle;
    this.distance = distance;
    this.damage = damage;
    this.rotationSpeed = rotationSpeed;
  }

  // 更新角度
  void update() {
    angle += rotationSpeed;
  }

  // 顯示守衛者
  void display() {
    float x = agent.x + cos(angle) * distance;
    float y = agent.y + sin(angle) * distance;

    pushMatrix();
    translate(x, y);
    imageMode(CENTER);
    image(guardianImage, 0, 0, 75, 75);
    popMatrix();
  }

  // 獲取守衛者位置
  float getX() {
    return agent.x + cos(angle) * distance;
  }

  float getY() {
    return agent.y + sin(angle) * distance;
  }
}
