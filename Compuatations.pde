 //<>//

void doCluster()
{
  float smallest = Float.MAX_VALUE  ;
  Isovist bestFrom = null, bestToo = null ;
  for ( Isovist it : isovists )
  {
    float myVal = it.getValue( kTOTAL_FRACITON_INTEGRATION, 0 ) ;
    Isovist other = it.findMostSimilarToYou() ;
    assert other !=null ;

    if ( other == it) continue ; // skip self

    float otherVal = other.getValue( kTOTAL_FRACITON_INTEGRATION, 0 ) ;

    float d = sq( otherVal - myVal );

    if ( d < smallest )  // find something I'm connected to which is small
    {
      smallest = d;
      bestToo = other ;
      bestFrom = it ;
    } else if ( d == smallest )
    {
      PVector me = it.getCenter();
      float smallestP = bestFrom.getCenter().dist( bestToo.getCenter());
      ;
      PVector otherP = other.getCenter();
      if ( me.dist( otherP ) <  smallestP  )
      {
        println("found closer." );
        smallest = d;
        bestToo = other ;
        bestFrom = it ;
      }
    }
  }
  println("Min ", smallest, bestFrom, bestToo ) ;
  // Make isovst pair remove the others. add new parent one.
}
//-----------------------------------------------------------------------
/*
 Access gobal variable shapes
 */
public boolean rayBlockedByBuilding(   PVector start, PVector end )
{
  for ( GeneralPath p : shapes)
  {
    PathIterator pi = p.getPathIterator(null);
    float[] pts = new float[2];
    double[] where = new double[2];
    PVector last = new PVector();
    PVector first = new PVector();

    while (!pi.isDone())
    {
      int type = pi.currentSegment(pts);
      if (type == PathIterator.SEG_MOVETO)
      {
        last.x =  pts[0];
        last.y =  pts[1];
        first = last.copy();
      }
      if (type == PathIterator.SEG_CLOSE)
      {
        pts[0] = first.x ;
        pts[1] = first.y ;
        type = PathIterator.SEG_LINETO;//  WE CLOSE SHAPES...
      }
      if (type == PathIterator.SEG_LINETO)
      {

        if ( Line2D.linesIntersect( last.x, last.y, pts[0], pts[1], start.x, start.y, end.x, end.y ))
        {
          // findLineSegmentIntersection( last.x,last.y, pts[0], pts[1], start.x,start.y, end.x, end.y, where);
          // r.x = (float)where[0];
          // r.y = (float)where[1] ;
          return true ;
        }

        last.x =  pts[0];
        last.y =  pts[1];
      }

      pi.next();
    }
  }
  // println("*************"  + shapes.size());
  return false ;
}

/*
    processAllAreaIntersections
    
    could run ths in a pararlle stream ? 
 */
void processAllAreaIntersections(final List<Isovist> isovists)
{
  Set<Isovist> deadlist = new HashSet<Isovist>( isovists ) ;
  println("1.");
  synchronized( isovists) {
    for ( Isovist from : isovists ) from.reset();
  }
  println("2.");
  synchronized( isovists )
  {
    // could avoid the double loop would speed up by 2.
    int fromIndex = 0 ;
    for (  Isovist from : isovists ) // test each isovist against every other isovists
    {
      synchronized( from )
      {
        from.myColor = #BC09B1 ;
        int otherIndex = 0 ;
        assert from.validMinMax()==true;

        for ( Isovist other : isovists )
        {
          synchronized( isovists)
          { 
            assert other.validMinMax()==true;
            if ( from == other ) continue ;

            //SLOWER BETTER
            if ( other.isPointInsideIsovist(from.center.x, from.center.y) == false ) continue ;
            //MORE ACCURATE  if ( rayBlockedByBuilding( from.center, other.center ) == true ) continue ;
//  1. normal 
            assert other.validMinMax()==true;
            from.connect( other ) ; // normal connection add.
 // 2. frational - asymetical  
             assert other.validMinMax()==true;
             assert from.validMinMax()==true;
            float fraction = other.areaofOverlapWith(from) ; // default item of connection
            if( fraction == 0.0f ) fraction = 0.0001f; //Cap  
            if ( fraction > 0.f )
            {
              //println(from, other, fraction ) ;
              assert fraction > 0;
              assert fraction <= 1.0f :"f=" + fraction;
              
              from.connect( other, 1.0f- fraction  ) ;// could be wrong.
              deadlist.remove( from );
            } else
            { 
              println(fromIndex, "faction unconnected", fraction ) ;
              assert false : "Should not happen or need to redo. f" + fraction ;
            }
 // 3. symetical         
            float omniFraction = other.areaofOverlapWithOmni(from, K1024 , kNoDebugIsovistIntersection ) ;
            if( omniFraction == 0.0f ) omniFraction = 0.0001 ; // min cap 
            if( omniFraction > 0.f ) 
            { 
              assert omniFraction > 0;
              assert omniFraction <= 1.0f :"f=" + omniFraction;
              float weight =  1.0f - omniFraction ; 
              if(other.omniDirectionToWeightedEdges.containsKey(from))
              { 
                 float otherWeight =  other.omniDirectionToWeightedEdges.get(from); 
                 //println("Merage " , otherWeight , weight, lerp( weight , otherWeight, 0.5));
                 weight = lerp( weight , otherWeight, 0.5); 
                 other.connectOmniDiretional(from, weight);
              }
              from.connectOmniDiretional( other,weight  ) ;// could be wrong.
              deadlist.remove( from );
            } else
            { 
               println(fromIndex, "faction unconnected", omniFraction ) ;
            } 
            
           // To test - make simple shape put in small number of isovists and draw them.
           // this is the section to approach next... need to do
          }
          Thread.yield();
        }
      }
      fromIndex += 1;
      println("@", fromIndex,isovists.size()  );
    }// End sync.
  }
  println("3. find dead ");
  println("DEAD LIST SIZE " + deadlist.size());
  for ( Isovist it : deadlist )
  {
    assert it.connectedToWeighted.size() == 0 ;
  }
  println("4. remove dead ");
  synchronized( isovists)
  {
    isovists.removeAll( deadlist ) ;
  }
  println("5.( processAllAreaIntersections done)");
}

/*
 SO AFTER CHECKING THE quantisation of the 1 degree rays is not as
 perfect as the do the center points intersect test.
 but the is in isovist is a lot faster.
 boolean  o = other.isPointInsideIsovist( from.center.x, from.center.y );
 boolean  f  = from.isPointInsideIsovist( other.center.x, other.center.y );
 boolean  ox = other.isPointInOutline(from.center.x, from.center.y);
 boolean  fx = from.isPointInOutline(other.center.x, other.center.y );
 boolean  blocked = rayBlockedByBuilding( from.center, other.center );
 
 if(   o != f  ) // might not be true do to quantisation of edges
 {
 stroke( 0,0,255); // blue
 line( from.center.x, from.center.y , other.center.x, other.center.y ) ;
 println(" point inside incorrect "  + o +  " f = " + f ) ;
 }
 if( ox != fx )
 {
 stroke( 0,255,0); // green
 line( from.center.x, from.center.y , other.center.x, other.center.y ) ;
 println( " point inside 2 incorrect ix "  + ox + " f = " + fx ) ;
 }
 */
/*
          if(  o == blocked )
 {
 println( "o = " + o + " o.outl "+ ox +
 " f  = " + f +  " f.outl " + fx + " krc = " + blocked) ;
 stroke( 0,0,0,255);
 strokeWeight(4.0);
 from.selected = true ; other.selected = true ;
 //println(from.center,other.center, " dist ", from.center.dist(other.center));
 
 line( from.center.x, from.center.y , other.center.x, other.center.y ) ;
 from.myColor = #DE16ED ;
 other.myColor = #16E8ED ;
 stroke( 255,0,255);
 strokeWeight(1.0);
 
 from.drawFast(); other.drawFast();
 //frameRate(0);
 return;
 }
 // this line not working.
 if( other.isPointInOutline(from.center.x, from.center.y) == false ) continue ;
 */


//----------------------------------------------

boolean gFixedRange = false ;
float gMinRangeValue = 0.0  ;
float gMaxRangeValue = 0.0  ;
String gMessage = "Not set"; 

void colourBy( int which  )
{ 
   colourBy( which ,"unknown_"+which); 
} 

void colourBy( int which , String mesure  )
{
  assert  mesure != null ; 
  
  gMessage= mesure; 
  float min =  Float.MAX_VALUE;
  float max = -Float.MAX_VALUE;
  colorMode( HSB, 255, 255, 255 ) ;
  if ( gFixedRange == false )
  {
    // Determin range
    synchronized( isovists )
    {
      for (  Isovist startingPoint : isovists )
      {
        assert startingPoint != null ;
        float val = startingPoint.getValue(which, isovists.size() );
        if ( Float.isInfinite(val) || Float.isNaN(val)) continue ;

        min = min( min, val );
        max = max(max, val );
        //println(startingPoint.getValue(which));
        gMinRangeValue = min;
        gMaxRangeValue = max ;
      }
    }

    //println("Dynamic ", min, " max ", max ," current value ", which ) ;
    if ( (max - min)<= 0 )  println("mode = "+ which, " RANGE ", min, max, max - min, " which ", which ) ;
  } else // Range is fixed.
  {
    min =  gMinRangeValue;
    max = gMaxRangeValue;
    // println("Fixed min", min, " max ", max ," current value ", which ) ;
  }
  println( mesure , " RANGE min", min, "max", max, "RANGE", max - min );

  double totalVal = 0 ;
  int    count = 0 ;
  synchronized( isovists )
  {
    for ( Isovist startingPoint : isovists )
    {
      float val = startingPoint.getValue(which, isovists.size()) ;
      startingPoint.myCurrentValue  = val ;
      if ( Float.isInfinite(val) || Float.isNaN(val))
      {
        startingPoint.myColor = color(#D007F0 ) ;// error color
        continue ;
      }

      totalVal += startingPoint.myCurrentValue;
      count++ ;
      startingPoint.myColor = color( map( startingPoint.myCurrentValue, min, max, 0, 161), 230, 230);
      //....println( startingPoint.hashCode());
    }
    Collections.sort(isovists, new Comparator<Isovist>() {
      @Override
        public int compare(Isovist o1, Isovist o2) {
        float val =  o1.getValue(which, isovists.size() );
        float val2 = o2.getValue(which, isovists.size() );

        return -Float.compare(val, val2 );
      }
    }
    );
  }
  if ( count>0)gCurrentValueAverage = (float)(totalVal/(float)count) ;
  colorMode( RGB, 255, 255, 255 ) ;
}
float gCurrentValueAverage = 0 ;

//----------------------------
void  colourEvenlyBy( int which )
{
  println("Color Evenly by " + which );
  gMessage = "Even distrubtion " + gMessage; 
  
  colorMode( HSB, 255, 255, 255 ) ;
  synchronized( isovists )
  {
    double totalVal = 0 ;
    int    count = 0 ;
    int    max   = isovists.size();
    Collections.sort(isovists, new Comparator<Isovist>() {
      @Override
        public int compare(Isovist o1, Isovist o2) {
        float val =  o1.getValue(which, isovists.size() );
        float val2 = o2.getValue(which, isovists.size() );

        return -Float.compare(val, val2 );
      }
    }
    );

    int index = 0 ;
    for ( Isovist it : isovists )
    {
      float val = it.getValue(which, isovists.size()) ;
      it.myCurrentValue  = val ;
      if ( Float.isInfinite(val) || Float.isNaN(val))
      {
        it.myColor = color(#D007F0 ) ;// error color
        continue ;
      }
      index += 1 ;
      totalVal += it.myCurrentValue;
      count++ ;
      it.myColor = color( map( index, 0, max, 161, 0), 230, 230);
      println( index, max, it.myColor ) ;
    }// end of for loop.

    if ( count>0)gCurrentValueAverage = (float)(totalVal/(float)count) ;
  }

  colorMode( RGB, 255, 255, 255 ) ;
}

//----------------------------
/* 
This is the asymetical  Jacobean  AR(A U B) / AR(A)
  this.connectedToWeighted.get(it);

*/ 


//---------------------------------------------------------------



//---------------------------------------------------------------
float  computeStepDepthFrom(  Isovist startingPoint, List<Isovist> deadIsovists )
{
  final int MAXDEPTH  = 400 ;
  for (  Isovist it : isovists ) it.depth = MAXDEPTH ;

  Set<Isovist> fire = new HashSet<Isovist>();
  Set<Isovist> fireEdge = new HashSet<Isovist>();
  fire.add( startingPoint ) ;
  startingPoint.depth = 0 ;
  for ( int i = 0; i < 4000; i++ )
  {
    // print( i , fire.size());
    for ( Isovist it : fire )
    {
      for ( Isovist to : it.connections )
      {
        if ( to.depth  > it.depth + 1 )
        {
          fireEdge.add(to);
          to.depth  = it.depth + 1;
        }
      }
    }

    // println( ",", fireEdge.size());
    if ( fireEdge.size()<= 0 ) break;
    fire = fireEdge;
    fireEdge = new HashSet<Isovist>();
  }
  int totaltDepth = 0;
  int isolated = 0 ;
  double daltonFractionalDepth = 0.0;
  for (  Isovist it : isovists )
  {
    if (it.depth < MAXDEPTH  )
    {
      totaltDepth +=  it.depth  ;
      if ( it.depth != 0 )   daltonFractionalDepth  += pow(it.depth, -2.5 ) ;
      // println(  it.depth , pow(it.depth , -1.2 )) ;
    } else
    {
      isolated++ ;
    }
  }
  if ( isolated > isovists.size()/2)
  {
    deadIsovists.add( startingPoint ) ;
  }
  startingPoint.totalDepth = totaltDepth;
  startingPoint.setDaltonGradient( daltonFractionalDepth );
  //  println( startingPoint.computeClusterCoeifAssumDepthComputed() ) ;
  return  startingPoint.computeClusterCoeifAssumDepthComputed() ;
  //println(daltonFractionalDepth );
  // println( startingPoint.totalDepth);
}
//---------------------------------------------------------------
void generateStocasticIsovist( java.util.List<GeneralPath> buidlings, int size )
{
  if( buidlings == null || buidlings.size()==0 ) return ; // nothign to process. 
  assert size> 0 ;
  assert  gMinx <= maxX: " the area to process is not big enough. " + gMinx + " " + maxX ;
  this.rays  = new ArrayList<PVector>(); // resets. 
  for ( int i  = 0; i < K360; i++) rays.add( PVector.random2D());

  if (size==1)println("generateStocasticIsovist::Start", gMinx, maxX, gMinY, maxY, gBoundingShapeBoundary );
  addStocasticIsovist( buidlings, size ) ;
}
//-------------------------------------------------------------------------
PVector generateRandomIsovistCenter( java.util.List<GeneralPath> buidlings,  int MAXTRIES ) 
{ 
    PVector v = PVector.random2D(); //try again ..
    
    int limitGoRound = 0 ;
      do
      { // pick a point in spave
        v.x = random( (float)gMinx, (float)maxX ) ;
        v.y = random( (float)gMinY, (float)maxY ) ;
        if( limitGoRound++> MAXTRIES) 
        { 
          println( "Could not find point. Problems with boundry? try=" 
                     + limitGoRound  + " last point {" + gMinx + " < " + maxX + "}, {"  + gMinY + " " + maxY + " } " + v.x + "," +v.y );
          return null ;
        }
      }
      while ( pointIsValid(v, buidlings)== false  );// dont fall in a building.
     return v;  
} 
//-------------------------------------------------------------------------
void addStocasticIsovist( java.util.List<GeneralPath> buidlings, int size  )
{
  println("addStocasticIsovist--");
  int i = 0 ;
  PVector v  = new PVector( 492.0, 467.0 ) ;
  int  sec = second();
  do
  {
    float  maxDistance = - (Float.MAX_VALUE-1 )  ;
    PVector best = null ;
    for ( int a = 0; a < size; a++ ) // make 40 points find furtherst
    {
      v= generateRandomIsovistCenter(  buidlings,  1000 );  
      float d = distanceToNearst( v, isovists ) ;
      //println( d, maxDistance);
      if (  d > maxDistance  )
      {
        maxDistance = d ;
        best = v;
      }
    }
    //println( "BEST", best, maxDistance," i = ", i  ) ;
    v = best ;
    assert best !=null : "impossible 9933";

    points.add(  v ) ;
    Isovist iso = new Isovist( v ) ;
    iso.computIsovist(shapes ) ;
    synchronized( isovists ) {
      isovists.add( iso) ;
    }

    if ( second() != sec )
    {
      println("*" + isovists.size());
      sec = second() ;
    }

    i++ ;
  }
  while (i < size);
}

//---------------------------------------------------------------
static java.util.List<PVector> pointIsValidRays  = new ArrayList<PVector>();

boolean pointIsValid(PVector v, java.util.List<GeneralPath> buidlings )
{
  if ( pointIsValidRays.size()!=K360)  // Cache
  {
    pointIsValidRays.clear();
    for ( int i  = 0; i < K360; i++)
    {
      pointIsValidRays.add( PVector.random2D());
    }
    println("----created rays chache---");
  }
  if ( gBoundingShapeBoundary!=null &&   gBoundingShapeBoundary.contains(  v.x, v.y ) == false ) return false ;
  
  synchronized( shapes )
  {
    for ( GeneralPath p : shapes)
    {
      if ( gBoundingShapeBoundary == p ) continue ;
      if (  p.contains( v.x, v.y ) ) return false ;//should be fast.
    }
  }

  if ( gBoundingShapeBoundary == null  ) // CURRENTRLY unreachable. 
    //  "Null bounday - need to do the test for infinti test ";
    //  if this fais go up
    /*  DON'T CHANGE THIS CODE- EXPERIMENT 1 - IS NESSASRY for 2000 */
  {
    // is this nessasry ...
    //    if(size==1) println("Found", v.x,v.y,gBoundingShapeBoundary  );
    generateRayForCenter( pointIsValidRays, v ) ;
    synchronized( shapes )
    {
      for ( GeneralPath p : shapes)  trimRaysToShape( pointIsValidRays, p, v);
    }
    if ( testRaysForIninity( pointIsValidRays, v) == false )
    {
      println("testRaysForIninity pre-screen failed", millis() );

      //assert false :" test rays for infinity failed.";
      return false ;
    }
  }
  return true;
}
//670.333
//----------------------------------------------------------------
float distanceToNearst( PVector v, java.util.List<Isovist>  isovists )
{
  assert v!=null ;
  float minDistance =  Float.MAX_VALUE-1;
  for ( Isovist iso : isovists )
  {
    float d = PVector.dist(v, iso.center );
    if ( d < minDistance ) minDistance = d ;
  }
  return minDistance ;
}
final int K360 = 360; 
//-----------------------------------------------------------------------
void generateRayForCenter( java.util.List<PVector> rays, PVector center, float radius )
{
  assert rays.size() == K360;
  int i = 0 ;
  for ( PVector p : rays )
  {
    p.x = center.x + (radius * cos( map( i, 0, K360, 0, PI*2) )) ;
    p.y = center.y + (radius * sin( map( i, 0, K360, 0, PI*2) )) ;
    i+=1 ;       
  }
  assert i == K360; 
}
void generateRayForCenter( java.util.List<PVector> rays, PVector center )
{ 
  this.generateRayForCenter(rays, center , myInfinity ) ;
} 
//-----------------------------------------------------------
void trimRaysToShape( java.util.List<PVector> rays, GeneralPath   p, PVector center )
{
  PathIterator pi = p.getPathIterator(null);
  float[] pts = new float[2];
  double[] where = new double[2];
  PVector last = new PVector();
  PVector first = new PVector();
  
  while (!pi.isDone())
  {
    int type = pi.currentSegment(pts);
    if (type == PathIterator.SEG_MOVETO)
    {
      last.x =  pts[0];
      last.y =  pts[1];
      first = last.copy();
    }
    if (type == PathIterator.SEG_CLOSE)
    {
      pts[0] = first.x ;
      pts[1] = first.y ;
      type = PathIterator.SEG_LINETO;//
    }
    if (type == PathIterator.SEG_LINETO)
    {
      for ( PVector r : rays ) // could do this in parralle.
      {
        if ( Line2D.linesIntersect(last.x, last.y, pts[0], pts[1], center.x, center.y, r.x, r.y  ))
        {
          findLineSegmentIntersection( last.x, last.y, pts[0], pts[1], center.x, center.y, r.x, r.y, where);

          r.x = (float)where[0];
          r.y = (float)where[1] ;
        }
      }
      last.x =  pts[0];
      last.y =  pts[1];
    }
    pi.next();
  }
}
//-------------------------------------------------
/* 
   this could work in parralell. 
*/ 
boolean trimRaysToLine( float lastX, float lastY, float pts0,float  pts1,
  java.util.List<PVector> rays, final PVector center)
{
  boolean trimed  = false ;
  double[] where = new double[2];
  
  for ( PVector r : rays ) // could do this in parralle.
  {
    if ( Line2D.linesIntersect(lastX, lastY, pts0, pts1, center.x, center.y, r.x, r.y  ))
    {
      findLineSegmentIntersection( lastX, lastY, pts0, pts1, center.x, center.y, r.x, r.y, where);

      r.x = (float)where[0];
      r.y = (float)where[1] ;
      trimed = true;
    }
  }
  return trimed ;
}
//-----------------------------------------------------------------------
boolean testRaysForIninity( java.util.List<PVector> rays, PVector center )
{
  assert rays.size() == K360;
  int i = 0 ;
  for ( PVector p : rays )
  {
    if (  p.dist( center )> (myInfinity/2)) return false ;
  }
  return true ;
}
//-----------------------------------------------------------------------

private static boolean geom_equals (double a, double b, double limit)
{
  return Math.abs (a - b) < limit;
}
/**
 * Check if two double precision numbers are "equal", i.e. close enough
 * to a prespecified limit.
 *
 * @param a  First number to check
 * @param b  Second number to check
 * @return   True if the twho numbers are "equal", false otherwise
 */
private static boolean geom_equals (double a, double b)
{
  return geom_equals (a, b, 1.0e-5);
}
/**
 * Return smallest of four numbers.
 *
 * @param a  First number to find smallest among.
 * @param b  Second number to find smallest among.
 * @param c  Third number to find smallest among.
 * @param d  Fourth number to find smallest among.
 * @return   Smallest of a, b, c and d.
 */
private static double geom_min (double a, double b, double c, double d)
{
  return Math.min (Math.min (a, b), Math.min (c, d));
}

/**
 * Return largest of four numbers.
 *
 * @param a  First number to find largest among.
 * @param b  Second number to find largest among.
 * @param c  Third number to find largest among.
 * @param d  Fourth number to find largest among.
 * @return   Largest of a, b, c and d.
 */
private static double geom_max (double a, double b, double c, double d)
{
  return Math.max (Math.max (a, b), Math.max (c, d));
}


public static void findLineSegmentIntersection (double x0, double y0,
  double x1, double y1,
  double x2, double y2,
  double x3, double y3,
  double[] intersection)
{
  // TODO: Make limit depend on input domain
  final double LIMIT    = 1e-5;
  final double INFINITY = 1e10;
  double x, y;

  //
  // Convert the lines to the form y = ax + b
  //

  // Slope of the two lines
  double a0 = geom_equals (x0, x1, LIMIT) ?
    INFINITY : (y0 - y1) / (x0 - x1);
  double a1 = geom_equals (x2, x3, LIMIT) ?
    INFINITY : (y2 - y3) / (x2 - x3);

  double b0 = y0 - a0 * x0;
  double b1 = y2 - a1 * x2;

  // Check if lines are parallel
  if (geom_equals(a0, a1)) {
    if (!geom_equals (b0, b1))
      return ; // Parallell non-overlapping

    else {
      if (geom_equals (x0, x1)) {
        if (Math.min (y0, y1) < Math.max (y2, y3) ||
          Math.max (y0, y1) > Math.min (y2, y3)) {
          double twoMiddle = y0 + y1 + y2 + y3 -
            geom_min (y0, y1, y2, y3) -
            geom_max (y0, y1, y2, y3);
          y = (twoMiddle) / 2.0;
          x = (y - b0) / a0;
        } else return ;  // Parallell non-overlapping
      } else {
        if (Math.min (x0, x1) < Math.max (x2, x3) ||
          Math.max (x0, x1) > Math.min (x2, x3)) {
          double twoMiddle = x0 + x1 + x2 + x3 -
            geom_min (x0, x1, x2, x3) -
            geom_max (x0, x1, x2, x3);
          x = (twoMiddle) / 2.0;
          y = a0 * x + b0;
        } else return ;
      }

      intersection[0] = x;
      intersection[1] = y;
      return ;
    }
  }

  // Find correct intersection point
  if (geom_equals (a0, INFINITY))
  {
    x = x0;
    y = a1 * x + b1;
  } else if (geom_equals (a1, INFINITY))
  {
    x = x2;
    y = a0 * x + b0;
  } else
  {
    x = - (b0 - b1) / (a0 - a1);
    y = a0 * x + b0;
  }

  intersection[0] = x;
  intersection[1] = y;
}
