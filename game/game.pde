import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;


//Images
PImage end_game;
PImage title_screen;
PImage character_idle;
PImage character_run;
PImage character_jump;
PImage character_fall;
PImage character_double_jump;
PImage background;
PImage [] tileImages = new PImage[]{};


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
int displayStartTime = 0;
boolean showRunAnimation = true;
boolean showJump = true;
boolean displayCoinCount = false;
int coinCountX;
boolean displayLevel = true;
int displayLevelStartTime = millis();

int [] displayLevelStart = new int[]{350, 50, 200};
int [] displayLevelEnd = new int[]{1900, 1900};

boolean showTittleScreen = true;

//Character properties
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
float resistance = 0.93;


//Movement
boolean runLeft = false;
boolean runRight = false;
boolean peakReached = false;

//Map properties
int tileSize = 32;
int mapHeight = 20;
int mapWidth = 64;
boolean gridOn = false;
boolean gameOver = false;
int [][][] maps = new int [3][mapHeight][mapWidth];
String mainPath = "...";


//Collision
boolean movingIntoAwall = false;

//Camera
float camX, camY;

//Level properties
int level = 1;

int[][] levelSpawns = new int [][]{{0, 16},{1, 16},{1, 14}}; 
int[][] levelEnds = new int [][]{{62, 4},{63, 1},{63, 3}}; 
int coinsCollected = 0;
 
int x = levelSpawns[level - 1][0] * tileSize;
int y = levelSpawns[level - 1][1] * tileSize;
int displayLevelX = displayLevelStart[level - 1];

//------------------------------------------------------------
void setup() {
    size(800, 640);
    character_idle = loadImage("../Images/character/Idle.png");
    character_run = loadImage("../Images/character/Run.png");
    character_jump = loadImage("../Images/character/Jump.png");
    character_fall = loadImage("../Images/character/Fall.png");
    background = loadImage("../Images/Background.png");
    character_double_jump = loadImage("../Images/character/Double Jump.png");
    title_screen = loadImage("../Images/Tittle screen.png");
    end_game = loadImage("../Images/End game.png");

    int maxTileId = 21;
    tileImages = new PImage[maxTileId + 1];
    for (int i = 1; i <= maxTileId; i++) {
        tileImages[i] = loadImage("../Images/Tiles/" + i + ".png");
    }

    loadFromCSV();
}

void loadFromCSV() {
    for(int i = 1; i <= 3; ++i){
        String filePath = mainPath + i + ".csv";
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            int row = 0;
            while ((line = br.readLine()) != null && row < mapHeight) {
                String[] values = line.trim().split("\\s+");
                for (int col = 0; col < Math.min(values.length, mapWidth); col++) {
                    int tileId = Integer.parseInt(values[col]);
                    maps[i - 1][row][col] = tileId;
                }
                row++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

void drawMap(int level){
    image(background, 0, 0);
    for(int i = 0 ; i < mapHeight; ++i){
        for(int x = 0; x < mapWidth; ++x){
            int tileId = maps[level - 1][i][x];
            if(tileId != 0){
                PImage tile = tileImages[tileId];
                image(tile, x * tileSize, i * tileSize);
            }
        }
    }
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

boolean canWalkThrough(int tileId){
    if(tileId == 17 || tileId == 18 || tileId == 19 || tileId == 21 || tileId == 0){
        return true;
    }
    return false;
}

boolean isInsideWall(int[][] map) {
    // Check just the center of the player
    int centerX = constrain((x + playerWidth / 2) / tileSize, 0, mapWidth - 1);
    int centerY = constrain((y + playerHeight / 2) / tileSize, 0, mapHeight - 1);
    
    return (map[centerY][centerX] != 0 && !canWalkThrough(map[centerY][centerX]));
}

void detectCollision(int[][] map) {
    int left = constrain(x / tileSize, 0, mapWidth - 1);
    int right = constrain((x + playerWidth - 1) / tileSize, 0, mapWidth - 1);
    int top = constrain(y / tileSize, 0, mapHeight - 1);
    int bottom = constrain((y + playerHeight - 1) / tileSize, 0 , mapHeight - 1);

    if(left >= levelEnds[level - 1][0] && top == levelEnds[level - 1][1]){
        if(level != 3){
            ++level;
            vx = 0;
            vy = 0;
            x = levelSpawns[level - 1][0]*tileSize;
            y = levelSpawns[level - 1][1]*tileSize;
            displayLevelX = displayLevelStart[level - 1];
            displayLevel = true;
            displayLevelStartTime = millis();
        }else{
            if(coinsCollected == 12){
                gameOver = true;
            }else{
                textSize(42);
                fill(255, 0, 0);
                text("Only " + coinsCollected + " coins out of 12!", 1400, 150);
            }
        }
    }

    if(left == levelSpawns[level - 1][0] - 1 && top == levelSpawns[level - 1][1]){
        if(level != 1){
            --level;
            vx = 0;
            vy = 0;
            x = levelEnds[level - 1][0]*tileSize;
            y = levelEnds[level - 1][1]*tileSize;
            displayLevelX = displayLevelEnd[level - 1];
            displayLevel = true;
            displayLevelStartTime = millis();
        }
    }

    if (isInsideWall(map)) {
        vy = 0;
        y = (bottom - 1) * tileSize + 1;
        onGround = true;
        doubleJumpPressed = false;
        showJump = true;
        showRunAnimation = true;
    }

    if(vy != 0 && vx > 0 && map[bottom][right] != 0 && !canWalkThrough(map[bottom][right]) && (map[bottom][left] == 0 || canWalkThrough(map[bottom][left]))  ||
        vy != 0 && vx < 0 && (map[bottom][right] == 0 || canWalkThrough(map[bottom][right])) && map[bottom][left] != 0 && !canWalkThrough(map[bottom][left])){
        movingIntoAwall = true;
    }

    else{
        movingIntoAwall = false;
    }

    //Horizontal movement
    if(vx > 0 && map[top][right] != 0 && !canWalkThrough(map[top][right])){
        vx = 0;
        x = (right - 1) * tileSize;
    }

    if(vx < 0 && map[top][left] != 0 && !canWalkThrough(map[top][left])){
        vx = 0;
        x = (left + 1) * tileSize;
    }


    //Vertical movement
    if(vy > 0 && (map[bottom][left] != 0 && !canWalkThrough(map[bottom][left])  || map[bottom][right] != 0 && !canWalkThrough(map[bottom][right])) && !movingIntoAwall){
        vy = 0;
        y = (bottom - 1) * tileSize + 1;
        onGround = true;
        doubleJumpPressed = false;
        showJump = true;
        showRunAnimation = true;
    }

    if (vy < 0 &&
    ((map[top][left] != 0 && !canWalkThrough(map[top][left])) ||
     (map[top][right] != 0 && !canWalkThrough(map[top][right])))) {
        if((map[bottom][left] == 0 || map[bottom][right] == 0)){
            if(!movingIntoAwall){
                y = (top + 1) * tileSize;
                vy = 0;
                peakReached = true;
            }else if (movingIntoAwall && (map[top][left] != 0 && map[bottom][left] == 0 ||
                       map[top][right] != 0 && map[bottom][right] == 0)){
                y = (top + 1) * tileSize;
                vy = 0;
                peakReached = true;
            }
        }
    }

    if(map[bottom][left] == 0 && map[bottom][right] == 0 || (canWalkThrough(map[bottom][left]) && canWalkThrough(map[bottom][right]))){
        onGround = false;
    }

    //if its a coin
    if(map[top][left] == 19){
        map[top][left] = 0;
        ++coinsCollected;
        displayCoinCount = true;
        displayStartTime = millis();
        coinCountX = x;
    }

    else if(map[top][right] == 19){
        map[top][right] = 0;
        ++coinsCollected;
        displayCoinCount = true;
        displayStartTime = millis();
        coinCountX = x;
    }

}

void draw() {
    if(showTittleScreen){
        image(title_screen, 0, 0);
    }

    else if(y >= 20*tileSize){
        x = levelSpawns[level - 1][0] * tileSize;
        y = levelSpawns[level - 1][1] * tileSize;
    }

    else if(!gameOver){
        camX = constrain(x - width/2 + playerWidth/2, 0, (mapWidth - 25)*tileSize);
        camY = 0;
        translate(-camX, -camY);
        drawMap(level);

        idleCounter++;
        if (idleCounter >= idleDelay) {
            idleCounter = 0;
            idleFrame = (idleFrame + 1) % 11;
        }

        detectCollision(maps[level - 1]);

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
                    text(maps[level - 1][row][col], col * tileSize, (row + 1) * tileSize);
                }
            }
        }

        if (displayCoinCount) {
            if (millis() - displayStartTime < 3000) {
                textSize(26);
                fill(0, 0, 0);
                int xPos = coinCountX + 100;
                if(coinCountX >= 1900)
                    xPos = coinCountX - 250;

                text("Collected " + coinsCollected + "/ 12 coins", xPos, 50);
                
            } else {
                displayCoinCount = false;
            }
        } 

        if (displayLevel) {
            if (millis() - displayLevelStartTime < 3000) {
                textSize(36);
                fill(0, 0, 0);
                int xPos = displayLevelX;
                if(xPos >= 1900)
                    xPos = displayLevelX - 200;

                text("Level " + level, xPos, 100);
                
            } else {
                displayLevel = false;
            }
        } 
    }else{
        image(end_game, 0, 0);
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
    if(keyCode == ENTER && showTittleScreen){
        showTittleScreen = false;
    }

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
        onGround = false;
        peakReached = false;
    }

    else if(key == 'w' && !onGround && !doubleJumpPressed ||
            key == 'w' && vy < 0 && !doubleJumpPressed){
        vy = jumpPower;
        yPeak = y - (vy*vy)/(2*gravity);
        doubleJumpPressed = true;
        showJump = false;
        peakReached = false;
    }
}