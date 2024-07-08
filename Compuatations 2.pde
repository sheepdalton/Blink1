
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
*/
void processAllAreaIntersections(final List<Isovist> isovists) 
{ 
   Set<Isovist> deadlist = new HashSet<Isovist>( isovists ) ; 
   println("1.");
   synchronized( isovists) {  for( Isovist from: isovists ) from.reset();}  
   println("2.");
   synchronized( isovists ) 
   { 
   // could avoid the double loop would speed up by 2. 
   int fromIndex = 0 ; 
   for(  Isovist from: isovists ) // test each isovist against every other isovists 
   { 
     synchronized( from )
     { 
      from.myColor = #BC09B1 ;
      int otherIndex = 0 ;
      
      for( Isovist other: isovists ) 
      { 
        synchronized( isovists) 
        { 
          if( from == other ) continue ; 
           
         //SLOWER BETTER //<>//
         if( other.isPointInsideIsovist(from.center.x, from.center.y) == false ) continue ;
         //MORE ACCURATE  if ( rayBlockedByBuilding( from.center, other.center ) == true ) continue ; 
         
          from.connect( other ) ; // normal connection add. 
          float fraction = other.areaofOverlapWith(from) ; // default item of connection 
          
          // frational 
          if( fraction > 0.f ) 
          { 
            //println(from, other, fraction ) ; 
             assert fraction > 0; 
             assert fraction <= 1.0f : "f=" + fraction; 
            from.connect( other, 1.0f- fraction  ) ;// could be wrong.
            deadlist.remove( from ); 
          } else println(fromIndex, "faction unconnected", fraction ) ; 
        }
         Thread.yield();
     }

    } 
     fromIndex += 1; println("@",fromIndex); 
   }// End sync. 
    
   } 
   println("3.");
   println("DEAD LIST SIZE " + deadlist.size()); 
   for( Isovist it: deadlist ) 
   { 
     assert it.connectedToWeighted.size() == 0 ; 
   } 
   println("4.");
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
float gMinRangeValue = 0.0 ;
float gMaxRangeValue = 0.0;

void colourBy( int which )
{
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
        if( Float.isInfinite(val) || Float.isNaN(val)) continue ; 
        
        min = min( min, val );
        max = max(max,  val );
        //println(startingPoint.getValue(which));
        gMinRangeValue = min;
        gMaxRangeValue = max ;
      }
    }

    //println("Dynamic ", min, " max ", max ," current value ", which ) ;
    if ( (max - min)<= 0 )  println("mode = "+ which , " RANGE ", min, max, max - min, " which ", which ) ;
  } else // Range is fixed.
  {
    min =  gMinRangeValue;
    max = gMaxRangeValue;
    // println("Fixed min", min, " max ", max ," current value ", which ) ;
  }
  println("RANGE min", min, "max", max, "RANGE", max - min );
  
  double totalVal = 0 ; 
  int    count = 0 ; 
  synchronized( isovists ) 
  { 
    for ( Isovist startingPoint : isovists )
    {
       float val = startingPoint.getValue(which, isovists.size()) ; 
       startingPoint.myCurrentValue  = val ;
       if( Float.isInfinite(val) || Float.isNaN(val)) 
       { 
          startingPoint.myColor = color(#D007F0 ) ;// error color
          continue ; 
       } 
      
      totalVal += startingPoint.myCurrentValue; count++ ; 
      startingPoint.myColor = color( map( startingPoint.myCurrentValue  , min, max, 0, 161), 230, 230);
      //....println( startingPoint.hashCode());
    }
    Collections.sort(isovists, new Comparator<Isovist>() {
              @Override
              public int compare(Isovist o1, Isovist o2) {
                  float val =  o1.getValue(which, isovists.size() ); 
                  float val2 = o2.getValue(which, isovists.size() );
                  
                  return -Float.compare(val , val2 );
              }
          });
  }     
  if( count>0)gCurrentValueAverage = (float)(totalVal/(float)count) ; 
  colorMode( RGB, 255, 255, 255 ) ;
}
float gCurrentValueAverage = 0 ; 



//----------------------------
void buildSmallestPathFrom( Isovist start, List<Isovist> all  ) 
{ 
   //println( all); 
   // O(N) 
   for( NodeInGraph it: all )  {  it.fDepth = Float.POSITIVE_INFINITY; }
   
   Set<NodeInGraph> processed = new HashSet<NodeInGraph>() ; 
   Set<NodeInGraph> consideration = new HashSet<NodeInGraph>() ; 
  
   start.fDepth = 0.0f; 
   processed.add( start) ;
   updateFromNode( start , consideration) ; 
   //println("Considering " , consideration ); 
   do // Worst case O(N) 
   { 
     // find one with smallest fDepth
     float smallestDepth = Float.POSITIVE_INFINITY;
     NodeInGraph smallest = null ; 
     for( NodeInGraph it: consideration ) // O(N) worste case
     { 
       if(it.fDepth < smallestDepth ) 
       { 
         smallest = it ; 
         smallestDepth =it.fDepth; 
       } 
     }
     //println("BEST", smallest, smallestDepth ) ; 
     updateFromNode( smallest , consideration) ; 
     consideration.remove(smallest); 
     processed.add(smallest);
     
     //println("Considering " , consideration ); 
   } while( consideration.size()> 0 ) ;
   
  
  // println( all);
  // println("Processed",processed);  
} 

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
  assert size> 0 ;
  assert  minX <= maxX;
  this.rays  = new ArrayList<PVector>();
  for ( int i  = 0; i < 360; i++) rays.add( PVector.random2D());

   
  if (size==1)println("generateStocasticIsovist::Start", minX, maxX, minY, maxY, gBoundingShapeBoundary );
  addStocasticIsovist( buidlings, size ) ;
}
//-------------------------------------------------------------------------
void addStocasticIsovist( java.util.List<GeneralPath> buidlings, int size  )
{
  int i = 0 ;
  PVector v  = new PVector( 492.0, 467.0 ) ;
  int  sec = second(); 
  do
  {
    float  maxDistance = - (Float.MAX_VALUE-1 )  ;
    PVector best = null ;
    for ( int a = 0; a < size; a++ ) // make 40 points find furtherst
    {
      v = PVector.random2D(); //try again ..
      do
      { // pick a point in spave
        v.x = random( (float)minX, (float)maxX ) ;
        v.y = random( (float)minY, (float)maxY ) ;
      }
      while ( pointIsValid(v, buidlings)== false  );// dont fall in a building.
      float d = distanceToNearst( v, isovists ) ;
      //println( d, maxDistance);
      if (  d > maxDistance  )
      {
        maxDistance = d ;
        best = v;
      }
    }
    // println( "BEST", best, maxDistance  ) ;
    v = best ;
  assert best !=null :  "impossible 9933";

    points.add(  v ) ;
    Isovist iso = new Isovist( v ) ;
    iso.computIsovist(shapes ) ;
    synchronized( isovists ) {  isovists.add( iso) ; } 

    if( second() != sec )
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
  if ( pointIsValidRays.size()!=360)  // Cache
  {  pointIsValidRays.clear();
    for ( int i  = 0; i < 360; i++)
    {
      pointIsValidRays.add( PVector.random2D());
    }
    println("----create rays chache---");
  }
  if( gBoundingShapeBoundary!=null &&   gBoundingShapeBoundary.contains(  v.x, v.y ) == false ) return false ;
  synchronized( shapes )
  { 
    for ( GeneralPath p : shapes)
    {
      if ( gBoundingShapeBoundary == p ) continue ;
      if (  p.contains( v.x, v.y ) ) return false ;//should be fast. 
    }
  } 
  
  assert  gBoundingShapeBoundary != null : 
  "Null bounday - need to do the test for infinti test ";  
  //  if this fais go up 
  /*  DON'T CHANGE THIS CODE- EXPERIMENT 1 - IS NESSASRY for 2000 
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
        println("testRaysForIninity pre-screen failed");
        assert false :" test rays for infinity failed."; 
        return false ;
      }
  }*/ 
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

//-----------------------------------------------------------------------
void generateRayForCenter( java.util.List<PVector> rays, PVector center )
{
  assert rays.size() == 360;
  int i = 0 ;
  for ( PVector p : rays )
  {
    p.x = center.x + (myInfinity * cos( map( i, 0, 360, 0, PI*2) )) ;
    p.y = center.y + (myInfinity * sin( map( i, 0, 360, 0, PI*2) )) ;
    i+=1 ;
  }
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
      for ( PVector r : rays )
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

//-----------------------------------------------------------------------
boolean testRaysForIninity( java.util.List<PVector> rays, PVector center )
{
  assert rays.size() == 360;
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
          }
          else return ;  // Parallell non-overlapping
        }
        else {
          if (Math.min (x0, x1) < Math.max (x2, x3) ||
              Math.max (x0, x1) > Math.min (x2, x3)) {
            double twoMiddle = x0 + x1 + x2 + x3 -
                               geom_min (x0, x1, x2, x3) -
                               geom_max (x0, x1, x2, x3);
            x = (twoMiddle) / 2.0;
            y = a0 * x + b0;
          }
          else return ;
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
    }
    else if (geom_equals (a1, INFINITY)) 
    {
      x = x2;
      y = a0 * x + b0;
    }
    else 
    {
      x = - (b0 - b1) / (a0 - a1);
      y = a0 * x + b0; 
    }
    
    intersection[0] = x;
    intersection[1] = y;
  } 
  
