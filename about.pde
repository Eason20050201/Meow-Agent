//關於介面
PImage[] aboutImages;
PImage next_page, last_page, go_back;
int aboutPage = 0;
boolean goBackPressed = false;
boolean nextPagePressed = false;
boolean lastPagePressed = false;


// 顯示關於圖片
void aboutimage() {
  imageMode(CORNER);     
  image(aboutImages[aboutPage],0,0,436,800);
}

// 實現 displayAbout() 函數
void displayAbout() {
  PImage lobby = loadImage("lv1lobby.png");
  imageMode(CENTER);
  image(lobby, width / 2, height / 2);
  image(aboutImages[aboutPage], width / 2, height / 2 - 20, 480, 640);
  
  // 顯示退出按鈕，按下時平移效果
  if (goBackPressed) {
    image(go_back, width/2, height - 80, 110, 110); // 退出按鈕按下時平移
  } else {
    image(go_back, width/2, height - 80, 130, 130);
  }
  if (nextPagePressed && aboutPage < aboutImages.length - 1) {
    image(next_page, width - 80, height - 80, 110, 110); // 退出按鈕按下時平移
  } else if(aboutPage < aboutImages.length - 1){
    image(next_page, width - 80, height - 80, 130, 130);
  }
  if (lastPagePressed && aboutPage > 1) {
    image(last_page, 80, height - 80, 110, 110); // 退出按鈕按下時平移 
  } else if (aboutPage > 1) {
    image(last_page, 80, height - 80, 130, 130);
  }
}
