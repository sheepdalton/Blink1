final float KSCALE_WEGHT = 1.0 ; 
List<Cluster> gClusters = null ; 

class Cluster
{ 
    // I AM USING A HACK HERE WHERE CENTER.Z HOLDS THE ACTUAL VALUE 
    PVector center ; 
    Set<Isovist> items ;
    
    float averages[ ] ; 
     
    //-------------------------
    Cluster()
    { 
      items = new HashSet<Isovist>( 10 ) ; 
      averages =  new float[ 3 ] ; 
      center = new PVector( random(0,100), random(0,100)); 
    };
    //-------------------------
    Cluster( float minX , float maxX, float minY , float maxY ) 
    { 
      float x = random(minX,maxX) , y = random(minY,maxY) ; 
      reset( x , y) ; 
    } 
    //--------------------------------------
    void reset( float x, float y ) 
    { 
      center = new PVector(x , y ); 
      averages  = new float[ 3 ] ;
      averages[0] = x ; 
      averages[1] = y; 
      averages[2] = random(0,KSCALE_WEGHT);
      
      items = new HashSet<Isovist>( 10 ) ;  
    } 
    //--------------------------------------
    Cluster( float x, float y ) 
    {
      reset( x , y);  
    }
    
    PVector getCenter(){ return center; } 
    float getAverageValue() { return center.z ; } // see hack 
    //-------------------------
    void add( Isovist it ) 
    { 
       //it.getCenter().z = it.getValue( kTOTAL_FRACITON_INTEGRATION , 0 ) *KSCALE_WEGHT;
       items.add( it); 
    } 
    void  resetBeforeUpdate(){ items.clear(); } 
    //------------------------
    void updateNewCentroid()
    { 
      assert       averages  !=null ; 
      if( items.size() == 0) return ;  
      float totals[ ] = { 0.f , 0.f , 0.f } ; 
      int count = 0 ; 
      for( Isovist iso : items ) 
      { 
           totals[0] += iso.getCenter().x; 
           totals[1] += iso.getCenter().y ;
           
           totals[2] += iso.getValue( kTOTAL_FRACITON_INTEGRATION , 0 ) *KSCALE_WEGHT  ; 
           count ++ ;  
      } 
      assert count != 0 : "should be more than one item in block.." ; 
      for( int a =0 ; a < 3 ; a++ ) 
      { 
         averages[a] = totals[a] / count ; 
      } 
      center.x  = averages[0];
      center.y  = averages[1];
      center.z =  averages[2] ; // NOTICE THIS IS SCALED 
    } 
    //----------------------------------
    void draw()
    { 
      assert center != null ;
    
      
       strokeWeight( 0.5 ) ; 
       stroke( 128,0,0);
      // println(connections.size())
   // draw all connections 
       
       for( Isovist  who : items ) 
       { 
         line(who.center.x , -who.center.y, center.x , -center.y);
       }
       
      stroke( #D10EE0 ); 
      noFill( ); 
      strokeWeight( 5 ) ; 
      circle( center.x , -center.y , 10 ) ; 
      strokeWeight(1);  
    } 
} 
//------------------------------------
List<Cluster> processClusters(int K,  List<Cluster> clusters , java.util.List<Isovist> isovists )
{
  println("Processing clusters"); 
  if( clusters == null || clusters.size() == 0 ) 
  { 
  
    println("MAKING NEW CLISTERS" + K); 
    clusters = new ArrayList<Cluster>( K ) ;
 
    for ( int a = 0; a < K; a ++ )
    {
      // v.x = random( (float)minX, (float)maxX ) ;
      //     v.y = random( (float)minY, (float)maxY ) ;
      Isovist iso = isovists.get( (int) random( 0, isovists.size() )); 
      Cluster it = new Cluster(iso.getCenter().x , iso.getCenter().y) ;
      clusters.add( it );
     // println("NEW Cluster ", it.center.x, it.center.y ) ;
    }
  } else
  { 
    println("assiging to cluters" ) ; 
     for( Cluster c : clusters )c.resetBeforeUpdate(); 
     for( Isovist iso : isovists ) 
     { 
       Cluster c = findNearest( iso , clusters ) ; 
       c.add( iso); 
     } 
     for( Cluster c : clusters ) c.updateNewCentroid(); 
    
  } 
  return clusters ; 
}

Cluster findNearest( Isovist iso , List<Cluster> clusters ) 
{ 
  assert iso!=null ; assert clusters != null ; 
  float nearestDistance = Float.MAX_VALUE ; 
  Cluster best=null ; 
  for( Cluster c:clusters) 
  { 
    // NOTE THIS RELIES ON THE Z HACK SEE ABOVE. 
    float d = c.getCenter().dist( iso.getCenter()); 
    if( d < nearestDistance ) 
    { 
      best = c ; 
      nearestDistance = d ; 
    } 
  } 
  return best ; 
} 
/****
if( key == 'c')
    { 
      if( gClusters == null || gNumberOfClusters == 0  ) 
      { 
       String input = JOptionPane.showInputDialog(null, "Enter the number of clusters:",
                "Cluster Input Dialog", JOptionPane.QUESTION_MESSAGE);
       if( input == null ){ gClusters=null ; return ; } 
        int numberOfClusters = 0;
        try {
            numberOfClusters = Integer.parseInt(input);
            if( numberOfClusters < 1) 
            { 
              JOptionPane.showMessageDialog(null, input+ "Please enter a valid number.",
                    "Error", JOptionPane.ERROR_MESSAGE);
              return ; 
            } 
            gNumberOfClusters = numberOfClusters;
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(null,input+ "is not a number ! Please enter a valid number.",
                    "Error", JOptionPane.ERROR_MESSAGE);
        }
      } 
        
       gClusters=  processClusters(gNumberOfClusters,  gClusters, isovists ) ;
    } 
     
    if( key == 'C') { gClusters=null ; return ; } 
 */ 
 
 //-------------------------------------------------------------------------
void groupIsoivsts()
{
  println("BEFORE groupIsoivsts:", isovists.size()) ;
  Isovist bestA = null, bestB = null ;
  double bestD = Float.MAX_VALUE ;
  float d = Float.NaN ;
  float bestValue = Float.MAX_VALUE ;
  // use the connectivity list.. x
  for ( Isovist from : isovists )
  {
    for ( Isovist too : from.connections  )
    {
    assert from != too :
      "Impossible self connection." ;
      if ( from == too ) continue ;
      float v = sq( from.myCurrentValue - too.myCurrentValue );
      if (  v <= bestValue  )
      {
        if ( bestValue == v )
        {
          d = from.howFar( too ) ;
          if ( d < bestD ) // look for smallest distance.
          {
            bestA = from ;  // check mid point not in a building.
            bestB = too ;
            bestD = d ;
            bestValue = v ;
          }
        } else
        {
          bestA = from ;  // check mid point not in a building.
          bestB = too ;
          bestD = d ;
          bestValue = v ;
        }
      }
    }
  }

  if ( bestA != null && bestB != null )
  {
    assert bestA != null ;
    assert bestB != null ;
    println("grouping: smallest distance", bestA.howFar(bestB ), " diff",
      sq( bestA.myCurrentValue - bestB.myCurrentValue ), bestA, bestB  ) ;

    isovists.remove( bestB ) ;
    for ( Isovist conn : bestB.connections )
    {
      conn.connections.remove( bestB ) ; // remove me
    }
    bestA.center = bestA.getCenter().lerp( bestB.getCenter(), 0.5  )  ;
    bestA.myColor = lerpColor( bestA.myColor, bestB.myColor, 0.5f ) ;

    bestA.totalDepth           =  (bestA.totalDepth + bestB.totalDepth)/2;
    ;
    bestA.myGradientDepth = (bestA.totalDepth + bestB.totalDepth)/2;
    bestA.myCurrentValue  = (bestA.myCurrentValue + bestB.myCurrentValue)/2;
    bestA. totalfDepth    =      (bestA.totalfDepth + bestB.totalfDepth)/2;
    ;
  } else
  {
    println("A or B null", bestA, bestB ) ;
  }
  println("AFTER groupIsoivsts:", isovists.size()) ;
}

 
