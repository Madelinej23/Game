/********* VARIABLES *********/

// Ils contrôle quel écran est actif par les paramètres / la mise à jour
// variable gameScreen. Nous affichons l'écran correct en fonction
// de la valeur de cette variable.
//
// 0: Écran initial
// 1: Écran Game
// 2: Écran Game-over

int gameScreen = 0;

// paramètres de jeu
float gravity = .4;
float airfriction = 0.00001;
float friction = 0.1;

// pointage
int score = 0;
int maxHealth = 100;
float health = 100;
float healthDecrease = 1;
int healthBarWidth = 60;

// paramètre de la balle
float ballX, ballY;
float ballSpeedVert = 0;
float ballSpeedHorizon = 0;
float ballSize = 20;
color ballColor = color(0);

// paramètre de la raquette
color racketColor = color(0);
float racketWidth = 100;
float racketHeight = 10;

// paramètre des murs
int wallSpeed = 5;
int wallInterval = 1000;
float lastAddTime = 0;
int minGapHeight = 200;
int maxGapHeight = 300;
int wallWidth = 80;
color wallColors = color(44, 62, 80);
// Cette liste de tableaux stocke les données des espaces entre les murs. Les murs réels sont dessinés en conséquence.
// [gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored]
ArrayList<int[]> walls = new ArrayList<int[]>();

/********* BLOCK DE SETUP *********/

void setup() {
 size(500, 500);
 // coordonnée initial de la balle
 ballX=width/4;
 ballY=height/5;
 smooth();
}


/********* BLOCK DE DESSIN *********/

void draw() {
 // Afficher le contenu de l'écran actuel
 if (gameScreen == 0) {
 initScreen();
 } else if (gameScreen == 1) {
 gameScreen();
 } else if (gameScreen == 2) {
 gameOverScreen();
 }
}

/********* CONTENU D'ÉCRAN *********/

void initScreen()/**Code l'ecran initial**/ {
 background(236, 240, 241);
 textAlign(CENTER);
 fill(52, 73, 94);
 textSize(30);
 text("JEU CRÉE PAR MADDY ET BELLA", width/2, height/2);
 textSize(20);
 text("Click pour commencer", width/2, height-30);
}
void gameScreen() /**Code pour l'ecran du jeu**/{
  background(255);/**Couleur de l'arriere plan**/
  drawRacket();
  watchRacketBounce();
  drawBall();
  applyGravity();
  applyHorizontalSpeed();
  keepInScreen();
  drawHealthBar();
  printScore();
  wallAdder();
  wallHandler();
}
void gameOverScreen() {
  background(44, 62, 80);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(12);
  text("Your Score", width/2, height/2 - 120);
  textSize(130);
  text(score, width/2, height/2);
  textSize(15);
  text("Clique pour recommencer", width/2, height-30);
}


/********* INPUTS *********/

public void mousePressed() {
  // si sur l'écran initial, lorsque vous cliquez dessus, lancez le jeu
  if (gameScreen==0) { 
    startGame();
  }
  if (gameScreen==2) {
    restart();
   }
}

/********* Autre Fonctions *********/

// Cette méthode définit les variables nécessaires pour démarrer le jeu  
void startGame() {
  gameScreen=1;
}
void gameOver() {
  gameScreen=2;
}

void restart() {
  score = 0;
  health = maxHealth;
  ballX=width/4;
  ballY=height/5;
  lastAddTime = 0;
  walls.clear();
  gameScreen = 1;
}


void drawBall() {
  fill(ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

void drawRacket()/**défini la couleur, largeur et hauteur de la raquette**/{
  fill(racketColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight, 5);
}

void wallAdder() {
  if (millis()-lastAddTime > wallInterval) {
    int randHeight = round(random(minGapHeight, maxGapHeight));
    int randY = round(random(0, height-randHeight));
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored}
    int[] randWall = {width, randY, wallWidth, randHeight, 0}; 
    walls.add(randWall);
    lastAddTime = millis();
  }
}
void wallHandler() {
  for (int i = 0; i < walls.size(); i++) {
    wallRemover(i);
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
  }
}
void wallDrawer(int index) {
  int[] wall = walls.get(index);
  // obtenir les paramètres d'écart de mur 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  // dessiner les murs
  rectMode(CORNER);
  noStroke();
  strokeCap(ROUND);
  fill(wallColors);
  rect(gapWallX, 0, gapWallWidth, gapWallY, 0, 0, 15, 15);
  rect(gapWallX, gapWallY+gapWallHeight, gapWallWidth, height-(gapWallY+gapWallHeight), 15, 15, 0, 0);
}
void wallMover(int index) {
  int[] wall = walls.get(index);
  wall[0] -= wallSpeed;
}
void wallRemover(int index) {
  int[] wall = walls.get(index);
  if (wall[0]+wall[2] <= 0) {
    walls.remove(index);
  }
}

void watchWallCollision(int index) /**detect collision entre la balle et les murs**/ {
  int[] wall = walls.get(index);
  // obtenir les paramètres d'écart de mur
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int wallScored = wall[4];
  int wallTopX = gapWallX;
  int wallTopY = 0;
  int wallTopWidth = gapWallWidth;
  int wallTopHeight = gapWallY;
  int wallBottomX = gapWallX;
  int wallBottomY = gapWallY+gapWallHeight;
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height-(gapWallY+gapWallHeight);


  if (
    (ballX+(ballSize/2)>wallTopX) &&
    (ballX-(ballSize/2)<wallTopX+wallTopWidth) &&
    (ballY+(ballSize/2)>wallTopY) &&
    (ballY-(ballSize/2)<wallTopY+wallTopHeight)
    ) {
    decreaseHealth();
  }
  if (
    (ballX+(ballSize/2)>wallBottomX) &&
    (ballX-(ballSize/2)<wallBottomX+wallBottomWidth) &&
    (ballY+(ballSize/2)>wallBottomY) &&
    (ballY-(ballSize/2)<wallBottomY+wallBottomHeight)
    ) {
    decreaseHealth();
  }

  if (ballX > gapWallX+(gapWallWidth/2) && wallScored==0) {
    wallScored=1;
    wall[4]=1;
    score();
  }
}

void drawHealthBar() {
  noStroke();
  fill(189, 195, 199);
  rectMode(CORNER);
  rect(ballX-(healthBarWidth/2), ballY - 30, healthBarWidth, 5);
  if (health > 60) {
    fill(46, 204, 113);
  } else if (health > 30) {
    fill(230, 126, 34);
  } else {
    fill(231, 76, 60);
  }
  rectMode(CORNER);
  rect(ballX-(healthBarWidth/2), ballY - 30, healthBarWidth*(health/maxHealth), 5);
}
void decreaseHealth() {
  health -= healthDecrease;
  if (health <= 0) {
    gameOver();
  }
}
void score() {
  score++;
}
void printScore() {
  textAlign(CENTER);
  fill(0);
  textSize(30); 
  text(score, height/2, 50);
}

void watchRacketBounce()/**Fait que la balle peut bondir sur la raquette**/ {
  float overhead = mouseY - pmouseY;
  if/**change la vitesse de la balle dépendant de ou ca frappe la raquette**/ ((ballX+(ballSize/2) > mouseX-(racketWidth/2)) && (ballX-(ballSize/2) < mouseX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, mouseY)<=(ballSize/2)+abs(overhead)) {
      makeBounceBottom(mouseY);
      ballSpeedHorizon = (ballX - mouseX)/10;
      // racket moving up
      if (overhead<0) {
        ballY+=(overhead/2);
        ballSpeedVert+=(overhead/2);
      }
    }
  }
}
void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}

//fait que la balle peut aller et bondir dans n'importe qu'elle direction
void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
}
// la balle tombe et touche le sol (ou une autre surface)
void makeBounceBottom(float surface) {
  ballY = surface-(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}
// la balle monte et touche le plafond (ou une autre surface)
void makeBounceTop(float surface) {
  ballY = surface+(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}
//ball frappe objet du coté gauche
void makeBounceLeft(float surface) {
  ballX = surface+(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}
// ball frappe objet du coté droit
void makeBounceRight(float surface) {
  ballX = surface-(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}
// garde la ball sur l'écran
void keepInScreen() {
  // ball frappe le plancher
  if (ballY+(ballSize/2) > height) { 
    makeBounceBottom(height);
  }
  // ball frappe le plafond
  if (ballY-(ballSize/2) < 0) {
    makeBounceTop(0);
  }
  //  ball frappe coté droite de l'ecran
  if (ballX-(ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  // ball frappe coté gauche de l'ecran
  if (ballX+(ballSize/2) > width) {
    makeBounceRight(width);
  }
}
