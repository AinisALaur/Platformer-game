PImage character_idle;
PImage character_run;
PImage character_jump;
PImage character_fall;

PImage background;
int idleFrame = 0;
int idleDelay = 6;
int idleCounter = 0;

void setup() {
    size(800, 640);
    character_idle = loadImage("../Images/character/Idle.png");
    character_run = loadImage("../Images/character/Run.png");
    character_jump = loadImage("../Images/character/Jump.png");
    character_fall = loadImage("../Images/character/Fall.png");
    background = loadImage("../Images/Background-1.png");
}
void draw() {
    background(255);
    image(background, 0, 0);

    idleCounter++;
    if (idleCounter >= idleDelay) {
        idleCounter = 0;
        idleFrame = (idleFrame + 1) % 11;
    }


    PImage idleScene = character_idle.get(idleFrame * 32, 0, 32, 32);
    image(idleScene, 0, 512);
}