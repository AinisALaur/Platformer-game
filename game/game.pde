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
int runSpeed = 1;
boolean onGround = true;
float jumpPower = -10;
boolean doubleJumpPressed = false;
int playerWidth = 32;
int playerHeight = 32;

//Physics
float gravity = 0.6;
float yPeak;
float resistance = 0.9;


//Movement
boolean runLeft = false;
boolean runRight = false;
boolean peakReached = false;

//Map properties
int tileSize = 32;
int mapHeight = 20;
int mapWidth = 64;
boolean gridOn = false;

//Collision
int[][] hitBoxArray1;
int[][] hitBoxArray2;
int[][] hitBoxArray3;
boolean movingIntoAwall = false;

//Camera
float camX, camY;

//Current level
int level = 1;
int[][][] hitBoxes;

//------------------------------------------------------------
void setup() {
    size(800, 640);
    character_idle = loadImage("../Images/character/Idle.png");
    character_run = loadImage("../Images/character/Run.png");
    character_jump = loadImage("../Images/character/Jump.png");
    character_fall = loadImage("../Images/character/Fall.png");
    background = loadImage("../Images/Background-" + level + ".png");
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
    hitBoxes = new int[][][] {hitBoxArray1, hitBoxArray2, hitBoxArray3};
}

int[][] generateHitboxes(PImage hitBoxMap) {
    int[][] hitBoxes = new int[mapHeight][mapWidth];

    float targetR = 73;
    float targetG = 97;
    float targetB = 23;
    float tol = 15;

    for(int y = 0; y < mapHeight; y++){
        for(int x = 0; x < mapWidth; x++){
            int imgX = x * tileSize;
            int imgY = y * tileSize;
            int c = hitBoxMap.get(imgX + tileSize/2, imgY + tileSize/2);

            float r = red(c);
            float g = green(c);
            float b = blue(c);

            boolean isTargetGreen =
                abs(r - targetR) < tol &&
                abs(g - targetG) < tol &&
                abs(b - targetB) < tol;

            if(brightness(c) < 250 && !isTargetGreen){
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
    vx += runSpeed;
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
    vx += (-1) * runSpeed;
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
    x = constrain(x, 0, 63*tileSize);
    if (vx > 0) {
        vx -= resistance;
        if (vx < 0) vx = 0;
    } else if (vx < 0) {
        vx += resistance;
        if (vx > 0) vx = 0;
    }
}

void detectCollision(int[][] map) {
    int left = constrain(x / tileSize, 0, mapWidth - 1);
    int right = constrain((x + playerWidth - 1) / tileSize, 0, mapWidth - 1);
    int top = constrain(y / tileSize, 0, mapHeight - 1);
    int bottom = constrain((y + playerHeight - 1) / tileSize, 0 , mapHeight - 1);

    if(vy != 0 && vx > 0 && map[bottom][right] == 1 && map[bottom][left] == 0 ||
        vy != 0 && vx < 0 && map[bottom][right] == 0 && map[bottom][left] == 1){
        movingIntoAwall = true;
    }

    else{
        movingIntoAwall = false;
    }

    if(vy > 0 && (map[bottom][left] == 1 || map[bottom][right] == 1) && !movingIntoAwall){
        vy = 0;
        onGround = true;
        showJump = true;
        showRunAnimation = true;
    }

    if(vy < 0 && (map[top][left] == 1 || map[top][right] == 1)){
        if((map[bottom][left] == 0 || map[bottom][right] == 0)){
            if(!movingIntoAwall){
                y = (top + 1) * tileSize;
                vy = 0;
                peakReached = true;
            }else if (movingIntoAwall && (map[top][left] == 1 && map[bottom][left] == 0 ||
                       map[top][right] == 1 && map[bottom][right] == 0)){
                y = (top + 1) * tileSize;
                vy = 0;
                peakReached = true;
            }
        }
    }
    
    if(vx > 0 && map[top][right] == 1){
        vx = 0;
        x = (right - 1) * tileSize;
    }

    if(vx < 0 && map[top][left] == 1){
        vx = 0;
        x = (left + 1) * tileSize;
    }

    if(map[bottom][left] == 0 && map[bottom][right] == 0){
        onGround = false;
    }
}


void draw() {
    if(y >= 20*tileSize){
        x = 0;
        y = 513;
    }
    background(255);

    camX = constrain(x - width/2 + playerWidth/2, 0, (mapWidth - 25)*tileSize);
    camY = 0;
    translate(-camX, -camY);

    image(background, 0, 0);

    idleCounter++;
    if (idleCounter >= idleDelay) {
        idleCounter = 0;
        idleFrame = (idleFrame + 1) % 11;
    }

    detectCollision(hitBoxes[level - 1]);

    if(!onGround){
        vy += gravity;
        y += vy;
        y = constrain(y, -100*tileSize, 20*tileSize);

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
            vx += runSpeed;
            direction = 'l';
        }
        if (runRight) {
            vx += -runSpeed;
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

    if(gridOn){
        for (int i = 0; i <= mapWidth; i++) {
            line(i*tileSize, 0, i*tileSize, mapHeight*tileSize);
        }

        for (int j = 0; j <= mapHeight; j++) {
            line(0, j*tileSize, mapWidth*tileSize, j*tileSize);
        }

        for (int row = 0; row < mapHeight; row++) {
            for (int col = 0; col < mapWidth; col++) {
                textSize(24);
                fill(0, 0, 0);
                text(hitBoxes[level - 1][row][col], col * tileSize, (row + 1) * tileSize);
            }
        }
    }

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