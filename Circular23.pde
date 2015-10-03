ArrayList<Node> allNodes = new ArrayList<Node>(); 
// allNodes is the entire collection of nodes
int TOT;
// total number of nodes. Depends on data. Don't need to modify
float INC;
// angular displacement between two adjacent nodes
float SCALEFACTOR = 35;
// scalefactor is used to convert the node's importance to its size
// Can be changed to make appropriate size scale when the sizes don't fit
int THRESHOLD = 950;
// confidence level of the connection between two nodes
// controls the transparency of edges
String K="8"; // first NO. in the file name
String LV="4"; // second NO. in the file name
String P="2";  // third NO. in the file name
boolean PAUSE=false; // don't change
int FRAMERATE=60;  // doesn't make a difference when changed
float RADIUS=200; // default radius of the circle. No need to change

String PATHNAME;

void keyPressed()
{  
PAUSE = !PAUSE;  
if (PAUSE)    
  noLoop();  
else    
  loop();
}

float edgeBrightness(float connectionLevel) // calculate transparency/brightness of an edge
{
  float scale = (999.0-THRESHOLD)/160;
float s = (connectionLevel - THRESHOLD)/scale+10;
return s;
}

float impToSize(float imp, float scaleMax, float scaleMin) // convert importance to size
{
float scale = (scaleMax-scaleMin)/SCALEFACTOR;
float s = (imp-scaleMin)/scale+5;
return s;
}

boolean mouseOverCircle(float x, float y, float diameter) 
{  
  return (dist(mouseX, mouseY, x, y) <= (diameter*0.5+2));
}

class Neighbor
{
Node mNode;
int connWeight;
Neighbor(Node node)
{
mNode = node;
connWeight = 200;
}

Neighbor(Node node, int conn)
{
mNode = node;
connWeight = conn;
}
}

class Node
{
int mId;
String mName;
float mImportance;
float mX;
float mY;
//float mZ;
float mScore;   // this is the size of the node
float mColor;
PVector mForce;
ArrayList<Neighbor> neighbors = new ArrayList<Neighbor>();
int red = 0;
//ArrayList<Node> neighbors = new ArrayList<Node>();
Node(int i)
{
mId = i;
mX = random(15,680);
mY = random(15,680);
//mZ = 0;
mScore = 15;
mForce = new PVector(0,0);
mName = "";
mImportance=0.01;
mColor = 0;
}
}
/**************************************************************
***************************************************************
***************************************************************/
void setup()
{
size(920,740);
background (0);
frameRate(FRAMERATE);
String[] lines = loadStrings("order"+K+"_lv"+LV+"_best"+P+".txt");
String[] lines1 = loadStrings("pname"+K+"_lv"+LV+"_best"+P+".txt");
PATHNAME = lines1[lines1.length-1];
// lines is "order" file name, and lines1 is "pname" file name.
int[] num0 = int(split(lines[lines.length-1],' '));
int[] num1 = int(split(lines[0],' '));
int start = num1[0];
// index of the first node
float[] num2 = float(split(lines1[lines1.length-2], ' '));
float[] num3 = float(split(lines1[0], ' '));
float MIN = num2[1]; // MIN importance of the nodes in the file
float MAX = num3[1]; // MAX importance of the nodes in the file
// used to convert importance to size. Upper limit and lower limit.
TOT = num0[0]; // total number of nodes
INC = 2*PI/TOT; // angular displacement between two adjacent nodes.

/* Adjust the size of the circle and the angular displacement bwteen nodes according 
to the total number of nodes */
if (TOT <=10)
RADIUS = 120;
if (TOT >=30)
RADIUS = 240;
if (TOT >=40)
RADIUS = 280;
if (TOT >=50)
{
  SCALEFACTOR = 20; 
  RADIUS = 300;
}
if (TOT >=60)
{
  SCALEFACTOR = 16; 
  RADIUS = 321;
}
if (TOT >=79)
{
  SCALEFACTOR = 12; 
  RADIUS = 340;
}
if (TOT >=120)
{
  SCALEFACTOR = 2; 
  RADIUS = 345;
}

/*Initialize all nodes' attributes*/
for (int k=start; k<=TOT; k++)
{
allNodes.add(new Node(k));
Node curr = allNodes.get(k-1); // minus 1 because node index is 1 more than array index
/*Read in from file to see if the node needs to be red*/
String[] name = split(lines1[k-1],' ');
int[] ifRed = int(split(lines1[k-1],' '));
float[] imp = float(split(lines1[k-1],' ')); // importance
curr.mName = name[0];
curr.red = ifRed[2];
curr.mImportance = imp[1];
curr.mScore = impToSize(imp[1], MAX, MIN);   // compute and assign the size of nodes;
curr.mX = (width/2)+50+RADIUS*cos((3*PI/2)+((k-1)*INC)); // x coordinate
curr.mY = (height/2)+RADIUS*sin((3*PI/2)+((k-1)*INC)); // y coordinate
//curr.mColor += k*255/TOT;  // adjust colors
}

for (int i=0; i<lines.length; i++)
{
int[] num = int(split(lines[i],' '));
if (num[1] > TOT)
  {
    TOT = num[1];
    allNodes.add(new Node(num[1]));
  }
Node temp0 = allNodes.get(num[0]-1);  // because the node's id starts at 1, array index is off by 1;
Node temp1 = allNodes.get(num[1]-1);
temp0.neighbors.add(new Neighbor(temp1, num[2]));
}
println(allNodes.size());
}

void draw()
{
background (0);
PFont f = createFont("Arial",12,true); // Font used to label the nodes
String text =PATHNAME.substring(13);
int x,y,s;
if (text.length() >= 30){
  x = 170; y = 40; s = 14;}
else{
x = 140; y = 60; s = 22;}
fill (0,255,0);
textSize(s);
text(text, x, y);
for (int i=0; i < allNodes.size(); i++)
{
  float ha=1;
  float ha2=11;
  Node temp = allNodes.get(i);
  if (mouseOverCircle(temp.mX, temp.mY, temp.mScore)){
    ha = 3;
    ha2 = 20;
   }
    temp.mScore *=ha;
    noStroke();
    if (temp.red == 1)
      fill(255,0,0);
    else
      fill(0, temp.mColor, 255);
    ellipse(temp.mX, temp.mY, temp.mScore, temp.mScore);
    temp.mScore /= ha;
    textFont(f,ha2);
    fill(255,255,0);
    float setX = width/2+50+(RADIUS+2+0.65*temp.mScore)*cos(3*PI/2+i*INC);
    float setY = height/2+(RADIUS+2+0.65*temp.mScore)*sin(3*PI/2+i*INC);
    if (i == TOT/2 + 1)
      setX -= 6;
    if (i == TOT/2 - 1)
      setX += 7;
    if (i == TOT/2 + 2)
      setY += 4;
    if (i == TOT/2 - 2)
      setY += 4;
    if (i == 1)
    {
      setX += 5;
      setY += 5;
    }
    if (i == TOT-1)
      setX -= 4;
    if (i == TOT-2)
      setX += 5;
    if (i == 2)
      setX -= 4;
    /* decide the positions of the labels*/
    if (i == 0 || i == 1 || i == TOT-1)
      textAlign(CENTER, BOTTOM);
    else if (i == TOT/2 || i == TOT/2 + 1 || i == TOT/2 - 1 )
      textAlign(CENTER, TOP);
    else if (i < TOT/2) 
      textAlign(LEFT);
    else
      textAlign(RIGHT);
    //if (mouseOverCircle(temp.mX, temp.mY, temp.mScore) || (temp.red==1))
    text(temp.mName, setX, setY); // write text
    for (int j=0; j<temp.neighbors.size(); j++){
      Neighbor nei = temp.neighbors.get(j);
      Node temp2 = nei.mNode;
      float e = edgeBrightness(nei.connWeight);
      stroke(255, e); // draw the edge
      line(temp.mX, temp.mY, temp2.mX, temp2.mY); // draw the edge
    }
}
}