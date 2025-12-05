import java.util.HashMap;
import java.util.HashSet;
import java.util.Arrays;

Table table;
String[] dates; 
HashMap<String, Integer> colors = new HashMap<String, Integer>();

void setup() {
  size(800, 500); //bigger canvas for bigger clocks
  
  table = loadTable("November_Activities_Rounded_CLEANED.csv", "header");
  
  //simple colors for categories
  colors.put("Sleep", color(66, 135, 245)); //blue
  colors.put("Work", color(255, 180, 0)); //yelllow
  colors.put("Exercise", color(50, 200, 50));//green
  colors.put("Hobbies", color(255, 100, 100));//red
  colors.put("Entertainment", color(180, 0, 255));//puprle
  
  //get unique dates from CSV
  HashSet<String> dateSet = new HashSet<String>();
  for (TableRow r : table.rows()) dateSet.add(trim(r.getString("Date")));
  
  dates = dateSet.toArray(new String[0]);
  Arrays.sort(dates);
  
  //one week only, cba to do more than that
  if (dates.length > 7) dates = Arrays.copyOfRange(dates, 0, 7);
  
  noLoop();
  drawWeek();
}

void drawWeek() {
  background(255);
  textAlign(CENTER, CENTER);
  
  float marginX = 60;
  float marginY = 120; 
  float w = (width - marginX*2) / 7;
  float h = 250;
  float r = w * 0.5;
  
  for (int i = 0; i < dates.length; i++) {
    float x = marginX + w*(i + 0.5);
    float y = marginY + h/2;
    drawDayClock(dates[i], x, y, r);
  }
  
  //draw color key in top-right corner
  drawLegend(width - 180, 10);
  
  //draw small demo clock in bottom-right corner
  drawDemoClock(width - 70, height - 70, 45);
}

//simple clock for one day
void drawDayClock(String date, float cx, float cy, float r) {
  String mainCat = getDominantCategory(date);
  strokeWeight(4);
  stroke(colors.get(mainCat));
  noFill();
  ellipse(cx, cy, r*2, r*2);
  
  // draw 24 segments
  strokeWeight(2);
  for (int h = 0; h < 24; h++) {
    String cat = getCategoryForHour(date, h);
    if (cat.equals("")) cat = "Work";
    stroke(colors.get(cat));
    
    float ang = map(h, 0, 24, -HALF_PI, TWO_PI - HALF_PI);  // ai helped significanltly w maths as circles confusing asf
    float x1 = cx + cos(ang)*r*0.7;
    float y1 = cy + sin(ang)*r*0.7;
    float x2 = cx + cos(ang)*r;
    float y2 = cy + sin(ang)*r;
    line(x1, y1, x2, y2);
  }
  
  fill(0);
  noStroke();
  textSize(10);
  text(date, cx, cy + r + 15);
}

//draw color key "legend"
void drawLegend(float x, float y) {
  float boxSize = 12;
  float gap = 6;
  textAlign(LEFT, CENTER);
  textSize(12);
  noStroke();
  
  String[] keys = {"Sleep", "Work", "Exercise", "Hobbies", "Entertainment"};
  for (int i = 0; i < keys.length; i++) {
    float yy = y + i * (boxSize + gap);
    fill(colors.get(keys[i]));
    rect(x, yy, boxSize, boxSize, 2);
    fill(0);
    text(keys[i], x + boxSize + 6, yy + boxSize/2);
  }
}

//draw a small demo 24-hour clock for referencee
void drawDemoClock(float cx, float cy, float r) {
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(8);
  stroke(0);
  strokeWeight(1);
  noFill();
  ellipse(cx, cy, r*2, r*2);
  
  //hour ticks
  for (int h = 0; h < 24; h++) {
    float ang = map(h, 0, 24, -HALF_PI, TWO_PI - HALF_PI);
    float x1 = cx + cos(ang)*r*0.8;
    float y1 = cy + sin(ang)*r*0.8;
    float x2 = cx + cos(ang)*r;
    float y2 = cy + sin(ang)*r;
    line(x1, y1, x2, y2);
    
    //hour labels every 6 hours
    if (h % 6 == 0) {
      float tx = cx + cos(ang)*(r+10);
      float ty = cy + sin(ang)*(r+10);
      text(h + "h", tx, ty);
    }
  }
  
  textSize(10);
  text("Demo Clock", cx, cy + r + 15);
}

//simple most occuring "dominant" category by counting hours
String getDominantCategory(String date) {
  HashMap<String, Integer> count = new HashMap<String, Integer>();
  for (TableRow r : table.rows()) {
    if (!trim(r.getString("Date")).equals(date)) continue;
    String cat = trim(r.getString("Category"));
    count.put(cat, count.getOrDefault(cat, 0) + 1);
  }
  String best = "";
  int bestVal = -1;
  for (String k : count.keySet()) {
    if (count.get(k) > bestVal) {
      best = k;
      bestVal = count.get(k);
    }
  }
  return best;
}

//which category for each hour
String getCategoryForHour(String date, int hour) {
  for (TableRow r : table.rows()) {
    if (!trim(r.getString("Date")).equals(date)) continue;
    String[] startParts = split(r.getString("Start Time"), ":");
    String[] endParts = split(r.getString("End Time"), ":");
    int s = int(startParts[0]);
    int e = int(endParts[0]);
    if (e == 0) e = 24;
    if (hour >= s && hour < e) return trim(r.getString("Category"));
  }
  return "";
}
