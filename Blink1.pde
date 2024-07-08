
/*
 Step 1 - get isovist to have bounding box.
 Step 2 - check if point is in the ray/triangles
 step 3 - generate points in union of bounding box.
 setp 4 - test if both points in two seperat boxes.
 step 5 - keep running score - this is % of overlap
 setp 6 - check if working.
 
 
 https://en.wikipedia.org/wiki/Multimodal_distribution#General_tests
 
 
 To use
 'o' to open a  SVG file
 'k' to set the number of isovists
 'g' to generate at grid of isovists
 'r' to generate random isovists ( better for less isovists )
 
 'a' to process insovists to compute intergration fractional interagrion ( can take time ) 
 
 '1' .... '0' to switch between values
 't' to save table of isovists + data.
 
 click and drag to move , scroll wheel to zoom
 'control key'/click to add an isovist at the selected point.
 
 'z' - hide down isovists.
 click
 'd' fractiona depth from nearest isovist
 'D' step depth from nearest selected isovist
 
 */
/*
 
 Bury isovits in the edge of each shape.
 Generate spaces from the edges
 Are they the same as E and S partitif'oons ?
 
 */
/*
  Observations -
 
 Fractional conectivity ( Asymetrtical ) looks to work like revelation.
 It looks to be at its highest when moving in to the largest space.
 
 Symetrical high symetry looks to be highest when at points of hi8gh interesection - so
 looks close to maximum depths.
 
 */

import processing.pdf.*;
import java.awt.geom.Line2D.*;
import java.util.*;
import java.io.*;
import java.util.*;
import java.awt.geom.*;
import java.awt.Rectangle;// for RECT . 
import java.lang.Float ;
import javax.swing.JOptionPane;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;

// float scaleFactor = 1.0;
double fZoomFactor  = 1.0;
protected double fMaxZoom = 300.0;
protected double fMinZoom = 1.e-4;
int    fScrollFactor = 0;
final double fIncrement = 1.05;
final float kVerticalSpacesing = 60;
double fOffSetX= 0 ;
double fOffSetY = 0;
final float myInfinity = 100_000f;

double gMinx = Integer.MAX_VALUE ;
double gMinY = Integer.MAX_VALUE ;
double maxX = -Integer.MAX_VALUE ;
double maxY = -Integer.MAX_VALUE ;

PShape drawing = null ;
boolean isLoading = false ;
HashSet<GeneralPath>              unique = new HashSet<GeneralPath>( ) ;
java.util.List<GeneralPath>       shapes = new ArrayList<GeneralPath>(8);
GeneralPath gBoundingShapeBoundary       = null ;

java.util.List<PVector> points   = new ArrayList<PVector>();
java.util.List<PVector> rays     = new ArrayList<PVector>();
java.util.List<Isovist> isovists = new ArrayList<Isovist>();
java.util.List<Isovist> badIsovists = new ArrayList<Isovist>();

boolean gScreenShotInProgess = false ;
boolean gPrintable = false ;

//-----------------------------------------------------------------------

//---------------------------------------------------------------------
void updateFromNode( NodeInGraph start, Set<NodeInGraph> consideration)
{
  assert start != null ;
  assert consideration != null;

  for ( NodeInGraph it : start.connectedToWeighted.keySet())
  {
    float addedDepth = start.connectedToWeighted.get(it);
    if ( (start.fDepth + addedDepth) <  it.fDepth )
    {
      it.fDepth = start.fDepth + addedDepth;
      consideration.add( it ) ;
    }
  }
}
void buildSmallestPathFrom( Isovist start, java.util.List<Isovist> all  )
{
  //println( all);
  // O(N)
  for ( NodeInGraph it : all ) {
    it.fDepth = Float.POSITIVE_INFINITY;
  }

  Set<NodeInGraph> processed     = new HashSet<NodeInGraph>() ;
  Set<NodeInGraph> consideration = new HashSet<NodeInGraph>() ;

  start.fDepth = 0.0f;
  processed.add( start) ;
  updateFromNode( start, consideration) ;
  //println("Considering " , consideration );
  do // Worst case O(N)
  {
    // find one with smallest fDepth
    float smallestDepth = Float.POSITIVE_INFINITY;
    NodeInGraph smallest = null ;
    for ( NodeInGraph it : consideration ) // O(N) worste case
    {
      if (it.fDepth < smallestDepth )
      {
        smallest = it ;
        smallestDepth =it.fDepth;
      }
    }
    //println("BEST", smallest, smallestDepth ) ;
    updateFromNode( smallest, consideration) ;
    consideration.remove(smallest);
    processed.add(smallest);

    //println("Considering " , consideration );
  }
  while ( consideration.size()> 0 ) ;


  // println( all);
  // println("Processed",processed);
}
//---------------------------------------------------------------------
void testGraph()
{
  ArrayList<Isovist> all = new ArrayList<Isovist>() ;
  Isovist a = new Isovist("A");
  all.add(a);
  Isovist b = new Isovist("B");
  all.add(b);
  Isovist c = new Isovist("C");
  all.add(c);
  Isovist d = new Isovist("D");
  all.add(d);
  Isovist e = new Isovist("E");
  all.add(e);
  a.connect(b, 0.1 ) ;
  b.connect(a, 0.1);
  b.connect(c, 1.0 ) ;

  c.connect(b, 1.0);
  c.connect(d, 1.0);
  d.connect(c, 1.0);

  a.connect( e, 0.5 ) ;
  e.connect( a, 0.5);
  e.connect( c, 0.2);
  c.connect( e, 0.2);

  buildSmallestPathFrom( c, all ) ;

  float total = 0.0f;
  for ( Isovist it : all )
  {
    total += it.fDepth;
  }
  println("total", total );
  assert total == 2.7f;
}

//--------------------------------------------------------------------------
float x1 = 10;
float y1 = 10;

float x2 = 200.0;
float y2 = 200.0  ;

float x3 = 100.0;
float y3 = 10.0;

float px = 50.0;
float py = -50.0;
//--------------------------------------------------------------------------
public static double calculateTriangleArea(PVector p1, PVector p2, PVector p3)
{
  double side1 = p1.dist(p2);
  double side2 = p2.dist(p3);
  double side3 = p3.dist(p1);

  double s = (side1 + side2 + side3) / 2; // calculate the semi-perimeter
  double area = Math.sqrt(s * (s - side1) * (s - side2) * (s - side3)); // Heron's formula

  return area;
}
//--------------------------------------------------------------------------
boolean testIsInsideTriangle( )
{
  return insideTriangle( px, py, x1, y1, x2, y2, x3, y3);
}
//--------------------------------------------------------------------------
void testTriangle()
{
  stroke( 255, 0, 0);

  boolean bx =  insideTriangle(convertWindowToMapCoordX(mouseX),
    convertWindowToMapCoordY(mouseY),
    x1, y1, x2, y2, x3, y3 ) ;
  if ( bx ) stroke( 0, 255, 0);
  triangle( x1, y1, x2, y2, x3, y3 ) ;
}
//--------------------------------------------------------------------------
boolean insideTriangle(   double pX, double pY,
  double x1, double y1,
  double x2, double y2,
  double x3, double y3 )
{
  int s1 = java.awt.geom.Line2D.relativeCCW( x1, y1, x2, y2, pX, pY);
  int s2 = java.awt.geom.Line2D.relativeCCW( x2, y2, x3, y3, pX, pY);
  int s3 = java.awt.geom.Line2D.relativeCCW( x3, y3, x1, y1, pX, pY);

  if ( s1 == -1 ) return false ;
  if ( s2 == -1 ) return false ;
  if ( s3 == -1 ) return false ;
  return true ;
}
Isovist  intersetTest, intersetTest2 ;

boolean gTestIntersections = false;
boolean gTestGraph = false ;

//--------------------------------------------------------------------------
/*
 
 
 */
void setup()
{
  size( 1024, 800);
  assert testIsInsideTriangle() == false ;
  fOffSetY = width/2 ;
  fOffSetX = height/2;
  if (gTestIntersections!=true)
  {
    // readSVGFile( "/Users/nickdalton/Dropbox (Northumbria University)/StocasticIsovistsPaper/AttenudatedIsovist_machine/AttenudatedIsovistMachine/billIntelligibile.svg") ;
  }
  //readySVG
  if ( gTestGraph)
  {
    testGraph();
    testGraphOmni();
  }

  if (gTestIntersections )
  {
    intersetTest = new Isovist( new PVector(100f, 100f ) ) ;
    intersetTest.initRays();

    intersetTest.trimRaysToThisLine(50, 50, 150, 50);
    intersetTest.trimRaysToThisLine(150, 50, 150, 150);
    intersetTest.trimRaysToThisLine(150, 150, 50, 150);
    intersetTest.trimRaysToThisLine(50, 150, 50, 50 );
    intersetTest.makeOutlineFromRays();
    isovists.add( intersetTest);

    intersetTest2 = new Isovist( new PVector( random(100, width-100), 200 ) ) ; //200,200));

    intersetTest2.initRays( 80);
    intersetTest2.makeOutlineFromRays();
    //intersetTest.itrimRaysToThisLine
    isovists.add( intersetTest2);

    gDrawMode = true ;
    gshowHIsovist = true;
    gTestIntersections = true ;
    // frameRate( 4 ) ;
  }
  // println( eNegativeConnectivity
  // println( java.awt.geom.Line2D.relativeCCW( x1, y1, x2, y2, px, py));
}
//--------------------------------------------------------------------------
void computeAllFractionalDepthAssumingEdgesAreBuilt()
{
  for ( Isovist it : isovists )
  {
    buildSmallestPathFrom( it, isovists   )  ;
    double t = 0.0;

    for ( Isovist k : isovists )
    {
      t +=  k.fDepth;
    }
    it.totalfDepth = (float) t  ;
  }
}
//--------------------------------------------------------------------------
void saveTable()
{
  println("Saving table");
  Table    intergrationTable  = new Table();
  intergrationTable.addColumn("X");
  intergrationTable.addColumn("Y");

  intergrationTable.addColumn("VGATotalDepth");
  intergrationTable.addColumn("AsymetricTotalDepth");
  intergrationTable.addColumn("SymetricTotalDepth");

  intergrationTable.addColumn("VGA_Connectivity");
  intergrationTable.addColumn("Asymetric_CONNECTIVITY");
  intergrationTable.addColumn("Symetric_CONNECTIVITY");

  for ( Isovist it : isovists )
  {
    TableRow newRow = intergrationTable.addRow();

    newRow.setFloat("X", it.center.x );
    newRow.setFloat("Y", it.center.y );

    newRow.setFloat("VGATotalDepth", it.totalDepth );
    newRow.setFloat("AsymetricTotalDepth", it.totalfDepth );
    newRow.setFloat("SymetricTotalDepth", it.getValue( kSYMETRIC_TOTAL_DEPTH, 0 ) );
    newRow.setFloat("VGA_Connectivity", it.getValue(ePureConnectivity, 0) );
    newRow.setFloat("Asymetric_CONNECTIVITY", it.getValue(kFRACTIONAL_CONNECTIVITY, 0) );
    newRow.setFloat("Symetric_CONNECTIVITY", it.getValue(kSYMETRIC_CONNETIVITY, 0) );
  }

  saveTable(intergrationTable, "data/comparison.csv");
}
//--------------------------------------------------------------------------
/*
 cluster method.
 1. give each node a 'color ( group )
 2. look around - next one is the most popular for your nehbourhood ) ( by weight)
 3. make the next the current ( for everyone )
 4. repeat until don't move or N times
 */
class IsoPair extends Isovist
{
  Isovist childA, childB ;

  IsoPair( Isovist a, Isovist b )
  {
    super( a.getCenter().lerp( b.getCenter(), 0.5  )  );

    this.myColor = lerpColor( a.myColor, b.myColor, 0.5f ) ;
    this.depth                = 0;
    this.totalDepth           =  (a.totalDepth + b.totalDepth)/2;

    this.myGradientDepth = (a.totalDepth + b.totalDepth)/2;
    this.myCurrentValue  = (a.myCurrentValue + b.myCurrentValue)/2;
    this.totalfDepth    =      (a.totalfDepth + b.totalfDepth)/2;
    ;
    this.fDepth          =  (a.fDepth + b.fDepth)/2;
    this.outline         = a.outline ;

    // Make this point the middle of points
    /* float clusterCoif   ;
     int kMeansCluster ;
     boolean selected  ;
     float  minH , maxH = 0, minV = 0, maxV = 0 ;
     
     //java.util.List<PVector>  rays; // MERGE ?
     
     // make thse merge
     // Map<NodeInGraph,Float> connectedToWeighted;
     
     */
    Set<Isovist> cons = new HashSet<Isovist>( a.connections  ) ;
    cons.addAll( b.connections ) ;

    this.connections = new ArrayList<Isovist>( cons ) ;
    this.connectedToWeighted = new  HashMap<NodeInGraph, Float>(a.connectedToWeighted);
    // connectedToWeighted.add( b.connectedToWeighted);
  }
}
/*
 look for every connection you have.
 To make this work when you add a connection you have to
 */
void groupIsoivstsVersion1()
{
  float WEIGHT = 64.0 ;
  println("grouping");
  Isovist bestA = null, bestB = null ;
  double bestD = Float.MAX_VALUE ;
  float d = Float.NaN ;
  // use the connectivity list.. x
  for ( Isovist from : isovists )
  {
    for ( Isovist too : isovists  )
    {
      if ( from == too ) continue ;
      if ( sq( from.myCurrentValue - too.myCurrentValue ) > 0.1 ) continue ;
      d = from.howFar( too ) ;
      if ( d < bestD ) // look for smallest distance.
      {
        bestA = from ;  // check mid point not in a building.
        bestB = too ;
        bestD = d ;
      }
    }
  }
  if ( bestA == null || bestB != null )
  {
    assert bestA != null ;
    assert bestB != null ;
    println("grouping: smallest distance", bestA.howFar(bestB ), " diff",
      sq( bestA.myCurrentValue - bestB.myCurrentValue ) * WEIGHT, bestA, bestB  ) ;
    isovists.remove( bestA ) ;
    isovists.remove( bestB ) ;

    IsoPair pair = new IsoPair( bestA, bestB ) ;
    isovists.add( pair ) ;
  } else
  {
    println("could not find anything.");
  }
}

//---------------------------------------------------------------------
void processAllFractionalIntergration( )
{
  final int K =  gNumberOfIsovists ;
  jGraph = null ;
  if ( (isovists == null) ||  isovists.size()==0)
  {
    println("Generate stocastic isovist k= ", K );
    generateStocasticIsovist( shapes, K ); //  281  );
    println("ENDED isovist generation\nProcess All Area Isoivst");
  }
  processAllAreaIntersections( isovists );
  println("Build shortest paths");
  computeAllFractionalDepthAssumingEdgesAreBuilt();
  println("Depth compuations Complete");
  colourBy( kTOTAL_FRACITON_INTEGRATION ) ;
  processTraditionalDepthWithGraphBuilt( ) ;
  println("END OF THREAD");
}
//-------------------------------------------------------------
void processTraditionalDepthWithGraphBuilt()
{
  println("Compute step depths..");
  println(" Isovists" + isovists.size());
  ArrayList<Isovist> gDeadIsovists = new ArrayList<Isovist>() ;
  do
  {
    gDeadIsovists = new ArrayList<Isovist>() ;
    for ( Isovist it : isovists )
    {
      float g =  computeStepDepthFrom(   it, gDeadIsovists );
      // println("D", it.connections.size());
    }

    if ( gDeadIsovists.size()> 0 )
    {
      println("gDeadIsovists ", gDeadIsovists.size());
      // more surgical
      // remove all refera
      isovists.removeAll( gDeadIsovists ) ;
      // processAllAreaIntersections( isovists ); // is this nessasry if not connected.
      println("processed again" + isovists.size());
    }
  }
  while ( gDeadIsovists.size()> 0 ) ;
  println("processTraditionalDepthWithGraphBuilt complete." );
}
//-------------------
/* **************************************************************************
 1. Import an SVG file with command 'o'
 2. use 'n' to set the number of isovists lines.
 3. use 'a' to process the document. ( will take a long time).
 4. click 5 to get log kLogTOTAL_FRACITON_INTEGRATION
 
 click 6 for kLog_eTOTAL_DEPTH_MEASURE ( i.e normal intergration )
 
 'b' to toggle black background.
 
 Depth
 1. click on isovist
 2. 'd' does fractional depth
 3.    ( eTOTAL_DEPTH_MEASURE )
 'D' does depth from selection.
 
 ***************************************************************************/
void gridOfInsovists(java.util.List<GeneralPath> buidlings, int noOfIsovists )
{
  assert noOfIsovists > 0 ;

  int N = (int) sqrt( noOfIsovists ) * 2 ;
  println("Grid.  N = ", N);
  assert noOfIsovists> 0 ;
  assert  gMinx <= maxX;

  rays  = new ArrayList<PVector>();
  for ( int i  = 0; i < 360; i++) rays.add( PVector.random2D());

  println("generate VGA grid isovists ::Start", gMinx, maxX, " )( ", gMinY, maxY, " N", N  );
  //if(rays!=null )return ;
  float hx ;
  for ( int h = 0; h <= N; h++ )
  {
    hx = map((float)h, 0f, (float)N, (float)gMinx+1, (float)maxX-1 ) ;
    for ( int y = 0; y < N; y++ )
    {
      float vy = map( (float)y, 0f, (float)N, (float)gMinY+1, (float)maxY-1 );
      PVector v = new PVector( hx, vy );
      // println("# point # [", h,"," , v,"]" ,  hx , vy , v, pointIsValid(v, buidlings)  ) ;
      //points.add(  v ) ;

      if ( pointIsValid(v, buidlings) )
      {
        //println("Isovist ", v ) ;
        points.add(  v ) ;
        Isovist iso = new Isovist( v ) ;
        boolean px = iso.computIsovist(shapes ) ;

        if ( px == true  )
        {
          assert iso.validMinMax() == true :
          " the isovist is not computed, min, max not set";
          assert isovists != null;
          synchronized( isovists )
          {
            isovists.add( iso) ;
          }
        }
      }
    }
  }
  println("END. Grid line. number of isovists=  ", isovists.size() );

  // addStocasticIsovist( buidlings, size ) ;
  // v = PVector.random2D(); //try again ..
  //  while ( pointIsValid(v, buidlings)== false  );// dont fall in a building.
  // points.add(  v ) ;
  //  Isovist iso = new Isovist( v ) ;
  //  iso.computIsovist(shapes ) ;
  //   synchronized( isovists ) {  isovists.add( iso) ; }


  //gBoundingShapeBoundary
  // gBoundingShapeBoundary
}
void alert( String it)
{
  assert it != null ;
  JOptionPane.showMessageDialog(null, it, "Alert", JOptionPane.INFORMATION_MESSAGE);
}
//--------------------------------------------------------------------------
// IGraph-networkX
/*
 To use
 'o' to open a  SVG file
 'k' to set the number of isovists
 'g' to generate at grid of isovists
 'r' to generate random isovists ( better for less isovists )
 
 'a' to process insovists to compute intergration fractional interagrion
 '1' .... '0' to switch between values
 't' to save table of isovists + data.
 
 click and drag to move , scroll wheel to zoom
 'control key'/click to add an isovist at the selected point.
 
 'z' - hide down isovists.
 click
 'd' fractiona depth from nearest isovist
 'D' step depth from nearest selected isovist
 
 
 
 */
boolean gShowJgraph = false ;
Map<Float, java.util.List<Isovist>> jGraph = null;
int gNumberOfClusters = 0 ;
int gNumberOfIsovists = 256 * 2;
int gLastColorMeasure = 0 ;
boolean gIntersect = false ;
boolean gshowHIsovist = false ;
boolean gshowWeights = false ;

void keyReleased()
{
  //println("key " + key ) ;
  try
  {
    if ( key == '=' ) {
      gIsoivstDotSize += 0.5;
    }
    if ( key == '-' && gIsoivstDotSize >= 0.5 ) {
      gIsoivstDotSize-= 0.5;
    }
    if ( key == 'z' ) {
      gshowHIsovist = !gshowHIsovist;
      return ;
    }
    if ( key == 'm' ) {
      gDrawMode = !gDrawMode;
      return;
    }

    final int K =  gNumberOfIsovists  ; // 256*1; // 256 ;
    if ( key == 'x' ) {
      gIntersect = true ;
      return ;
    }

    if ( key == 'l' ) {
      gDrawIsovistLinks = ! gDrawIsovistLinks ;
      return ;
    }
    if ( key == 'L' ) {
      gshowWeights = !gshowWeights ;
      gDrawIsovistLinks = ! gDrawIsovistLinks ;
      return ;
    }

    if ( key == 'g' ) {
      gridOfInsovists(shapes, gNumberOfIsovists ) ;
      return ;
    }
    if ( key == 'G' ) {
      groupIsoivsts( ) ;
      return ;
    }

    if ( key == 'n' )  // ask for number of isovists.
    {
      String input = JOptionPane.showInputDialog( "Enter the number of isovis points \n(512 is good):",
        ""+gNumberOfIsovists );

      if ( input == null ) {
        println("No change");
        return ;
      }
      int numberOfIsovists = 0;
      try {
        numberOfIsovists = Integer.parseInt(input);
        if ( numberOfIsovists < 1)
        {
          JOptionPane.showMessageDialog(null, input+ " ? Please enter a valid number.",
            "Error", JOptionPane.ERROR_MESSAGE);
          return ;
        }
        gNumberOfIsovists = numberOfIsovists;
      }
      catch (NumberFormatException e) {
        JOptionPane.showMessageDialog(null, input+ " is not a number ! Please enter a valid number.",
          "Error", JOptionPane.ERROR_MESSAGE);
      }
    }
/*
    if ( key == 'c' )  // Cluster.
    {
      doCluster();
      return ;
    }*/ 

    if ( key == '1' ) {
      colourBy( gLastColorMeasure = ePureConnectivity, "ePureConnectivity" )  ;
   't   return;
    }
    if ( key == '2' ) {
      colourBy(gLastColorMeasure =  kFRACTIONAL_CONNECTIVITY, "kFRACTIONAL_CONNECTIVITY"    ) ;
      return  ;
    }
    ///kTOTAL_FRACITON_INTEGRATION
    if ( key == '3' ) {
      colourBy(gLastColorMeasure =  kSYMETRIC_CONNETIVITY, "kSYMETRIC_CONNETIVITY");
      return ;
    }

    if ( key == '4' ) {
      colourBy(gLastColorMeasure =  eTOTAL_DEPTH_MEASURE, "eTOTAL_DEPTH_MEASURE_VGA");
      return ;
    }
    if ( key == '5' ) {
      colourBy( gLastColorMeasure = kTOTAL_FRACITON_INTEGRATION, "kTOTAL_ASYM_FRACITON_INTEGRATION"  );
      return;
    }
    if ( key == '6' ) {
      colourBy( gLastColorMeasure =  kSYMETRIC_TOTAL_DEPTH, "kSYMETRIC_TOTAL_DEPTH" );
      return;
    }

    if ( key == '7' ) {
      colourBy( gLastColorMeasure=  kLog_eTOTAL_DEPTH_MEASURE, "kLog_eTOTAL_DEPTH_MEASURE");
      return;
    }
    if ( key == '8' ) {
      colourBy( gLastColorMeasure = kLogTOTAL_FRACITON_INTEGRATION, "kLogTOTAL_FRACITON_INTEGRATION" );
      return;
    }
    if ( key == '9' ) {
      colourBy( gLastColorMeasure=  kLog_SYMETRIC_TOTAL_DEPT, "kLog_SYMETRIC_TOTAL_DEPT");
      return;
    } // integer depth

    if ( key == '0' ) {
      colourEvenlyBy( gLastColorMeasure);
      return;
    }
   if( key == 'c') 
   { 
      colourBy( gLastColorMeasure=  kClusterCoiff, "kClusterCoiff");
      return ; 
   } 
   
   if ( key == '/' ) {
      colourBy( gLastColorMeasure=  kJACOBIAN_BY_CON, "kJACOBIAN_BY_CON");
      return;
    } 


    if ( key == '(' ) {  colourEvenlyBy( eDEPTH ); return; }
    if ( key == ')' ) {  colourEvenlyBy( kLogTOTAL_FRACITON_INTEGRATION ); return; }
    if ( key == '*' ) { colourBy(  gLastColorMeasure = eTOTAL_DEPTH_MEASURE , "TOTAL_DEPTH(RAW)" );  return; }
    if ( key == 'b') {  gPrintable = ! gPrintable; return ;   }
    if( key == 'B') { gDebugBoundary = ! gDebugBoundary; return ; } 
    
    if (  key == 'o' )
    {
      selectInput("Select a .SVG file to process:", "SVGfileSelected");
      return ;
    }
    if ( key == 't') {
      saveTable();
      return  ;
    }
    if ( key == 'f' )
    {
      thread("processAllFractionalIntergration");
      return ;
    }
    if ( key == 'F')
    {
      println("RE-COMPUTE fractional assuming all built. ");
      computeAllFractionalDepthAssumingEdgesAreBuilt();
      println("END");
      return ;
    }
    /* if ( key == 'i' ) // compute fractional intergration.
     {
     println("processAllFractionalIntergration");
     cursor(WAIT);
     processAllFractionalIntergration() ;
     // draw s dots and lines.
     cursor(ARROW);
     println("Done.");
     return ;
     }
     if ( key == 'I' ) // ALL intergration
     {
     cursor(WAIT);
     println("Compute normal intergration");
     if ( isovists.size() <= 0 )
     {
     jGraph = null ;
     println("Generate stocastic isovist", K );
     generateStocasticIsovist( shapes, K ); //  281  );
     println("ENDED isovist generation\nProcess All Area Isoivst " + isovists.size());
     processAllAreaIntersections( isovists );
     println("End of processAllAreaIntersections " + isovists.size() );
     }else
     {
     println("Already exitsintg isovists");
     }
     
     processTraditionalDepthWithGraphBuilt( ) ;
     
     println("Classic total Depth computed\nCompute fractions again");
     computeAllFractionalDepthAssumingEdgesAreBuilt( ) ;
     println("End of fraction compuation");
     colourBy( eTOTAL_DEPTH_MEASURE) ;
     
     cursor(ARROW);
     return ;
     }// end of key
     */


    if ( key == '∂' )//∂
    {
      println("Omni depth");
      if ( isovists == null || isovists.size()==0 ) {
        alert("No isoivsts");
        return ;
      }

      if ( gSelectedItem > 0)
      {
        buildSmallestPathFromOmni( isovists.get(gSelectedItem), isovists   )  ;
      } else
      {
        alert("nothing selected");
      }
      println("End Omni depth");
      colourBy( kSYMETIC_STEP_DEPTH ) ;
      return ;
    }
    // Draw the J-graph dummy.
    if ( key == 'd' )
    {
      cursor(WAIT);
      if ( gSelectedItem > 0)
      {
        buildSmallestPathFrom( isovists.get(gSelectedItem), isovists   )  ;
        jGraph = new HashMap<Float, List<Isovist>>( ) ;
        float minVal = Float.MAX_VALUE ;
        float maxVal = -Float.MAX_VALUE ;
        for ( Isovist v : isovists )
        {
          Float dpt = v.getFractionalDepth();
          if ( Float.isInfinite(dpt)) continue ;
          minVal = min(minVal, dpt);
          maxVal = max(maxVal, dpt);
        }
        for ( Isovist v : isovists )
        {
          Float dpt = v.getFractionalDepth();
          if ( Float.isInfinite(dpt)) continue ;
          float stepVal   = (int)map( dpt, minVal, maxVal, 0, 18);
          if ( ! jGraph.containsKey(stepVal ))
          {
            jGraph.put( stepVal, new ArrayList<Isovist>( ) ) ;
          }
          List<Isovist> level = jGraph.get( stepVal ) ;
          level.add( v ) ;
          // println( dpt, level.size()) ;
        }
        gShowJgraph = true;
        colourBy( kDEPTH_FRACION ) ; //kSYMETIC_STEP_DEPTH
      } else println("******Nothing selected*****");
      // draw s dots and lines.
      cursor(ARROW);
      return ;
    }

    if ( key == 'D' ) // do step depth from intersection .
    {
      if ( gSelectedItem>= 0)
      {
        cursor(WAIT);
        //println("Generate stocastic isovist", K );
        //generateStocasticIsovist( shapes, K ); //  281  );
        println("ENDED isovist");
        //processAllAreaIntersections( isovists );

        computeStepDepthFrom( isovists.get(gSelectedItem), isovists   )  ;
        colourBy( eDEPTH ) ;
        // draw s dots and lines.
        cursor(ARROW);
      }
      return ;
    }
    if ( key == 'p') // do overlap dragion. interagrion
    {
      cursor(WAIT);
      println("Generate stocastic isovist" );
      generateStocasticIsovist( shapes, 256 ); //  281  );
      println("ENDED isovist");
      processAllAreaIntersections( isovists );
      colourBy( kTOTAL_AREA_OVERLAP_FRACTION ) ;
      // draw s dots and lines.
      println("Complete");
      cursor(ARROW);
      return ;
    }
    if ( key == 'a' ) // Process ALL Measures
    {
      // us this if you have made isoivsts by hand or by grid.
      if ( isovists == null || isovists.size()==0 )
      {
        JOptionPane.showMessageDialog(null, "no isovists= use 'g'rid or 'r'andom to generate", "Alert", JOptionPane.INFORMATION_MESSAGE);
        return ;
      }
      cursor(WAIT);
      println("Generate intersections");
      processAllAreaIntersections( isovists );// build graph

      println("Classic total Depth computed");
      processTraditionalDepthWithGraphBuilt( );// traditional classic depths
      println("Fractional Computation." );
      computeAllFractionalDepthAssumingEdgesAreBuilt( ) ;// new
      println("End of fraction compuation");
      println("computeAllFractionalDepthAssumingEdgesAreBuiltOmni");
      computeAllFractionalDepthAssumingEdgesAreBuiltOmni() ; //

      colourBy( kLogTOTAL_FRACITON_INTEGRATION ) ;
      println("Complete");
      cursor(ARROW);
      return  ;
    }
    if ( key == 'A' ) // just process all area intersections
    {
      cursor(WAIT);
      println("Generate intersections");
      processAllAreaIntersections( isovists );
      colourBy( kTOTAL_AREA_OVERLAP_FRACTION ) ;
      println("Generate intersections Complete");
      cursor(ARROW);
      return  ;
    }
    if ( key == 'r')
    {
      cursor(WAIT);
      println("Genlerate 'r'andom isovist " + K );
      generateStocasticIsovist( shapes, K ); //  281  );
      println("END random  isovist #=", isovists.size( ) );
      cursor(ARROW);
      return ;
    }

    if ( key == 's')
    {
      gScreenShotInProgess = true;
      return ;
    }
    if ( key == 'e') {
      doExportOfShapes();
      return ;
    }
  }
  catch( NullPointerException e )
  {
    println(e);
  }
}
/*
 screen shot.
 */
//-----------------------------------------------------------
void doExportOfShapes()
{
  println("Exporting");
  StringBuffer bx  = new StringBuffer() ;
  float[] pts = new float[2];

  String fileName = sketchPath("coords.txt");

  FileWriter writer = null;
  try {
    File myFile = new File(fileName);
    String absolutePath = myFile.getAbsolutePath();
    System.out.println(absolutePath);
    writer = new FileWriter(fileName);

    for ( GeneralPath p : shapes)
    {
      writer.append("#SHAPE\n");
      PathIterator pi = p.getPathIterator(null);

      while (!pi.isDone())
      {
        int type = pi.currentSegment(pts);
        if (type == PathIterator.SEG_MOVETO)
        {
          writer.append( " " + pts[0] + "," +  (-pts[1])+ "\n");
        }
        if (type == PathIterator.SEG_LINETO)
        { // LINETO
          writer.append( " " + pts[0] + "," +  (-pts[1])+ "\n");
        }
        if (type == PathIterator.SEG_CLOSE)
        {
          writer.append("#END_SHAPE\n");
        }
        pi.next();
      }
    }
    writer.close();

    System.out.println("Successfully wrote to the file.");
  }
  catch (IOException e) {
    System.out.println("An error occurred.");
    e.printStackTrace();
  }
  finally {
    try {
      if (writer != null) {
        writer.close();
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}

//
// Shinich Iida 2005 pedestrian data set.
// discovery.ucl.ac.uk/id/eprint/1232/

/*
 
 */
/*
  void drawShape(GeneralPath p, color col )
 {
 if ( p==null) return ;
 noFill() ;
 stroke( col  ) ;
 PathIterator pi = p.getPathIterator(null);
 float[] pts = new float[2];
 while (!pi.isDone())
 {
 int type = pi.currentSegment(pts);
 if (type == PathIterator.SEG_MOVETO)
 {
 beginShape();
 vertex(pts[0], -pts[1]);
 }
 if (type == PathIterator.SEG_LINETO)
 { // LINETO
 vertex(pts[0], -pts[1]);
 //println(pts[0]+","+pts[1]);
 }
 if (type == PathIterator.SEG_CLOSE)
 {
 endShape( CLOSE );
 }
 pi.next();
 }
 }
 */

//-----------------------------------------------------------
void SVGfileSelected(File selection)
{
  if (selection == null)
  {
    println("Window was closed or the user hit cancel.");
  } else
  {
    println("User selected " + selection.getAbsolutePath());
    // println("Name =", fileName = selection.getName().replace(".svg", "")) ;
    cursor( WAIT ) ;
    readSVGFile( selection.getAbsolutePath() ) ;

    cursor( ARROW ) ;
  }
}
//--------------------------------------------------------------------------
void draw()
{
  
  if (  gScreenShotInProgess == true ) beginRecord(PDF, gMessage+ hour()+ "_"+minute()+"output.pdf");

  if ( gPrintable ) background(0);
  else background(255);
   if( isLoading ==true){ text("LOADING", 0,0); return ;  } 
   
  smooth();

  pushMatrix();
  translate((float)fOffSetX, (float) fOffSetY ) ; //  getWidth()/2, getHeight()/2) ;
  //scale(0.75 , 0.75) ;
  scale((float)fZoomFactor, (float)fZoomFactor);
  drawScaled();
  popMatrix();

  fill( 255);

  textSize(18);
  text( gMessage +  " average = " + gCurrentValueAverage, width/2, 12);

  if (  gScreenShotInProgess == true )
  {
    gScreenShotInProgess = false ;
    println("Dumped");
    endRecord();
    return ;
  }
}
//--------------------------------------------------------------------------
void drawJGraph()
{ //Map<Float,List<Isovist>> jGraph = null;
  final float SK =  (float)(maxY - gMinY ) / 17;
  if (jGraph == null) return ;

  for ( Float v : jGraph.keySet())
  { //gMinx, maxX, gMinY, maxY
    stroke( 200); // grey
    line( (float) maxX+0f, (float) -(gMinY+ (SK*v)),
      (float) maxX + 100f, (float) -(gMinY+ (SK*v)) );
    text( ""+v, (float) maxX + 100, (float)  -(gMinY+ (SK*v)) ) ;
    List<Isovist> vals = jGraph.get(v);
    assert vals != null ;
    for ( int a = 0; a < vals.size(); a++ )
    {
      float r = 4;
      float x =  a*(r+1);
      Isovist it = vals.get(a);
      fill( it.myColor);
      noStroke();
      circle( (float) maxX+x, (float) -(gMinY+ (SK*v)), r ) ;
    }
  }
}
//--------------------------------------------------------------------------
void debugBoundaryDuringDraw()
{ 
   if(gDebugBoundary)
      { 
        stroke( #F2EA4E ) ;
        strokeWeight(4);
        line( (float)gMinx, (float)-gMinY, (float)maxX, (float)-gMinY ) ;
        line( (float)maxX, (float)-gMinY, (float)maxX, (float)-maxY ) ;
        line( (float)gMinx, (float)-gMinY, (float)gMinx, (float)-maxY ) ;
        line( (float)gMinx, (float)-maxY, (float)maxX, (float)-maxY ) ;
      } 
      
   frameRate(40);// back to normal. 
  if ( keyPressed == true && key == ' ')
  {
        frameRate(1) ;
        PVector v = PVector.random2D();
        v.x = random( (float)gMinx, (float)maxX ) ;
        v.y = random( (float)gMinY, (float)maxY ) ;
        strokeWeight(0.01);

        fill( 0, 255, 0);  // green is clear space
        if (   gBoundingShapeBoundary.contains(  v.x, v.y ) == false )
        {
          fill(0, 0, 255);
        }
        strokeWeight(1);
        
        Rectangle bnds = gBoundingShapeBoundary.getBounds(); 
        for ( GeneralPath p : shapes)
        {
          Rectangle pRect = p.getBounds(); 
          if ( ! bnds.equals( pRect )  )
          {
            if (  p.contains( v.x, v.y ) )
            {
              drawShape( p, #F50FDA  ) ;
              Rectangle r = p.getBounds() ; 
              strokeWeight(5);
              rect( (float)r.getMinX(), -(float)r.getMinY(), (float)r.getWidth() , (float) -r.getHeight()); 
              
              println(p.getBounds(), gBoundingShapeBoundary.getBounds());
              fill( 255, 0, 0);
              break ;
            }
          }
        }// 

        circle( v.x, -v.y, 15 ) ;
   }
} 
boolean gDrawMode = false ;
boolean gDebugBoundary = false ; 
//--------------------------------------------------------------------------
void drawScaled()
{
  textSize(4);
  textAlign(CENTER, CENTER);
  if ( shapes == null || shapes.size()==0 )  testTriangle( ) ;

  stroke( 128); //# draw grey.
  //fill( #20B3D6 ) ;
  fill( 128);
  if ( shapes!=null)
  {
    strokeWeight(1);
    synchronized( shapes )
    {
      for ( GeneralPath p : shapes) drawShape(p, #737473 );
    }
    
    // these are in processing coordinates line(who.center.x , -who.center.y, center.x , -center.y);
    if ( gBoundingShapeBoundary == null )
    {
      textSize(32);
      text("NO BOUNDARY POLYGON FOUND", 0, 0) ;
    }else // gBoundingShapeBoundary has been found. 
    {
      if( true  ) 
      { 
       // stroke( 255, 127, 0);//# orange
        strokeWeight(3);
        if ( gBoundingShapeBoundary !=null) drawShape( gBoundingShapeBoundary, #20B3D6  ) ;
        stroke( #6DE51E ) ;
      }
    }// end else 
    
    debugBoundaryDuringDraw(); 
  }
  // these are offset from draw shapes
  if (isovists!=null)synchronized(isovists) // modifiled while locked.
  {
    for ( Isovist px : isovists )
    {
      if ( gDrawMode ) px.drawMedium();
      else   px.drawFast();
      // px.drawMedium();
      if ( gshowHIsovist )     px.drawSlow();
      // vertex( px.x , px.y ) ;
    }
  }
  if ( badIsovists.size()> 0)
  {
    //text( 0,0, "Dead "+ badIsovists ) ;
    for ( Isovist deadIso : badIsovists )
    {
      deadIso.drawDead();
    }
  }


  if ( gTestIntersections )
  {
    assert intersetTest2 != null ;
    assert intersetTest !=null;
    //print("test pverlap draw");
    intersetTest.debugtestPointInside(
      convertWindowToMapCoordX(mouseX),
      -convertWindowToMapCoordY(mouseY) );

    if (keyPressed && keyCode == SHIFT )
    {
      isovists.remove( intersetTest2);
      intersetTest2 = new Isovist( new PVector( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY) ) ) ;

      intersetTest2.initRays( 80);
      intersetTest2.makeOutlineFromRays();
      isovists.add( intersetTest2);

      /*intersetTest2.re_init_rays(     new PVector( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY)), 50);
       println("make random point");
       PVector p  = intersetTest2.makeRandomPointInside( ) ;
       println("point made", p);*/

      float p = intersetTest2.areaofOverlapWithOmni(intersetTest, 512, false);
    } else
    {
      intersetTest2.debugtestPointInside(
        convertWindowToMapCoordX(mouseX),
        -convertWindowToMapCoordY(mouseY) );
    }
    // println(p);
  }
  /*if(points!=null)
   {
   for( PVector p:points)
   {
   fill( #DBB104 ) ;
   circle( p.x , -p.y , 4);
   }
   }*/

  

  if (  gIntersect == true  )
  {
    println("TESTING.");
    processAllAreaIntersections(isovists) ;
    //gIntersect = ;
  }

  //OLD beginShape( POINTS ) ;

  /* if ( lastHitPoint != null )
   {
   fill(   #85E81C ) ;
   stroke( #85E81C ) ;
   circle( lastHitPoint.x, -lastHitPoint.y, 0.5 ) ;
   
   if ( gCheckRay1 != null )
   {
   strokeWeight( .1 ) ;
   line( gCheckRay1.x, -gCheckRay1.y, gCheckRay3.x, -gCheckRay3.y ) ;
   line( gCheckRay2.x, -gCheckRay2.y, gCheckRay3.x, -gCheckRay3.y ) ;
   line( gCheckRay2.x, -gCheckRay2.y, gCheckRay1.x, -gCheckRay1.y ) ;
   }
   }*/
  noStroke() ;
  if ( gCheckIntersectOther != null)
  {
    fill( 0, 127, 0);
    for ( PVector p : gCheckIntersectOther )
    {
      circle( p.x, -p.y, 0.75 ) ;
    }
  }
  if ( gCheckInersectionMe != null)
  {
    fill( #F7E40A ) ;// #mustard yellow
    for ( PVector p : gCheckInersectionMe )
    {
      circle( p.x, -p.y, 0.5 ) ;
    }
  }
  stroke( 255, 0, 0); // RED
  drawJGraph();

  if ( gClusters != null ) for ( Cluster x : gClusters) x.draw() ;
}
//-----------------------------------------------------
void drawShape(GeneralPath p, color col )
{
  if ( p==null) return ;
  noFill() ;
  stroke( col  ) ;
  PathIterator pi = p.getPathIterator(null);
  float[] pts = new float[2];
  boolean closed = false ;
  while (!pi.isDone())
  {
    int type = pi.currentSegment(pts);
    if (type == PathIterator.SEG_MOVETO)
    {
      beginShape();
      vertex(pts[0], -pts[1]);
    }
    if (type == PathIterator.SEG_LINETO)
    { // LINETO
      vertex(pts[0], -pts[1]);
      //println(pts[0]+","+pts[1]);
    }
    if (type == PathIterator.SEG_CLOSE)
    {
      endShape( CLOSE );
      closed = true ;
    }
    pi.next();
  }
  if ( !closed)  endShape( CLOSE );
}
//---------------------------------------------------------------------------
///https://annasob.wordpress.com/2010/07/20/adding-svg-support-to-processing-js/

void readSVGFile( String path )
{
  gMinx = Integer.MAX_VALUE ;
  gMinY = Integer.MAX_VALUE ;
  maxX = -Integer.MAX_VALUE ;
  maxY = -Integer.MAX_VALUE ;
  isLoading = true ;
  drawing = loadShape(path);
  drawing.disableStyle(); //setVisible(true);
  println(drawing, "READ SVG", drawing.width, drawing.height, drawing.getFamily());
  unique  = new HashSet<GeneralPath>( ) ;
  if (drawing!=null) processSVG( drawing, 10, unique ) ;
  unique = removeDuplicates( unique ) ; 
  shapes = new ArrayList<GeneralPath>( unique  ) ;

  gBoundingShapeBoundary =  findBoundingShape( shapes );
  //shapes.remove( gBoundingShapeBoundary) ; BAD BAD BAD ! 
  
  isLoading= false ;
}
//-----------------------------------------------
GeneralPath findBoundingShape(  java.util.List<GeneralPath>  shapes )
{
  println("LOOKING FOR SUPER OBJECT. #shapes = ", shapes.size() );
  int a = 1;
  int bestScore = 0, score = 0  ;
  GeneralPath bestShape = null ;
  for ( GeneralPath possibleSuperShape : shapes )
  {
    boolean passedAll = true ;
    int b = 0 ;
    score = 0 ;
    for ( GeneralPath p : shapes)
    {
      b++;
      if ( p != possibleSuperShape )
      {
        if ( isThisInThat( p, possibleSuperShape ) == false )
        {
          //println(a++,  p, " is not in " ,  b, possibleSuperShape ) ;
          passedAll = false ;
        } else score += 1 ;
      }
    }
    if (score >  bestScore ) {
      bestScore = score ;
      bestShape  = possibleSuperShape;
    }
    if ( passedAll == true )
    {
      println("FOUND SUPER OBJECT." , possibleSuperShape );
      bestShape = possibleSuperShape; 
      gBoundingShapeBoundary = possibleSuperShape;
      break ;
    }
  }
  
  
  println("chosen boundary shape" , gBoundingShapeBoundary , "score ", bestScore  ) ; 
  // println("BEST SCORE ", bestScore);
  return bestShape; 
}
//--------------------------------------------------
/*
   is any segement of the same shape THIS in the shape that
 */
boolean isThisInThat( GeneralPath  THIS, GeneralPath THAT )
{
  PathIterator pi = THIS.getPathIterator(null);
  float[] pts = new float[2];
  while (!pi.isDone()) // for ech of my coords
  {
    int type = pi.currentSegment(pts);
    // println(pts);
    if (type == PathIterator.SEG_MOVETO || type == PathIterator.SEG_LINETO )
    {
      if (  THAT.contains(pts[0], pts[1] ) == false )
      {
        return false ;
      }
    }
    pi.next();
  }
  return true ;
}
//-----------------------------------------------------------
/* 
  Some times an Item of the same size comes in. very bad if it is the boudning shapee.
*/ 
HashSet<GeneralPath>   removeDuplicates( HashSet<GeneralPath> unique ) 
{ 
  assert isLoading == true ; 
  
  HashSet<GeneralPath> pure = new HashSet<GeneralPath>( ) ; 
  
  for( GeneralPath it : unique ) 
  { 
    Rectangle2D itRect  = it.getBounds2D() ; 
    boolean isUniuqe = true ; 
    for( GeneralPath element: pure ) 
    { 
       Rectangle2D  elementRect = element.getBounds2D(); 
      if( elementRect.equals( itRect ) ) // item already exists. 
      { 
        isUniuqe = false ; 
        println("Duplicate found" ,itRect.getWidth() , elementRect.getWidth() , it, element  ); 
        break; 
      }else 
        { 
          // something going wrong. 
          //assert !(itRect.getWidth() == elementRect.getWidth() &&itRect.getHeight() == elementRect.getHeight()) :  
           //   "Duplicate found " + itRect.getWidth() + " " +  elementRect.getWidth() ; 
        } 
    }// next element 
    if( isUniuqe ) 
    { 
      pure.add( it) ; 
    } 
  } 
  println ("Original size = " , unique.size(), " reduced = " , pure.size()); 
  return pure; 
} 
//-----------------------------------------------------------
void processSVG( PShape shape, int depth , HashSet<GeneralPath> unique  )
{
  assert unique!= null ; 
  
  depth = depth+1 ;
  if ( depth > 100 ) return  ;
  println(shape, " PROCESS SVG ", shape.width, shape.height, "<", shape.getFamily(), ">", shape.getChildCount(), shape.getName());

  int count = shape.getChildCount();
  println("Shape Family ", shape.getFamily(), "Priv=", PShape.PRIMITIVE, PShape.PATH,
    PShape.GROUP, PShape.GEOMETRY, shape.is2D() ) ;
  if (  shape.getFamily() ==  PShape.PRIMITIVE )
  {
    println("Primative - Which I cannot/do not read. ");
  } else  if ( shape.getFamily() == PShape.PATH || shape.getFamily() ==  PShape.GEOMETRY )
  {
    println("VERTX COUNT ", shape.getVertexCount() );
    GeneralPath currentShape = new  GeneralPath();
    for ( int k =0; k < shape.getVertexCount(); k++ )
    {
      PVector v = shape.getVertex(k);
      v.y = -v.y ;

      gMinx = Math.min( gMinx, v.x ) ;
      gMinY = Math.min( gMinY, v.y ) ;
      maxX = Math.max( maxX, v.x ) ;
      maxY = Math.max( maxY, v.y  );

      if ( k == 0 )
      {
        currentShape.moveTo((float) v.x, (float) v.y);
      } else
      {
        currentShape.lineTo((float) v.x, (float) v.y);
      }
      //println("PNT ", k, v.x, v.y );
    }
    currentShape.closePath() ;
    println(currentShape.hashCode()) ;
    unique.add( currentShape ) ;
  }
  // not need for else
  for ( int a = 0; a < count; a++ )
  {
    println("Child");
    PShape child = shape.getChild( a ) ;
    if ( child != null )
    {
      processSVG( child, depth , unique );
    }
  }
}
//-----------------------------------------------------------
void mouseReleased()
{
  if ( keyCode == CONTROL )
  {
    println( "Control KETY", mouseX, mouseY, convertWindowToMapCoordX(mouseX), convertWindowToMapCoordX(mouseY) ) ;
    gshowHIsovist = true ; // so can see result.  Use can switch off.

    Isovist v = new Isovist( new PVector( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY) )) ;
    v.computIsovist(shapes ) ;
    isovists.add( v ) ;
    if ( isovists.size()>= 2)
    {
      Isovist other = isovists.get(  isovists.size()-2 ) ;
      float f  = other.areaofOverlapWith(v);
      println("Fraction ", f, keyCode == SHIFT, keyCode ) ;
    }
    return ;
  }
  if ( keyCode == ALT )
  {
    if (isovists==null ||  isovists.size() < 2) return ;

    Isovist t = isovists.get(isovists.size()-1 ) ; // get last
    boolean inside = t.isPointInsideIsovist( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY)  ) ;
    if ( inside ) println("HIT");
    else println("MISS");
    return ;
    //lastHitPoint = new  PVector( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY) );
    //fill( #D6E81C ) ;
    // circle( convertWindowToMapCoordX(mouseX), -convertWindowToMapCoordY(mouseY) , 5) ;
  }


  if ( isovists.size()> 0 ) selectClosestIsovist() ;
}

//---------------------------------------------------------------------------
Set<Isovist> selectedIsovists = new HashSet<Isovist>( ) ;
int gSelectedItem = -1 ;

void selectClosestIsovist()
{
  println("Find closest spot.");
  for ( Isovist it : selectedIsovists ) {
    it.selected = false ;
  }
  selectedIsovists.clear();
  float h = convertWindowToMapCoordX(mouseX);
  float v =  -convertWindowToMapCoordY(mouseY);
  float distance = Float.MAX_VALUE;
  Isovist best = null ;
  int counter = 0 ;
  gSelectedItem = -1 ;

  for ( Isovist it : isovists )
  {
    if ( dist( h, v, it.center.x, it.center.y ) < distance )
    {
      distance = dist( h, v, it.center.x, it.center.y );
      best = it ;
      gSelectedItem = counter;
      //println(  h,v , it.center.x , it.center.y, distance ) ;
    }
    counter++ ;
  }
  if ( best !=null )
  {
    best.selected = true ;
    selectedIsovists.add( best ) ;
    println(  "Fractional Depth, Intergration depth, con,Fractionalcon") ;
    println(best.getFractionalDepth(), ",", best.getIntergrationDepth(), ",",
      -best.getValue( ePureConnectivity, 0 ), ",",
      best.getValue(kFRACTIONAL_CONNECTIVITY, 0), best.myCurrentValue);

    String formattedString =   String.format("%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f",
      -best.getValue( ePureConnectivity, 0  ),
      -best.getValue( kFRACTIONAL_CONNECTIVITY, 0  ),
      -best.getValue( kSYMETRIC_CONNETIVITY, 0  ),

      best.getValue( eTOTAL_DEPTH_MEASURE, 0  ),
      best.getValue( kTOTAL_FRACITON_INTEGRATION, 0  ),
      best.getValue( kSYMETRIC_TOTAL_DEPTH, 0  ),

      best.getValue( eDEPTH, 0 ),
      best.getValue( kDEPTH_FRACION, 0 ),
      best.getValue( kSYMETIC_STEP_DEPTH, 0 )
      ) ;

    copyStringToClip(formattedString);
  }
}
/*
103.000000  32.227539  48.413086  1587.000000  542.135742  946.142090  3.000000  1.398438  1.722656
 */
//-----------------------------------------------------------
void copyStringToClip( String textToCopy )
{
  // Get the system clipboard
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

  // Create a StringSelection object with the text to be copied
  StringSelection selection = new StringSelection(textToCopy);

  // Set the contents of the clipboard to the StringSelection object
  clipboard.setContents(selection, null);
}
//-----------------------------------------------------------
void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  //String message;

  int notches = (int)e;
  if (notches < 0)
  {
    zoomIn( mouseX, mouseY ) ;
    // scaleFactor *= 1.01;
    // message = "Mouse wheel moved UP "   + -notches + " notch";
  } else if (notches > 0)
  {
    // scaleFactor *= 1.0/ 1.01;
    zoomOut( mouseX, mouseY ) ;
    // message = "Mouse wheel moved DOWN "   + notches + " notch";
  }
  // println(message);
}
//-----------------------------------------------------------
public void zoomIn( int x, int y )
{
  double mapX, mapY ;

  mapX =  (x- fOffSetX)/fZoomFactor ;
  mapY =  (y- fOffSetY)/fZoomFactor ;

  double newscale  = fZoomFactor*fIncrement ;
  if ( newscale >= fMaxZoom)
  {
    maxZoomReached() ;
    return ;
  } //
  double newOffX =  ((mapX *fZoomFactor)+fOffSetX)- (mapX *newscale);
  double newOffY =  ((mapY *fZoomFactor)+fOffSetY)- (mapY *newscale);
  fOffSetX = newOffX;
  fOffSetY = newOffY   ;
  fZoomFactor = newscale ;
}
//---------------------------------------------------------------------
void mouseDragged()
{
  fOffSetX +=  mouseX - pmouseX;
  fOffSetY +=   mouseY - pmouseY;
}
//---------------------------------------------------------------------
public void minZoomReached()
{
  // Toolkit.getDefaultToolkit().beep();
}
//---------------------------------------------------------------------
public void maxZoomReached()
{
  // Toolkit.getDefaultToolkit().beep();
}
//---------------------------------------------------------------------
public void zoomOut(int x, int y )
{
  double mapX, mapY ;
  mapX =  (x- fOffSetX)/fZoomFactor ;
  mapY =  (y- fOffSetY)/fZoomFactor ;

  double newscale  = fZoomFactor/fIncrement ;
  if (newscale <= fMinZoom) {
    minZoomReached();
    return ;
  }
  double newOffX =  ((mapX *fZoomFactor)+fOffSetX)- (mapX *newscale);
  double newOffY =  ((mapY *fZoomFactor)+fOffSetY)- (mapY *newscale);
  fOffSetX = newOffX;
  fOffSetY = newOffY   ;
  fZoomFactor = newscale ;
}
//---------------------------------------------------------------------
public float convertWindowToMapCoordX( int x )
{
  return (float) ((x -  fOffSetX)/fZoomFactor) ;
}
//---------------------------------------------------------------------
public float convertWindowToMapCoordY( int y )
{
  return (float)((y -  fOffSetY)/fZoomFactor );
}
//---------------------------------------------------------------------
public float convertMapCoordToWindowX( float xmap )
{
  return (float)((xmap *fZoomFactor)+fOffSetX);
}
//---------------------------------------------------------------------
public float convertMapCoordToWindowY( float ymap )
{
  return (float)((ymap *fZoomFactor)+fOffSetY);
}
