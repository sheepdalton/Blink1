/* 
  constants 
*/ 
  
  enum Measure {
        eNegativeConnectivity, 
        eDEPTH , 
        eSqureRootConnectivity 
    };
    
final int eNegativeConnectivity = 0 ;
final int eDEPTH = 1 ; 
final int eSqureRootConnectivity = 5;
final int eLogTotalDepth = 3;

final int eTOTAL_DEPTH_MEASURE = 2 ;
final int eSevenN = 5; 
final int ePureConnectivity = 6; 
final int eRA = 7; 
final int eDvalIntgration = 8 ; 
final int eTeklenburg = 9 ;
final int eNegativeTeklenburg = 10 ; 
final int eHillierFactionalNAIN = 11 ; 
final int eDaltonGradient  = 12; 
final int eMeanDepth = 13 ; 
final int kDVAL = 14 ; 
final int kAXDVAL = 15 ; 
final int kClusterCoiff = 16; 
final int KMEANS_CLUSTER = 17 ; 
final int kCENTERX = 18 ; 
final int kCENTERY = 19 ; 

final  int kTOTAL_AREA_OVERLAP_FRACTION = 20; 
final  int kDEPTH_FRACION = 21 ; 
final int  kTOTAL_FRACITON_INTEGRATION = 22 ; 
final int  kFRACTIONAL_CONNECTIVITY = 23; 
final int  kLogTOTAL_FRACITON_INTEGRATION = 24;
final int  kSRT_TOTAL_FRACITON_INTEGRATION = 25 ; 
final int  kLog_eTOTAL_DEPTH_MEASURE = 26; 

final int  kSYMETRIC_CONNETIVITY  = 27 ; 
final int  kSYMETRIC_TOTAL_DEPTH  = 28 ;
final int  kLog_SYMETRIC_TOTAL_DEPT = 29 ;
final int  kSYMETIC_STEP_DEPTH = 30; 
final int  kJACOBIAN_BY_CON    = 31; 


final int K_ITEMS = 3; // for KMEans clustering 
final int K1024 = 1024; 
final boolean kNoDebugIsovistIntersection = false ; 
final boolean kDebugIsoIntersect = true; 
// DifferntialIsovist 
boolean gDrawIsovistLinks = false ; 
float     gIsoivstDotSize = 2; 
//boolean gVisualiseTheIntersection = false ; 
//===============================================================================
 class Isovist extends NodeInGraph
 { 
    PVector center ; 
    GeneralPath outline ; 
    java.util.List<PVector>  rays; 
    java.util.List <Isovist> connections; 
    int     depth = 0 ;  // integer step depth. 
    int     totalDepth = 0 ; 
    double  myGradientDepth = 0.0 ; 
    float   clusterCoif = 0.0  ; 
    int     kMeansCluster = -1; 
    
    color   myColor ; 
    float   myCurrentValue ; 
   
    float   minH = 0, maxH = 0, minV = 0, maxV = 0 ; 
    
    Isovist( String x ) { super( x ) ; } 
    //-------------------------------------
    Isovist( PVector center ) 
    { 
      super( center.toString());
      this.center = center ; 
      rays = null ; 
      connections  = new ArrayList<Isovist>(); 
      myColor = #D4E51E; 
      colorMode(HSB, 360, 100, 100); // Set color mode to HSB (Hue, Saturation, Brightness)
      
      float hue = random(360);
      float saturation = 100;
      float brightness = 100;
      myColor = color(hue, saturation, brightness,64); 
      
      colorMode(RGB,255,255,255); 
      minH = Integer.MAX_VALUE ;
      maxH = -Integer.MAX_VALUE ;
      minV = Integer.MAX_VALUE; 
      maxV = -Integer.MAX_VALUE ; 
     
    }
    @Override 
    String toString()
    { 
      return super.toString() + " " + center ; 
    }
    PVector  getCenter(){ return   center  ; } ; 
   
   //objects are the same if the have the same general path. 
    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null) return false;
        if (this.getClass() != o.getClass()) return false;
        Isovist it = (Isovist) o;
        return outline.equals( it.outline); 
    } 
    //------------------------
    float howFar( Isovist other ) 
    { 
      assert( this.center != null ); 
      assert( other.center != null );
      
      return this.center.dist( other.center) ; 
    } 
    //-----------------------
    public void difuseLabels()
    { 
      HashMap<Integer,Integer> histogram = new HashMap<Integer,Integer>( ) ; 
      for( Isovist link: connections ) 
      { 
          Integer lable = link.kMeansCluster ; 
          if( lable == -1 ) continue ; // skip if empty 
          //if( abs(  link.totalDepth - totalDepth) >18 ) continue ;
          if( histogram.containsKey( lable ) ) 
          { 
            int count = histogram.get( lable )   ; 
            histogram.put( lable, count ) ;
          } 
          else 
          { 
             histogram.put( lable, 1 )  ;
          }
      }
      
      int maxCount = -1 ; 
      for( Map.Entry<Integer, Integer>  item: histogram.entrySet() ) 
      { 
           int lable = item.getKey(); 
           int count = item.getValue(); 
           if( count > maxCount ) 
           { 
             this.kMeansCluster = lable;
             maxCount = count; 
             print(lable, count );
           } 
      } 
      println("Most popular ",kMeansCluster ," count= ",  maxCount ) ; 
      
      //if( kMeansCluster != -1 ) selected = true ;  
    } 
    //-----------------------
    // FOR K-means clustering 
    float [ ] fillArray( float values[ ]   ) 
    { 
      values[ 0 ] = this.getValue(kCENTERX,0); 
      values[ 1 ] = this.getValue(kCENTERY,0); 
      values[ 2 ] = this.getValue( kClusterCoiff, 0 ) ; 
      if(values.length > 3 ) values[ 3 ] = this.getValue( eTOTAL_DEPTH_MEASURE , 0 ) ;  
      
      return values ; 
    } 
    //-----------------------
    float [ ] fillArray( float values[ ] , float maxValues[ ] , float minValues[ ]   ) 
    { 
      values = fillArray( values ) ; 
      for(int e = 0 ; e < K_ITEMS ; e++ ) values[e] =  map( values[e],minValues[e], maxValues[ e ],0,1);
       
      return values ; 
    } 
     //-------------------------------------
     /* Local cluster Coefficient  =  2 * interconnectios / ( K * (K-1)    
        interconnections are the edges at level 2 
     */ 
     float computeClusterCoeifAssumDepthComputed() 
     { 
       // debuging.. selected = true; 
        int countOfLevel1 = 0 ; 

        for( Isovist nebour : connections ) 
        { 
           assert nebour != null ; 
           for( Isovist nebours_nebour: nebour.connections ) 
           { 
             // I am connected to you and we are both connected to start 
             assert  nebour != nebours_nebour : "I am connected to my self " ;   // don't check self. 
             if( nebours_nebour.depth == 1 ) countOfLevel1 += 1; // inter connections 
             //println( nebour.depth , nebours_nebour.depth ) ; 
           }
          // println( "---------" , nebour.connections.size() , nebour.depth , countOfLevel1  ) ; 
        } 
        float Nv = countOfLevel1 ; // these are counted twice 
        float Kv = connections.size() * ( connections.size()  -1 ) ;
   
       // println("connections.size()" , connections.size() ,  " Kv  " , Kv , " Nv " , Nv/2  , " Cluster " ,   Nv/Kv  );
        if( connections.size() <= 1  ) return 0.0f ; 
        clusterCoif = Nv/Kv; 
        return  clusterCoif ;
     } 
    //-------------------------------------------------
    //public  double  log2(double N) {  return (Math.log(N) / Math.log(2));  }
    // from Depthmap code in pubic domain. 
    public  double teklenburg( int t_nodecount , int t_totaldepth) 
    { 
        return  Math.log(0.5 * (t_nodecount - 2.0)) / Math.log(t_totaldepth - t_nodecount + 1.0)   ; 
    } 
    
    
    double  dvalueOLD_SHEEP(int total_nodes ) 
    {  
       return  2.0 * (total_nodes * ( log2( (total_nodes+2.0)/3.0) - 1.0) + 1.0) / ((total_nodes - 1.0) * (total_nodes - 2.0)) ;
    } 
    /*******************************************************************/ 
        /** work out the Dimaond value -                                    
         * this cacluate the gDeevalue  which is then uses as a constant    
         * by the Mean depths part of the parogram 1                       
         * Modifed:Friday, March 16, 1990 2:45:55 pm                       
         * - John P. Says that the Devalue calculations are incorret this  
         * version used the formula for the Dvalue calc taked from Alans    
         * Alan6 program which he makes verious claimes for. The formula
         * Does agree with the numbers in that BOOK.                       
         * Note for better accruacy use log( n ) rather than 6.664 ect 
         *  <pre> 
           (( 6.644 * S * ( 0.434294 * Math.log( S + 2 ) )) - (5.17 * S )+ 2 )
                   / ((S - 1 )* ( S - 2 ) ) ; 
          </pre> 
          where S = the size of the system. 
         * @param NoOfSpaces Number of reachable  spaces in the system  
         * @return dimond value.   
         * @since   Axman,LogladyOrage box  
         * note log is which ? 
         */ 
        /*******************************************************************/ 
        final float  AXMAN_deevalue(  long  NoOfSpaces) 
        { 
         double  S  =  (double )NoOfSpaces ; 
         double it ; 
         
         if( NoOfSpaces <= 0 ) return 1.0f; 
           
         it  = (( 6.644 * S * ( 0.434294 * Math.log( S + 2 ) )) - (5.17 * S )+ 2 )
                   / ((S - 1 )* ( S - 2 ) ) ; 
      
          return  (float)it ; 
        }
        
        
 /*  THIS CODE FROM PAFMath.h  deptmap1010entire 
    
    #define M_1_LN2 1.4426950408889634073599246810019
    #define ln(X) log(X)
    
     double log2(double a)
      {
         return (ln(a) * M_1_LN2);
      }

    // Hillier Hanson dvalue
    /// inline double dvalue(double k){  return 2.0 * (3.3231 * k * log10(k+2) - 2.5863 * k + 1.0) / ((k - 1.0) * (k - 2.0));}
    
    
    // Hillier Hanson dvalue (from Kruger 1989 -- see Teklenburg et al)
    inline double dvalue(double k)
    {
       return 2.0 * (k * (log2((k+2.0)/3.0) - 1.0) + 1.0) / ((k - 1.0) * (k - 2.0));
    }

*/ 
      final float   M_1_LN2  = 1.4426950408889634073599246810019; 
      double log2(double a)
      {
               return (ln(a) * M_1_LN2);
      }
      double  ln(double X){ return  Math.log( X); } 
      double dvalue(double k)
      {
         return 2.0 * (k * (log2((k+2.0)/3.0) - 1.0) + 1.0) / ((k - 1.0) * (k - 2.0));
      }
    //---------------------------------------------------------------------------- 
    public int connectivity(){ return (connections ==null?0:connections.size( )); }  
    public float normalisedAngularIntergration(  int  total_nodes  ) 
    { 
      return pow(total_nodes,-1.2)/ (totalDepth+2) ;  
    } 
    //-------------------------------------------------
    void setDaltonGradient( double d )
    { 
      assert d >= 0 ; // 0999 no negatives. 
      this.myGradientDepth = d; 
    } 
    //-------------------------------------------------
    public float meanDeath( int total_nodes ) 
    { 
      return   totalDepth/(float)(total_nodes-1) ; 
    }
    //-------------------------------------------------
    public float RA( int total_nodes ) 
    { 
      float mean_depth = meanDeath(total_nodes); 
      return (2.0 * (mean_depth - 1.0)) / float(total_nodes - 2); 
    }
    //-------------------------------------------------
    public float getValue( int what, int  total_nodes  ) 
    { 
      switch( what ) 
      { 
        case eNegativeConnectivity: return -connections.size();
        case eDEPTH: return (float) depth ; 
        case eTOTAL_DEPTH_MEASURE: return totalDepth; 
        case 3: return log( totalDepth ) ; 
        case 4: return sqrt( totalDepth ) ; 
        case eSevenN : return  totalDepth/(7.0*total_nodes) ; 
        case ePureConnectivity: return -connections.size() ; 
        case eRA: 
        { 
         //  float mean_depth = totalDepth/(float)total_nodes ; 
          float ra =  RA( total_nodes ) ;// 2.0 * (mean_depth - 1.0) / float(total_nodes - 2); 
   
          return ra ; 
        } 
        case  eDvalIntgration: 
        { 
          /*  PAF code. 
          case INTEGRATION_RRA:
            if (attributes[GRAPH_SIZE].intval > 2) {
               val = (2.0 * (QUICK_MD - 1.0)) / (double(attributes[GRAPH_SIZE].intval - 2) * dvalue(attributes[GRAPH_SIZE].intval));
            }
            */ 
          float mean_depth =  meanDeath( total_nodes ) ;// totalDepth/(float)(total_nodes-1) ; 
          float ra =RA(total_nodes);   //2.0 * (mean_depth - 1.0) / float(total_nodes - 2); 
          double rra_d = ra * dvalue(total_nodes);// paf style Dvalue 
          return (float) rra_d ; 
        } 
        case eTeklenburg: 
        { 
          return (float)teklenburg(total_nodes,  totalDepth);  
        } 
        case eNegativeTeklenburg: 
        { 
          return (float) (-1* teklenburg(total_nodes,  totalDepth));
        } 
        case eHillierFactionalNAIN: 
        { 
          return  - normalisedAngularIntergration( total_nodes ) ; 
        } 
        case eDaltonGradient: 
        { 
          return (float)-myGradientDepth ; 
        } 
        case eMeanDepth: 
        { 
          return  meanDeath( total_nodes ) ;
        } 
        case kDVAL: 
        { 
          return (float) dvalue(total_nodes); 
        } 
        case kAXDVAL:  { 
          return (float) AXMAN_deevalue( total_nodes ) ; 
        } 
        case kClusterCoiff:  { return  clusterCoif ; } 
        case KMEANS_CLUSTER: { return this.kMeansCluster; } 
        
        case kCENTERX:{ return this.center.x ; } 
        case kCENTERY: { return this.center.y ; } 
        case kTOTAL_AREA_OVERLAP_FRACTION: 
        { 
          float f = 0.0; 
          for( Float it: connectedToWeighted.values()) 
          { 
             f = f + it ; 
          } 
     
          return -f; 
        } 
        case kDEPTH_FRACION: return fDepth; 
        case kTOTAL_FRACITON_INTEGRATION: return totalfDepth ; 
        case kFRACTIONAL_CONNECTIVITY: 
        { 
          float f = 0.0; 
          int c = 0 ; 
          for( Float it: connectedToWeighted.values()) 
          { 
             f = f + it ; c++ ; 
          } 
         // println(f); 
          return  -f ; // WAS  -(f/c); 
        } 
        case  kLogTOTAL_FRACITON_INTEGRATION: return log( totalfDepth ) ;
        case  kSRT_TOTAL_FRACITON_INTEGRATION: return sqrt( totalfDepth ) ;
        
        case  kLog_eTOTAL_DEPTH_MEASURE : return log( totalDepth) ;
        
        case kSYMETRIC_CONNETIVITY:
        { 
          float f = 0.0; 
          for( Float it: omniDirectionToWeightedEdges.values()) 
          { 
             f = f + it ; 
          } 
          return -f; 
        }  
        case  kSYMETRIC_TOTAL_DEPTH  : return fTotalOmniDepth ; 
        case  kLog_SYMETRIC_TOTAL_DEPT:  return log( fTotalOmniDepth); 
        
        case kSYMETIC_STEP_DEPTH : return fOmniDepth; 
      
        case kJACOBIAN_BY_CON : return  log( totalfDepth  / connections.size() ) ; 
        
        
        
        /// @@@ TODO - handle the other cases. 
        default :  { assert false ; return 0.0f; } 
      } 
    } 
    //-------------------------------------------------
    public float getFractionalDepth(){ return fDepth; } 
    public int   getIntergrationDepth(){ return depth; } 
    //-------------------------------------------------
    public float getValue( int d  ) 
    { 
      return getValue( d, Integer.MAX_VALUE-1); 
    } 
    //-------------------------------------------------
    @Override 
    public int hashCode()
    { 
      if( outline == null ) return label.hashCode();
       assert outline !=null ; // should not be possile. 
       return outline.hashCode(); 
     } 
    //-------------------------------------
    public PVector peekCenter()
    { 
      return center ; 
    } 
    //-------------------------------------
    public void connect(Isovist other ) 
    { 
      //if( connections.contains(other)== false)  // why did I remove ? 
      connections.add( other);
     // println("ADDING"); 
    }
  /*  @Override 
    void connect( NodeInGraph g, float weight  ) 
    { 
      assert g instanceof Isovist : "Design assumptioin that only using isoivsts is broken";
      super.connect( g, weight ) ; 
      connections.connect( (Isovist )g); 
    }*/ 
    //----------------------------------------------------
    public Isovist findMostSimilarToYou()
    { 
      float smallest = Float.MAX_VALUE  ; 
      Isovist bestToo = null ; 
      float myVal = this.getValue( kTOTAL_FRACITON_INTEGRATION , 0 ); 
      
      for( NodeInGraph ix : this.connectedToWeighted.keySet() ) 
      { 
        assert ix instanceof Isovist ; 
        Isovist ist = (Isovist) ix ; 
        float d = sq( myVal - ist.getValue( kTOTAL_FRACITON_INTEGRATION , 0 )) ; 
        /* 
          if the values are the same then choose which is closes . 
        */ 
        if( d < smallest ) 
        { 
          smallest = d ; 
          bestToo = ist ; 
        } 
      } 
      assert bestToo != null : "  " ; 
      return bestToo ; 
    } 
    //----------------------------------------------------
    public void resetConnections() 
    { 
      connections.clear() ; 
    } 
    //-----------------------------------------------------
    public int connections(){  return connections.size();} 
    public PVector makeRandomPointInside( ) 
    { 
      assert validMinMax(); 
       float px,py ;
       do
       { 
          px  = random( minH,maxH ) ; 
          py =  random( minV ,maxV ) ; 
       }
       while( this.isPointInsideIsovist(px, py ) == false ) ;
       PVector result = new PVector( px, py ) ; 
       
       return result ; 
    } 
    //--------------------------------------------------------------
    public boolean NOT( boolean it ){ return ! it ; }
    public boolean validMinMax()
    { 
      if( ( minV == maxV  ||  minH == maxH ) )
         println( "ISOVST ERROR: internal min max not set " + ( minV !=maxV  )+"\n "+ 
      (minH + " "+ maxH )+ " \n<<" + this + ">>")  ; 
      return !( minV ==maxV  ||  minH == maxH )  ; 
    }  
    //--------------------------------------------------------------
    public PVector makeRandomPointInsideEither(  Isovist other ) 
    { 
      assert  validMinMax() ==true; 
       boolean isInMe ; 
       boolean isInOther ; 
       boolean isInEither ; 
       float px,py ;
       
       float mH = min(minH, other.minH ) ; 
       float mxH = max( maxH, other.maxH ) ; 
       float mV = min(minV , other.minV ) ; 
       float mxV = max( maxV , other.maxV ) ; 
       
       do
       { 
          px  = random( mH,mxH ) ; 
          py =  random( mV  ,mxV ) ;
          
          isInMe = this.isPointInsideIsovist(px, py ) ; 
          isInOther = other.isPointInsideIsovist(px,py); 
          isInEither = isInMe ||  isInOther; 
         // fill(127);
         // circle( px, -py, 3); 
          //println(  isInEither, mH,px, mxH , mV ,  py, mxV , isInMe , isInOther, isInEither  ); 
       }
       while( !isInEither  )   ;
       
       PVector result = new PVector( px, py ) ; 
       
       return result ; 
    }
    // public PVecotr makeRandomPointInside( float oMinH , oMinV, oMaxH , oMaxV ) // generate within common area. 
    //---------------------------------------
      /* 
           Area of Intersection / Area of Me 
       */
      float areaofOverlapWith( Isovist other , final int K ) 
      { 
         assert this.validMinMax()==true;
         assert other.validMinMax() == true ; 
         
         int ix = 0 ; 
         int  insideMe = 0 , insideOther = 0 ; 
         
         if( other == this ) return 1.0; 
         if( other == null ) return 0.0f; // special value = no connection 
         
         do{ 
             PVector p = makeRandomPointInside() ; 
             insideMe += 1; 
             ix += 1 ;
             if( other.isPointInsideIsovist(p.x , p.y ) ) 
             { 
               insideOther += 1 ; 
               //if( gCheckIntersectOther!= null ) gCheckIntersectOther.add(p); 
             }else
             { 
               //if( gCheckInersectionMe !=null) gCheckInersectionMe.add( p ) ; 
             } 
         } while ( ix < K ) ; 
         if( insideOther == 0 ) return 0.0f; // 0.0 is special number 
         assert insideMe  == K :"Something has gone deeply wrong "+ insideMe + " " + K  ; 
         // if the number of overlaps is small double the number to get better estimate. 
          // if ( insideOther < 5 ) return areaofOverlapWith( other, K * 2 ) ; 
        // println( insideMe , "Inside other " , insideOther);
         return  float(insideOther) / float(insideMe )  ; 
      }
       //-------------------------------------
       /* 
           Area of Intersection ( A X B  )/ Area of Union of A + B   
           
           Test with Isoivsts in rectangles. 
       */ 
      float areaofOverlapWithOmni( Isovist other , final int K , boolean debug ) 
      { 
         int ix = 0 ; 
         int  insideBoth = 0 , insideEither = 0 ; 
         
         if( other == this ) return 1.0f ; 
         if( other == null ) return 0.0f ; // special value = no connection 
         
         do{ 
             PVector p = makeRandomPointInsideEither( other ) ;  
             if( debug ) 
             { 
              // fill(255,127,0);
              // circle(p.x , -p.y,  3 ) ; 
             } 
             
             insideEither += 1; 
             ix += 1 ;
             
             if( other.isPointInsideIsovist(p.x , p.y ) && this.isPointInsideIsovist(p.x,p.y) ) 
             { 
               insideBoth += 1 ; // inside me and inside other. 
               
               if( gCheckIntersectOther!= null )gCheckIntersectOther.add(p); 
               if(debug)
               { 
                // fill(255,0,0);
                // circle(p.x , -p.y,  5 ) ; 
               } 
             }else
             { 
               if( gCheckInersectionMe !=null)  gCheckInersectionMe.add( p ) ; 
                if(debug)
                { 
                 fill(0,255,0);
                 circle(p.x , -p.y,  3 ) ;
                } 
             } 
         } while ( ix < K ) ; 
         
         if( insideEither == 0 )
         { 
           assert false:"This should never happe "; 
           return 0.0f; // 0.0 is special number 
         } 
         assert insideEither  == K :("Something has gone deeply wrong "+ insideEither + " " + K ) ; 
         // if the number of overlaps is small double the number to get better estimate. 
          // if ( insideOther < 5 ) return areaofOverlapWith( other, K * 2 ) ; 
        // println( insideMe , "Inside other " , insideOther);
         return  float(insideBoth) / float(insideEither )  ; 
      }
      public String NF(float f, int ignore , int ingore2 )
      { 
        return String.format("%.2f", f ) ; 
      } 
      //-------------------------------------
      public float areaofOverlapWith( Isovist other  ) 
      { 
         return areaofOverlapWith(other, K1024 ) ; 
      }
     public void drawDead() 
     { 
       fill( #EA18C8 ) ; 
       ellipse( center.x, -center.y , 5,5) ; 
        
     } 
     //-------------------------------------
     public void drawFast()
     { 
       noStroke(); 
       fill( myColor ) ; 
       ellipse( center.x, -center.y , gIsoivstDotSize,gIsoivstDotSize) ; 
       stroke( 255, 16 ) ; 
      // fill( #BCB524 ) ; 
       
       //fill( #E8E6C5 ) ; text( nf(myCurrentValue , 1, 2) , center.x, -center.y ) ; 

       if(selected ) for( NodeInGraph it : connectedToWeighted.keySet() ) 
       { 
         Isovist  who = ( Isovist) it ; 
         line(who.center.x , -who.center.y, center.x , -center.y);
       } 
       
      if( selected ) drawMedium(); 
      drawLinks(); 
     }
     //------------------------------------------------------------------
     void drawLinks() 
     { 
       if( gDrawIsovistLinks ) 
       { 
         textAlign(CENTER); 
         fill(0); 
         textSize(2);
         text( NF(fOmniDepth,3,2) + "|"+NF( fDepth, 3,2) + "|"+this.depth , center.x , -center.y); 
         stroke(64,64,64,64); 
         fill( myColor ) ; 
         
        for( Isovist  who : connections ) 
         { 
           line(who.center.x , -who.center.y, center.x , -center.y);
           if( gshowWeights) 
           { 
               float w =   connectedToWeighted.get( who  ) ; 
               float sym  = omniDirectionToWeightedEdges.get(who); 
               float posX = lerp( center.x ,who.center.x , 0.25);
               float posY = lerp( center.y , who.center.y , 0.25 ) ; 
               
               text(  NF(sym,1,3) +"_"+ NF(w,1,3)   , posX, -posY );
               
           } 
         }
       } 
     } 
     //------------------------------------
     public void drawMedium()
     { 
       //noFill(); 
       noStroke(); 
       fill( myColor ) ; 
       ellipse( center.x, -center.y , gIsoivstDotSize,gIsoivstDotSize) ; 
       strokeWeight(0.1);
       stroke( 0 ) ;
       
       //stroke( #BC24A3 , 22 ) ; 
       fill(  myColor , 32 ) ; 
       
      // fill( myColor ) ; 
       PVector last = rays.get( rays.size()-1);
       beginShape();

       for(PVector r : rays ) 
       { 
         vertex( r.x, -r.y );
        // line( r.x, -r.y , last.x, -last.y);
        // last = r ; 
       }
       endShape();
       drawLinks(); 
       //text(""+ rays.size(), center.x, -center.y );
     } 
      //-------------------------------------
     public void drawSlow()
     { 
       strokeWeight(1); 
       stroke( 128 , 0,128); 
       /*line( minH, -minV , minH, -maxV); 
       line( minH, -maxV , maxH, -maxV ); 
       line( maxH, -maxV ,  maxH, -minV  ); 
       line( maxH, -minV, minH, -minV  ); 
       */
       strokeWeight( 0.1 ) ; 
       stroke( 128,0,0);
       
       
      // println(connections.size())
   // draw all connections 
       drawLinks() ; // 
 
  // draw all rays  
       stroke( 0,0,255);
      if( rays!=null)
      { 
       for(PVector r : rays ) 
       { 
        // println(center.x, center.y , r.x, r.y );
         line( center.x, -center.y , r.x, -r.y ) ; 
       } 
      }else println("Rays null");
       
       strokeWeight( 1 ) ; 
       stroke( 255,0,0);
      /* line( minH,-minV, minH , -maxV ) ; 
       line( minH , -maxV ,maxH, -maxV ) ; 
       line( maxH, -maxV , maxH , -minV) ;
       line( maxH , -minV,minH,-minV ) ;*/ 
       
      if( false ) 
      { 
        PVector px =  makeRandomPointInside() ; 
        ellipse( px.x, -px.y  , 1, 1);
      }
           
       strokeWeight( 0.5 ) ;  
       if(connections.size()>0 )
        { 
          println("many connections");
          return ; 
        } 
        
       if( outline == null )
       { 
         println("NO outline");
         return ; 
       } 
       noFill(); 
       PathIterator pi = outline.getPathIterator(null);
        float[] pts = new float[2];
        while (!pi.isDone()) 
        {
          int type = pi.currentSegment(pts);
          if (type == PathIterator.SEG_MOVETO)
          {
            beginShape();
            vertex(pts[0],-pts[1]);
          }
          if (type == PathIterator.SEG_LINETO)
          { // LINETO
            vertex(pts[0],-pts[1]);
            //println(pts[0]+","+pts[1]);
          }
          if (type == PathIterator.SEG_CLOSE) 
          {
            endShape();
          }
          pi.next();
        }
        fill( #E51E9D );
        noStroke();  
        ellipse( center.x, -center.y  , gIsoivstDotSize, gIsoivstDotSize);      
     } 
     ///---------------------------------------------------------------------------
     public void  trimRaysToThisLine( float lastX, float lastY, float pts0,float  pts1)
     { 
       boolean cliped = trimRaysToLine(  lastX,  lastY,  pts0,  pts1, this.rays,  this.center);
       //if(cliped)  - check later.
      makeOutlineFromRays() ;
     } // end of function trimRaysToLine
     ///---------------------------------------------------------------------------
     boolean makeOutlineFromRays( ) 
     { 
       outline = new GeneralPath(); 
       boolean startPoly = true ; 
        minH =  Integer.MAX_VALUE ;
        maxH = -Integer.MAX_VALUE ;
        minV = Integer.MAX_VALUE; 
        maxV = -Integer.MAX_VALUE ; 
         
        for( PVector r: rays ) 
         { 
           if( startPoly == true ) 
           { 
               outline.moveTo((float) r.x, (float) -r.y); 
               startPoly = false; 
           } else 
           { 
              outline.lineTo((float) r.x, (float) -r.y); 
           } 
           minH = min( minH , r.x ) ; 
           maxH = max( maxH , r.x ) ;
           minV = min( minV , r.y ) ; 
           maxV = max( maxV , r.y ) ; 
         } 
         outline.closePath(); 
         
         assert  minH != Integer.MAX_VALUE; 
         assert  maxH != -Integer.MAX_VALUE; 
         assert  minV != Integer.MAX_VALUE;
         assert  maxV != -Integer.MAX_VALUE;
         if(  minV == maxV ||  minH == maxH  )
         { 
           badIsovists.add( this)  ;
           return false ; 
         } 
         assert  minV != maxV  : "No width "+minV   ; 
         assert  minH != maxH  : "No height "+maxH  ; 
          
         assert  validMinMax() ==true: "min max wrong #101"; 
         return true ; 
         
     } 
      //-----------------------------------------------------------
     public void initRays( float radius )
     { 
       assert  center != null ;
       if( this.rays == null || rays.size() != K360 )
       { 
           this.rays = new ArrayList<PVector>(K360 );
          for( int i  = 0 ; i < K360 ; i++) { rays.add( PVector.random2D()); } 
       } 
       generateRayForCenter( this.rays , center, radius );
       makeOutlineFromRays(); 
       assert  validMinMax() ==true: "min max wrong"; 
       
       assert minH != Integer.MAX_VALUE  :" minH != Integer.MAX_VALUE"  ;
     }
     
     public void initRays( )
     { 
       this.initRays( myInfinity) ;
     } 
     public void re_init_rays( PVector newcenter ,  float radius ) 
     { 
       assert newcenter!= null; 
       
       this.center = newcenter; 
       initRays( radius ) ; 
     }
     //-----------------------------------------------------------
     public boolean computIsovist( java.util.List<GeneralPath> shapes ) 
     { 
        minH = Integer.MAX_VALUE ;
        maxH = -Integer.MAX_VALUE ;
        minV = Integer.MAX_VALUE; 
        maxV = -Integer.MAX_VALUE ; 
       
       initRays(); 
       for( GeneralPath p: shapes) trimRaysToShape( this.rays, p , this.center);
       
       assert validMinMax() == true : "mim max for me not set shapes = " + shapes.size() ;
       boolean OK =  makeOutlineFromRays( ) ; 
       //assert validMinMax() == true : "2 mim max for me not set shapes = " + shapes.size() ;
       return OK;
     } 
     //-----------------------------------------------------------
     void setKMeansCluster( int which ) { kMeansCluster = which ; } 
     int  getKMeansCluster( ) { return kMeansCluster ; } 
     void computeBestCluster() 
     { 
         assert false ; 
     }
    //-----------------------------------------------------------
    boolean isPointInOutline( float px , float py ) 
    { 
      return outline.contains(px, py) ; 
    }
    //-----------------------------------------------------------
    boolean checkInsideBoundingBox( float px, float py )
    {
      return ( (px >= minH) && (px <= maxH) && (py >= minV) &&(py <= maxV) ) ; 
    } 
    //-----------------------------------------------------------
    /* 
      testPointInside is the fastest but it relighs on the 
    
    */ 
    boolean isPointInsideIsovist( float px, float py ) 
    { 
      assert this.validMinMax()==true;
     if(checkInsideBoundingBox(px,py) == false)
     { 
      // assert outline.contains( px , -py ) == false; 
       return false;
     }
     // outline.contains is 3 times faster. 
    /* long startTime = System.nanoTime();
      boolean gold  =  checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW(px,py);
      long endTime = System.nanoTime();
      
      float hoz = maxH - minH ; 
      float vert = maxV -minV  ; 
     
      long startTime2 = System.nanoTime();
       assert gold ==  outline.contains( px , -py ):
         ("Check + " +px+ " " + py + " " + gold + " ol =" + outline.contains( px , py ) + 
         " " + outline.getBounds()  + " \n{ x=" +  minH + " y="+minV+" w "+ hoz + " high "+ vert   ); 
       long endTime2 = System.nanoTime();
       
       long startTime3 = System.nanoTime();
      /* if( gold != testPointInside( px, py) )///testPointInside(px,py) ) 
       { 
         fill( #D6A009) ; 
         stroke( 255,0,0);
         
         circle( px, -py , 2); 
         line(px,-py, convertWindowToMapCoordX(mouseX),  convertWindowToMapCoordY(mouseY));
         frameRate(0);
         println("bad");
         println( "Check + " +px+ " " + py + " gold= " + gold + " TRI =" +  this.testPointInside( px , py ) + 
         " \n d  =  " + dist(px,py,center.x, center.y) +" hoz= "+ hoz + " high= "+ vert  + " " + 
         dist(px,0,center.x, 0)  + " "  + dist(0,py,0, center.y) +" seg="+ getSegmentFor(px,py) );
       } */ 
       /*assert gold == testPointInside(px,py):
         ("Check + " +px+ " " + py + " gold= " + gold + " TRI =" +  this.testPointInside( px , py ) + 
         " \n d  =  " + dist(px,py,center.x, center.y) +" hoz= "+ hoz + " high= "+ vert  + " " + 
         dist(px,0,center.x, 0)  + " "  + dist(0,py,0, center.y) ); 
       long endTime3 = System.nanoTime();
       
       println( endTime-startTime, endTime2-startTime2, endTime3-startTime3); 
       */ 
      
       //assert this.validMinMax()==true;
       
      /* assert testPointInside( px , py ) == checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW( px , py ):
               "Distrubing 7 " + px + " " + (py) + " " + testPointInside( px , py )
               + " " +checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW(px, py) ; */
               
      // OLDSET return outline.contains( px , -py );
      return testPointInside(px,py); 
     }
      //-------------------------------------------------------------
     boolean debugtestPointInside( float px , float py ) 
     { 
      
      if( true)
      { stroke( #0C84EA ) ;
       noFill();
       circle( px, -py , 5 ) ; 
      } 
       // line( lerp( center.x, px, .75) , lerp( -center.y, -py , 0.75)  ,   px, -py);

        
        if ( testPointInside( px , py ) )
         { 
          if( ! checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW( px, py) )
          { 
             println(" Disagreed TRUE, FALSE " + millis() ); 
             stroke( 255,0,0);
          } 
          else 
          stroke( #0FB938 ) ;
         } else 
         { 
           if( checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW( px, py) )
           { 
              println(millis() + "Disagreed 2  FALSE/TRUE not in checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW" + + millis() ); 
           stroke( 255,0,0);
           } 
           else 
            stroke( #0C84EA ) ;
         } 
          
          final int K = K360; 
          float angle = atan2( py - center.y, px- center.x ) ;
          int  it  = (int)map(angle,  -PI , PI,0,K);
          int T2 =  ((it+2)+(K/2)) % K; 
          int T1 =  ((it+1)+(K/2) ) % K ; 
          int T0 =  ((it)+(K/2) ) % K;
         
           PVector P2 = rays.get( T2 ) ; 
           PVector P1 = rays.get( T1) ; 
           PVector P0 = rays.get( T0) ;
         
          line( center.x, -center.y,  P2.x, -P2.y);
          line( center.x, -center.y,  P1.x, -P1.y);
          line( center.x, -center.y,  P0.x, -P0.y);
         
        
    
        return testPointInside(px,py) ; 
     } 
     int getSegmentFor( float px , float py) 
     { 
       final int K = K360; 
        float angle = atan2( py - center.y, px- center.x ) ;
        int  it  = (int)map(angle,  -PI , PI,0,K);
        return  it ; 
     } 
    //-------------------------------------------------------------
    /* 
     * special version which relies on the structure of the isovist as radial 
    */ 
     boolean testPointInside( float px , float py ) 
     { 
      final int K = K360; 
        //if( dist(px, py, center.x, center.y ) <0.001) return true; 
        
        float angle = atan2( py - center.y, px- center.x ) ;
        int  it  = (int)map(angle,  -PI , PI,0,K);
        int T3 =  ((it+3)+(K/2)) % K;
        int T2 =  ((it+2)+(K/2)) % K; 
        int T1 =  ((it+1)+(K/2) ) % K ; 
        int T0 =  ((it)+(K/2) ) % K;
        int T_1 =  ((it-1)+(K/2) ) % K;
       
         PVector P3 = rays.get( T3 ) ;
         PVector P2 = rays.get( T2 ) ; 
         PVector P1 = rays.get( T1) ; 
         PVector P0 = rays.get( T0) ;
         PVector P_1 = rays.get( T_1) ;
        
        boolean t3 = insideTriangle(px,py ,
             center.x,  center.y ,  P3.x, P3.y , P2.x, P2.y) ;
         boolean t1 = insideTriangle(px,py ,
             center.x,  center.y , P2.x, P2.y, P1.x, P1.y ) ;
         boolean t2 = insideTriangle(px,py ,
             center.x,  center.y , P1.x, P1.y, P0.x , P0.y ) ;
         boolean t4 = insideTriangle(px,py ,
             center.x,  center.y , P0.x , P0.y , P_1.x, P_1.y ) ;
         return  t1 || t2 || t3 || t4; 
     } 
     
     //-------------------------------------------------------------
     boolean checkPointIsInsideBodyAssumeBoundingBoxTestOK_SLOW(float px, float py )
     { 
       gCheckRay1 = null ; 
      // debug 
      lastHitPoint = new PVector( px , py )  ; 
      boolean isInside = false; 
      if( rays==null)  {  println("Rays null"); return isInside; } 
      assert rays.size() > 0 ; //must have 2... 
      PVector lastRay =  rays.get(  rays.size() - 1 ); // last but one 
      
      for( PVector r  : rays ) 
      { 
        boolean inside =  insideTriangle( px, py , center.x, center.y, 
                                          r.x , r.y , lastRay.x , lastRay.y ); 
        if( inside ) 
        { 
          isInside = true ;
        // debug  
         if( true ) 
         { 
            gCheckRay1 = r ; 
            gCheckRay2 = lastRay;
            gCheckRay3 = center; 
          } 
          // main code. 
          //assert checkInsideBoundingBox( px , py )== true ; 
          return true ;  
        }
        lastRay = r ; 
       } // end of loop 
       return false ; 
       
     } 
     ///-------------------------------
     boolean checkPointIsInsideBodyAssumeBoundingBoxTestOK_FAST(final float px, final float py )
     { 
       gCheckRay1 = null ; 
      // debug 
      lastHitPoint = new PVector( px , py )  ; 
      boolean isInside = false; 
      if( rays==null)  {  println("Rays null"); return isInside; } 
      assert rays.size() > 0 ; //must have 2... 
      PVector lastRay =  rays.get(  rays.size() - 1 ); // last but one 
      
      return false ; 
      /*
      use int stream / range to intterate over numbers 0 to rays.size()-1 m
      then get the item from the array. 
       Or reverse the angle to get the ray index. 
       check eiter size....
      */
      /*boolean allPass = rays.parallelStream().allMatch(item ->
       return  insideTriangle( px, py , center.x, center.y, 
                                          r.x , r.y , lastRay.x , lastRay.y )
      */  
      /*
      for( PVector r  : rays ) 
      { 
        boolean inside =  insideTriangle( px, py , center.x, center.y, 
                                          r.x , r.y , lastRay.x , lastRay.y ); 
        if( inside ) 
        { 
          isInside = true ;
        // debug  
         if( true ) 
         { 
            gCheckRay1 = r ; 
            gCheckRay2 = lastRay;
            gCheckRay3 = center; 
          } 
          // main code. 
          //assert checkInsideBoundingBox( px , py )== true ; 
          return true ;  
        }
        lastRay = r ; 
       } // end of loop 
       return false ; 
       */
       
     } 
     
     
 } // end of isovist 
 
 /*
 public class ParallelStreamConsecutivePairsExample {
    public static void main(String[] args) {
        // Example ArrayList
        List<Integer> arrayList = new ArrayList<>();
        arrayList.add(1);
        arrayList.add(2);
        arrayList.add(3);
        arrayList.add(4);
        arrayList.add(5);

        // Create parallel stream of consecutive pairs
        zipWithNext(arrayList.parallelStream())
                .forEach(pair -> {
                    // Replace this with the code you want to execute in parallel for each pair
                    System.out.println("Pair: " + pair);
                });
    }

    // Method to zip a stream with the next element
    public static <T> Stream<Pair<T>> zipWithNext(Stream<T> stream) {
        List<T> list = stream.toList();
        return IntStream.range(0, list.size() - 1)
                .parallel()
                .mapToObj(i -> new Pair<>(list.get(i), list.get(i + 1)));
    }
}

// Class to represent a pair of items
class Pair<T> {
    private final T first;
    private final T second;

    public Pair(T first, T second) {
        this.first = first;
        this.second = second;
    }

    @Override
    public String toString() {
        return "(" + first + ", " + second + ")";
    }
}
*/ 

 //=====================================================================
 PVector lastHitPoint = null ; 
 PVector gCheckRay1 = null ,gCheckRay2 = null , gCheckRay3 = null ; 
 ArrayList<PVector> gCheckInersectionMe=null; //  = new ArrayList<PVector>( ) ; 
 ArrayList<PVector> gCheckIntersectOther=null; //  = new ArrayList<PVector>( ) ; 
 
