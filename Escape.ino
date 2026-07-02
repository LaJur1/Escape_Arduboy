#include <Arduboy2.h>
#include "EscapeScreen.h"
#include "Sprite.h"

Arduboy2 arduboy;

//position des Spielers festlegen
int playerX = 12;
int playerY = 48;
int playerState;
int jumpingState; 
int STATE_STANDING = 0;
int STATE_RUNNING = 1;
int STATE_JUMPING = 2;
int STATE_FALLING = 3;
int playerDirection = 0;
int STATE_NEUTRAL = 0;
int STATE_RIGHT = 0;
int STATE_LEFT = 1;
int animationFrame = 0;
int movementCounter = 0;
int animationCounter = 0;
int jumpingCounter = 0; 
int JUMPINGCOUNTERMAX = 35;  
int debug = 0;
int level = 1; //level 0 = Startscreen
int jump_y[] = {0, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2};

// Pixel im Hintergrund abfragen
const uint8_t* levelData = Bg1Frame0 + 4;
bool getLevelPixel(uint8_t level, int x, int y) {
    if (x < 0 || x >= 128 || y < 0 || y >= 64) return false;

    uint16_t i = level * 1024 + (y >> 3) * 128 + x;

    return (pgm_read_byte(&levelData[i]) >> (y & 7)) & 1;
}
// check Ground
 bool checkGround(int level, int x, int y){
  return getLevelPixel(level,x+1,y+8) || getLevelPixel(level,x+6,y+8);  
 }
// check Air
 bool checkAir(int level, int x, int y){
  return !(getLevelPixel(level,x+1,y) || getLevelPixel(level,x+6,y));  
 }
// check wall left
 bool checkWallLeft(int level, int x, int y){
  return getLevelPixel(level,x+1,y+1) || getLevelPixel(level,x+1,y+7); 
 }
// check wall Right
 bool checkWallRight(int level, int x, int y){
  return getLevelPixel(level,x+6,y+1) || getLevelPixel(level,x+6,y+7); 
 }
// check Ground Feet
bool checkGroundFeet(int level, int x, int y){
  return getLevelPixel(level,x+1,y+7) || getLevelPixel(level,x+6,y+7);  
 }



void setup() {
  arduboy.boot();
  arduboy.clear();
 
}

uint8_t gameState = 0;

void loop() {
  if (!arduboy.nextFrame()) return;

  arduboy.pollButtons(); 
  
  //Startscreen
  if (gameState == 0) {
    arduboy.drawBitmap(0, 0, Bg1Frame0+2, 128, 64, WHITE);
    arduboy.display();
    
    if (arduboy.justPressed(A_BUTTON)) {
      gameState = 1; 
    }
  } 
  // 
  // Gameloop  
  //  
  else if (gameState == 1) {
 
   movementCounter++; 
   if  (movementCounter > 1) movementCounter = 0;

    //
    //Tastenabfrage 
    //
    if (arduboy.pressed(LEFT_BUTTON) && checkWallLeft(level, playerX, playerY) == false && movementCounter == 0) {
      playerX = playerX -1;
      playerState = STATE_RUNNING;
      playerDirection = STATE_LEFT;
    }
    if (arduboy.pressed(RIGHT_BUTTON) && checkWallRight(level, playerX, playerY) == false && movementCounter == 0) {
      playerX = playerX +1;  
      playerState = STATE_RUNNING;
      playerDirection = STATE_RIGHT;
    }
    if (arduboy.pressed(B_BUTTON) && jumpingState != STATE_JUMPING && jumpingState !=STATE_FALLING) {
      jumpingState = STATE_JUMPING;
      jumpingCounter = 0;
    }
    
    if (!(arduboy.pressed(RIGHT_BUTTON) || arduboy.pressed(LEFT_BUTTON))){
      playerState = STATE_STANDING;
    }
    //
    // Jumping 
    //
    if (jumpingState == STATE_JUMPING) {
      jumpingCounter++;
      if (jumpingCounter == JUMPINGCOUNTERMAX){
        jumpingCounter = 0;
        jumpingState = STATE_STANDING;
      }
      playerY = playerY + jump_y[jumpingCounter];
      // Kopf gestoßen?
      if (!checkAir(level, playerX, playerY)){
        jumpingCounter = 0;
        jumpingState = STATE_FALLING; 
      }
      //Ground?
      if (checkGround(level, playerX, playerY)){
        jumpingCounter = 0;
        jumpingState = STATE_STANDING;
      }
    }
    //
    // Check Ground & falling
    //
    if (!checkGround(level, playerX, playerY)&&(jumpingState !=STATE_JUMPING)) {
       jumpingState = STATE_FALLING;
    }
    


    //
    // Falling 
    //
    if (jumpingState == STATE_FALLING) {
        if (getLevelPixel(level, playerX+3, playerY+8)){
          jumpingState = STATE_STANDING;
      } else {
        playerY = playerY+1;
      }
    }


    //
    // Feet in Ground?
    // 
    while (checkGroundFeet(level, playerX, playerY)) {
      playerY = playerY - 1;
      jumpingState = STATE_STANDING;
     }
    
    // 
    // Mainscreen aktualisieren  
    // 
   animationCounter = animationCounter+1;
    if (animationCounter > 4) {
      animationCounter = 0;
      animationFrame = animationFrame+1;
      if (animationFrame > 1) animationFrame = 0;
    }
    if (playerState == STATE_STANDING) animationFrame = 0; 
    arduboy.clear(); 
    arduboy.drawBitmap(0, 0, Bg1Frame0+1024+4, 128, 64, WHITE);
    //arduboy.drawBitmap(0, 0, Bg1Frame0+2, 128, 64, WHITE);
   /*
    
    //zeichne spieler 
    if (playerState == STATE_STANDING)  
      Sprites::drawPlusMask(playerX, playerY, Player, 0+playerDirection + playerState*2 + animationFrame);
    if (playerState == STATE_RUNNING)  
      Sprites::drawPlusMask(playerX, playerY, Player, 0+playerDirection*2 + playerState*2 + animationFrame);
    if (playerState == STATE_JUMPING) 
      Sprites::drawPlusMask(playerX, playerY, Player, 0+ 6);
    arduboy.setCursor(0,0);   
    arduboy.print(playerDirection);
    arduboy.print(playerState);
    arduboy.print(animationFrame);
    arduboy.print(jumpingState);
    */
    arduboy.display();

/*
arduboy.clear();
for (int y = 0; y < 64; y++) {
    for (int x = 0; x < 128; x++) {
        if (getLevelPixel(level, x, y)) {
            arduboy.drawPixel(x, y, WHITE);
        }
    }
}

arduboy.display();
*/


  }
}             
