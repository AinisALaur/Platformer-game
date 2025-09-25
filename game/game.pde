//Images
PImage character_idle;
PImage character_run;
PImage character_jump;
PImage character_fall;
PImage character_double_jump;
PImage levelOneHitBoxes;
PImage levelTwoHitBoxes;
PImage levelThreeHitBoxes;
PImage background;


//Animations
int idleFrame = 0;
int idleDelay = 6;
int idleCounter = 0;
int runFrame = 0;
int runDelay = 4;
int runCounter = 0;
int doubleJumpFrame = 0;
int doubleJumpDelay = 4;
int doubleJumpCounter = 0;
boolean showRunAnimation = true;
boolean showJump = true;


//Character properties
int x = 0;
int y = 512;
float vy = 0;
float vx = 0;
char direction = 'l';
int runSpeed = 2;
boolean onGround = true;
float jumpPower = -15;
boolean doubleJumpPressed = false;


//Physics
float gravity = 0.8;
float yPeak;
float resistance = 0.8;


//Movement
boolean runLeft = false;
boolean runRight = false;
boolean peakReached = false;

//Map properties
int tileSize = 32;
int mapHeight = 20;
int mapWidth = 64;

//Collision
int[][] hitBoxArray1;
int[][] hitBoxArray2;
int[][] hitBoxArray3;

//------------------------------------------------------------
void setup() {
    size(800, 640);
    character_idle = loadImage("../Images/character/Idle.png");
    character_run = loadImage("../Images/character/Run.png");
    character_jump = loadImage("../Images/character/Jump.png");
    character_fall = loadImage("../Images/character/Fall.png");
    background = loadImage("../Images/Background-1.png");
    character_double_jump = loadImage("../Images/character/Double Jump.png");

    levelOneHitBoxes = loadImage("../Images/1.png");
    levelTwoHitBoxes = loadImage("../Images/2.png");
    levelThreeHitBoxes = loadImage("../Images/3.png");

    levelOneHitBoxes.loadPixels();
    levelTwoHitBoxes.loadPixels();
    levelThreeHitBoxes.loadPixels();

    hitBoxArray1 = generateHitboxes(levelOneHitBoxes);
    hitBoxArray2 = generateHitboxes(levelTwoHitBoxes);
    hitBoxArray3 = generateHitboxes(levelThreeHitBoxes);
}

int[][] generateHitboxes(PImage hitBoxMap) {
    int[][] hitBoxes = new int[mapHeight][mapWidth];
    for(int y = 0; y < mapHeight; y++){
        for(int x = 0; x < mapWidth; x++){
            int imgX = x * tileSize;
            int imgY = y * tileSize;
            int c = hitBoxMap.get(imgX + tileSize/2, imgY + tileSize/2);

            if(brightness(c) != 255){
                hitBoxes[y][x] = 1;
            }else{
                hitBoxes[y][x] = 0;
            }
        }
    }
    return hitBoxes;
}

void drawFlipped(PImage img, float x, float y) {
  pushMatrix();
  translate(x + img.width, y);
  scale(-1, 1);
  image(img, 0, 0);
  popMatrix();
}

void runLeft(){
    vx = runSpeed;
    if(showRunAnimation){
        runCounter++;
        if (runCounter >= runDelay) {
            runCounter = 0;
            runFrame = (runFrame + 1) % 12;
        }

        PImage runScene = character_run.get(runFrame * 32, 0, 32, 32);
        image(runScene, x, y);
    }
    direction = 'l';
}

void runRight(){
    vx = (-1) * runSpeed;
    if(showRunAnimation){
        runCounter++;
        if (runCounter >= runDelay) {
            runCounter = 0;
            runFrame = (runFrame + 1) % 12;
        }

        PImage runScene = character_run.get(runFrame * 32, 0, 32, 32);
        drawFlipped(runScene, x, y);
    }
    direction = 'r';
}

void idling(){
    PImage idleScene = character_idle.get(idleFrame * 32, 0, 32, 32);
    if(direction == 'l'){
        image(idleScene, x, y);
    }else{
        drawFlipped(idleScene, x, y);
    }
}

void applyRunning(){
    x += vx;
    if (vx > 0) {
        vx -= resistance;
        if (vx < 0) vx = 0;
    } else if (vx < 0) {
        vx += resistance;
        if (vx > 0) vx = 0;
    }
}

// boolean isCollisionAbove(int[][] hitBoxArray){
//     int playerTileX = x / tileSize;
//     int playerTileY = y / tileSize;
//     return hitBoxArray[playerTileY - 1][playerTileX] == 1;
// }

// boolean isCollisionBellow(int[][] hitBoxArray){
//     int playerTileX = x / tileSize;
//     int playerTileY = y / tileSize;
//     return hitBoxArray[playerTileY][playerTileX] == 1;
// }

// boolean isCollisionLeft(int[][] hitBoxArray){
//     int playerTileX = x / tileSize;
//     int playerTileY = y / tileSize;
//     return hitBoxArray[playerTileY][playerTileX + 1] == 1;
// }

// boolean isCollisionRight(int[][] hitBoxArray){
//     int playerTileX = x / tileSize;
//     int playerTileY = y / tileSize;
//     return hitBoxArray[playerTileY][playerTileX - 1] == 1;
// }

void draw() {
    background(255);
    image(background, 0, 0);

    idleCounter++;
    if (idleCounter >= idleDelay) {
        idleCounter = 0;
        idleFrame = (idleFrame + 1) % 11;
    }

    if(!onGround){
        vy += gravity;
        y += vy;

        if(doubleJumpPressed == true){
            doubleJumpCounter++;
            if (doubleJumpCounter >= doubleJumpDelay) {
                doubleJumpCounter = 0;
                doubleJumpFrame = (doubleJumpFrame + 1) % 6;
            }
            PImage doubleJumpScene = character_double_jump.get(doubleJumpFrame * 32, 0, 32, 32);
            if(direction == 'l')
                image(doubleJumpScene, x, y);
            else
                drawFlipped(doubleJumpScene, x, y);
        }

        if (runLeft) {
            vx = runSpeed;
            direction = 'l';
        }
        if (runRight) {
            vx = -runSpeed;
            direction = 'r';
        }

        if(peakReached == false){
            if(showJump){
                if(direction == 'l')
                    image(character_jump, x, y);
                else
                    drawFlipped(character_jump, x, y);
            }
        }else{
            if(direction == 'l')
                image(character_fall, x, y);
            else
                drawFlipped(character_fall, x, y);
        }

        if(y <= yPeak){
            peakReached = true;
        }

        if (y >= 512) {
            y = 512;
            vy = 0;
            onGround = true;
            showRunAnimation = true;
            showJump = true;
        }
    }

    else if (keyPressed && runLeft) {
        runLeft();
    }
        
    else if(keyPressed && runRight){
        runRight();
    }

    else{
        PImage idleScene = character_idle.get(idleFrame * 32, 0, 32, 32);
        if(direction == 'l'){
            image(idleScene, x, y);
        }else{
            drawFlipped(idleScene, x, y);
        }
    }

    applyRunning();
}

void keyPressed(){
    if(key == 'd'){
        runLeft = true;
    }

    if(key == 'a'){
        runRight = true;
    }
}

void keyReleased(){
    if(key == 'd'){
        runLeft = false;
    }

    if(key == 'a'){
        runRight = false;
    }

    if (key == 'w' && onGround) {
        showRunAnimation = false;
        vy = jumpPower;
        yPeak = y - (vy*vy)/(2*gravity);
        doubleJumpPressed = false;
        onGround = false;
        peakReached = false;
    }

    else if(key == 'w' && !onGround && !doubleJumpPressed){
        vy = jumpPower;
        yPeak = y - (vy*vy)/(2*gravity);
        doubleJumpPressed = true;
        showJump = false;
        peakReached = false;
    }
}