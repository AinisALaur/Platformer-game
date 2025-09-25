PImage character_idle;
PImage character_run;
PImage character_jump;
PImage character_fall;

PImage background;
int idleFrame = 0;
int idleDelay = 6;
int idleCounter = 0;

int runFrame = 0;
int runDelay = 4;
int runCounter = 0;

int x = 0;
int y = 512;

char direction = 'l';

int runSpeed = 2;

boolean runLeft = false;
boolean runRight = false;

boolean onGround = true;

float vy = 0;
float gravity = 0.5;
float jumpPower = -20;

boolean showRunAnimation = true;
boolean peakReached = false;
float yPeak;

//------------------------------------------------------------

void setup() {
    size(800, 640);
    character_idle = loadImage("../Images/character/Idle.png");
    character_run = loadImage("../Images/character/Run.png");
    character_jump = loadImage("../Images/character/Jump.png");
    character_fall = loadImage("../Images/character/Fall.png");
    background = loadImage("../Images/Background-1.png");
}

void drawFlipped(PImage img, float x, float y) {
  pushMatrix();
  translate(x + img.width, y);
  scale(-1, 1);
  image(img, 0, 0);
  popMatrix();
}

void runLeft(){
    x += runSpeed;
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
    x -= runSpeed;
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

        if (runLeft) {
            x += runSpeed;
            direction = 'l';
        }
        if (runRight) {
            x -= runSpeed;
            direction = 'r';
        }

        if(peakReached == false){
            if(direction == 'l')
                image(character_jump, x, y);
            else
                drawFlipped(character_jump, x, y);
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
        onGround = false;
        peakReached = false;
    }
}