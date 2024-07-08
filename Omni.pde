
//---------------------------------------------------------------------
void testGraphOmni()
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
  a.connectOmniDiretional(b, 0.1 ) ;
  b.connectOmniDiretional(a, 0.1);
  b.connectOmniDiretional(c, 1.0 ) ;

  c.connectOmniDiretional(b, 1.0);
  c.connectOmniDiretional(d, 1.0);
  d.connectOmniDiretional(c, 1.0);

  a.connectOmniDiretional( e, 0.5 ) ;
  e.connectOmniDiretional( a, 0.5);
  e.connectOmniDiretional( c, 0.2);
  c.connectOmniDiretional( e, 0.2);

  buildSmallestPathFromOmni( c, all ) ;

  float total = 0.0f;
  for ( Isovist it : all )
  {
    total += it.fOmniDepth;
  }
  println("Omni total", total );
  assert total == 2.7f;
}

//------------------------------------------------------------------------------

void updateFromNodeOmni( NodeInGraph start, Set<NodeInGraph> consideration)
{
  assert start != null ;
  assert consideration != null; 
  
  for ( NodeInGraph it : start.omniDirectionToWeightedEdges.keySet())
  {
    float addedDepth = start.omniDirectionToWeightedEdges.get(it);
    if ( (start.fOmniDepth + addedDepth) <  it.fOmniDepth )
    {
      it.fOmniDepth = start.fOmniDepth + addedDepth;
      consideration.add( it ) ;
    }
  }
}

//------------------------------------------------------------------------------
void buildSmallestPathFromOmni( Isovist start, List<Isovist> all  ) 
{ 
   //println( all); 
   // O(N) 
   for( NodeInGraph it: all )  {  it.fOmniDepth = Float.POSITIVE_INFINITY; }
   
   Set<NodeInGraph> processed = new HashSet<NodeInGraph>() ; 
   Set<NodeInGraph> consideration = new HashSet<NodeInGraph>() ; 
  
   start.fOmniDepth = 0.0f; 
   processed.add( start) ;
   updateFromNodeOmni( start , consideration) ; 
   //println("Considering " , consideration ); 
   do // Worst case O(N) 
   { 
     // find one with smallest fDepth
     float smallestDepth = Float.POSITIVE_INFINITY;
     NodeInGraph smallest = null ; 
     for( NodeInGraph it: consideration ) // O(N) worste case
     { 
       if(it.fOmniDepth < smallestDepth ) 
       { 
         smallest = it ; 
         smallestDepth =it.fOmniDepth; 
       } 
     }
    // println("BEST", smallest, smallestDepth ) ; 
     updateFromNodeOmni( smallest , consideration) ; 
     consideration.remove(smallest); 
     processed.add(smallest);
     
    // println("Considering  size =" , consideration.size() ); 
   } while( consideration.size()> 0 ) ;
   
  
  // println( all);
  //println("Processed",processed);  
} 
//-----------------------------------------------------------------

void computeAllFractionalDepthAssumingEdgesAreBuiltOmni()
{
  for ( Isovist it : isovists )
  {
    buildSmallestPathFromOmni( it, isovists   )  ;
    double t = 0.0;

    for ( Isovist k : isovists )
    {
      t +=  k.fOmniDepth;
    }
    it.fTotalOmniDepth = (float) t  ;
  }
}
