class Quiz {
  String question;
  String[] options;
  int correctAnswerIndex;

  Quiz(String question, String[] options, int correctAnswerIndex) {
    this.question = question;
    this.options = options;
    this.correctAnswerIndex = correctAnswerIndex;
  }

  boolean checkAnswer(int answerIndex) {
    return answerIndex == correctAnswerIndex;
  }
}

ArrayList<Quiz> quizzes = new ArrayList<>();

Quiz currentQuiz;
boolean showQuiz = false;
boolean[] optionPressed = new boolean[4];
float optionFontSize = 18; // 預設字體大小
float optionPressedFontSize = 16; // 按下時的縮小字體大小

void displayQuiz(Quiz quiz) {
  imageMode(CORNER);
  image(pausedBackground, 0, 0, width, height); // 使用截圖作為背景
  fill(150, 150, 150, 150);
  rectMode(CENTER);
  noStroke();
  rect(width / 2, height / 2, width, height);   // 顯示半透明遮罩
  fill(#333541);
  rect(width / 2, height / 2 - 50, 570, 400, 10); // 文字背景

  // 顯示提示文字
  fill(255);
  textFont(TCfont);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("恭喜升級!!\n答題成功即可選擇技能，失敗則無法選擇技能。", width / 2, height / 3 - 70);

  // 顯示題目文字
  textSize(19);
  text(quiz.question, width / 2, height / 3 - 10);

  // 顯示選項的背景矩形和文字
  for (int i = 0; i < quiz.options.length; i++) {
    float optionX = width / 2;
    float optionY = height / 3 + 50 * (i + 1);
    float optionWidth = 300;
    float optionHeight = 40;

    // 如果按下此選項，縮小顯示大小
    if (optionPressed[i]) {
      textSize(optionPressedFontSize);
      optionWidth *= 0.95;
      optionHeight *= 0.95;
    } else {
      textSize(optionFontSize);
    }

    // 繪製選項背景矩形
    fill(200, 200, 250);
    rect(optionX, optionY, optionWidth, optionHeight, 10); // 圓角設為10

    // 繪製選項文字
    fill(0);
    textAlign(CENTER, CENTER);
    text(quiz.options[i], optionX, optionY);
  }
}

// 升級時顯示題目
void showUpgradeQuiz() {
  currentQuiz = quizzes.get((int)random(quizzes.size())); // 隨機選擇一個問題
  showQuiz = true; // 開啟 Quiz 視窗
}

// 檢查答案
void checkAnswer(int selectedOption) {
  //println(selectedOption);
  if (currentQuiz.checkAnswer(selectedOption)) {
    soundManager.playSound("Correct"); 
    displayChoiceSkillMenu(); // 答對，顯示技能選單
  } else {
    println("答錯，無法選擇技能");
    soundManager.playSound("Wronganswer"); 
    agent.showWeaponChoice = false; // 答錯，將顯示技能選單的狀態設為 false
  }
  showQuiz = false; // 關閉 Quiz 視窗
}

// 設定題目
void setupQuizzes() {
  quizzes.add(new Quiz("網路用語「連車尾燈都看不到」與下列哪個成語意思最相近?",
    new String[]{"超英趕美", "難以望其項背", "青黃不接", "過河拆橋"}, 2));
  quizzes.add(new Quiz("Google商標中有幾種顏色?",
    new String[]{"6", "4", "5", "3"}, 2));
  quizzes.add(new Quiz("哪一個國家沒有和義大利接壤?",
    new String[]{"奧地利", "瑞士", "西班牙", "法國"}, 3));
  quizzes.add(new Quiz("太陽系中，離太陽最遠的行星是?",
    new String[]{"海王星", "天王星", "冥王星", "土星"}, 1));
  quizzes.add(new Quiz("眼睛總是乾乾的，晚上視力不太好，請問可能是缺乏哪種維生素?",
    new String[]{"維生素B", "維生素A", "維生素C", "維生素D"}, 2));
  quizzes.add(new Quiz("電荷的單位是什麼?",
    new String[]{"伏特", "瓦特", "安培", "庫倫"}, 4));
  quizzes.add(new Quiz("蓮霧是哪個縣市的名產?",
    new String[]{"台南縣", "台東縣", "花蓮縣", "屏東縣"}, 4));
  quizzes.add(new Quiz("「印度」的首都是?",
    new String[]{"新德里", "渥太華", "太子港", "孟買"}, 1));
  quizzes.add(new Quiz("一公克的脂肪可產生幾大卡的熱量?",
    new String[]{"4", "9", "11", "7"}, 2));
  quizzes.add(new Quiz("火星的大氣層的主要成分是什麼?",
    new String[]{"氧氣", "氮氣", "二氧化碳", "甲烷"}, 3));
  quizzes.add(new Quiz("sinx/x在x->0的極限是多少?",
    new String[]{"0", "-1", "1", "無限"}, 3));
  quizzes.add(new Quiz("世界上最長的河流是哪條?",
    new String[]{"亞馬遜河", "尼羅河", "長江", "密西西比河"}, 2));
  quizzes.add(new Quiz("世界上的人口最多的國家是哪一個?",
    new String[]{"印度", "美國", "中國", "巴西"}, 1));
  quizzes.add(new Quiz("哥倫布發現新大陸是在幾年?",
    new String[]{"1392年", "1692年", "1592年", "1492年"}, 4));
  quizzes.add(new Quiz("人體中，肝臟的主要功能之一是什麼?",
    new String[]{"分泌胰島素", "調節體溫", "運輸血液", "分解毒素"}, 4));
  quizzes.add(new Quiz("太陽系中最大的行星是?",
    new String[]{"地球", "火星", "土星", "木星"}, 4));
  quizzes.add(new Quiz("第一屆奧運會在哪裡舉行?",
    new String[]{"羅馬", "美國洛杉磯", "法國巴黎", "希臘雅典"}, 4));
  quizzes.add(new Quiz("在 Python 中，以下哪一個表示邏輯運算符「且」?",
    new String[]{"&", "|", "or", "and"}, 4));
  quizzes.add(new Quiz("若 int x = 10; 和 int y = 20;，以下表達式 x > y 的結果為何?",
    new String[]{"True", "False", "10", "20"}, 2));
  quizzes.add(new Quiz("地球的內部結構分為幾層?",
    new String[]{"2", "3", "4", "5"}, 3));
  quizzes.add(new Quiz("火山噴發時噴出的熔岩來自哪個地層?",
    new String[]{"地殼", "內核", "地幔", "外核"}, 3));
  quizzes.add(new Quiz("光合作用中的「光反應」發生在?",
    new String[]{"葉綠體", "粒線體", "細胞膜", "細胞質"}, 1));
  quizzes.add(new Quiz("海洋中的洋流主要受到什麼因素影響?",
    new String[]{"風和地球自轉", "月亮的引力", "陸地形狀", "地殼運動"}, 1));
  quizzes.add(new Quiz("地球表層的構造板塊被稱為?",
    new String[]{"岩石圈", "地幔", "地殼", "外核"}, 1));
  quizzes.add(new Quiz("下列哪個星球的自轉軸幾乎平行於其公轉軌道，\n因此自轉軸傾角接近90度?",
    new String[]{"木星", "土星", "海王星", "天王星"}, 4));
  quizzes.add(new Quiz("下列何者不是時間單位?",
    new String[]{"天", "小時", "毫秒", "光年"}, 4));
  quizzes.add(new Quiz("哪個成語用來形容一個人「罪行多得寫不完」?",
    new String[]{"不共戴天", "眾志成城", "破鏡重圓", "罄竹難書"}, 4));
  quizzes.add(new Quiz("以下哪個英文單字不能作為形容詞?",
    new String[]{"honest", "friend", "tight", "cold"}, 2));
  quizzes.add(new Quiz("成語「入木三分」和哪個歷史人物有關?",
    new String[]{"王世堅", "王郁琦", "王羲之", "王獻之"}, 3));
  quizzes.add(new Quiz("以下哪個國家位於北歐?",
    new String[]{"白俄羅斯", "荷蘭", "瑞典", "比利時"}, 3));
  // 添加其他問題
  // ...
}
