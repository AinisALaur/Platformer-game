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

void draw() {
    background(255);
    image(background, 0, 0);

    idleCounter++;
    if (idleCounter >= idleDelay) {
        idleCounter = 0;
        idleFrame = (idleFrame + 1) % 11;
    } 

    if (keyPressed && runLeft) {
        x += runSpeed;
        runCounter++;
        if (runCounter >= runDelay) {
            runCounter = 0;
            runFrame = (runFrame + 1) % 12;
        }

        PImage runScene = character_run.get(runFrame * 32, 0, 32, 32);
        image(runScene, x, y);
        direction = 'l';
    }
    
    else if(keyPressed && runRight){
        x -= runSpeed;
        runCounter++;
        if (runCounter >= runDelay) {
            runCounter = 0;
            runFrame = (runFrame + 1) % 12;
        }

        PImage runScene = character_run.get(runFrame * 32, 0, 32, 32);
        drawFlipped(runScene, x, y);
        direction = 'r';
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
}