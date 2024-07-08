//----------------------------------------------------------------------
class  NodeInGraph
{ 
  public 
    String label = null ; 
    float fDepth = Float.POSITIVE_INFINITY;
    
    float totalfDepth ;
    
    float fOmniDepth = Float.POSITIVE_INFINITY;
    float fTotalOmniDepth = Float.POSITIVE_INFINITY;
    boolean selected = false ;
    float   normalisedJaccabianDepth ; 
     
    protected Map<NodeInGraph,Float> connectedToWeighted;
    protected Map<NodeInGraph,Float> omniDirectionToWeightedEdges; 
    
    NodeInGraph() 
    { 
        this("");
    }
    //-----------------------
    NodeInGraph(String name) 
    { 
      label = name; 
      totalfDepth = 0f ;
      fOmniDepth = 0f; 
      fTotalOmniDepth = 0f ;
      normalisedJaccabianDepth = 0f; 
      
      connectedToWeighted = new HashMap<NodeInGraph,Float>() ;
      omniDirectionToWeightedEdges = new HashMap<NodeInGraph,Float>() ;
    }
    //-----------------------
    public void reset()
    { 
      connectedToWeighted = new HashMap<NodeInGraph,Float>() ; 
      omniDirectionToWeightedEdges = new HashMap<NodeInGraph,Float>() ;
    } 
    //---------------------------------------------------
    @Override 
    String toString()
    { 
      return label 
              + "{" +fDepth +","+ fOmniDepth 
           // + " " + connectedToWeighted.size()
            +"}"
            ; 
    }
    //---------------------------------------------------
    void connect( NodeInGraph g, float weight  ) 
    { 
      connectedToWeighted.put( g, weight ) ; 
    }
    //---------------------------------------------------
    void connectOmniDiretional( NodeInGraph g, float weight  ) 
    { 
      assert !Float.isNaN(weight): "Nan for weight onnection";
      omniDirectionToWeightedEdges.put( g , weight ) ; 
    } 
    //---------------------------------------------------
    void updateFromNode(  Set<NodeInGraph> consideration)
    { 
      assert consideration != null; 
      for( NodeInGraph it: this.connectedToWeighted.keySet()) 
       { 
           float addedDepth = this.connectedToWeighted.get(it); 
           if( (this.fDepth + addedDepth) <  it.fDepth ) 
           { 
              it.fDepth = this.fDepth + addedDepth;
              consideration.add( it ) ; 
           } 
       } 
    } 
    //---------------------------------------------------
    void updateFromNodeOmni(  Set<NodeInGraph> consideration)
    { 
      for( NodeInGraph it: this.omniDirectionToWeightedEdges.keySet()) 
       { 
           float addedDepth = this.omniDirectionToWeightedEdges.get(it); 
           if( (this.fDepth + addedDepth) <  it.fDepth ) 
           { 
              it.fDepth = this.fDepth + addedDepth;
              consideration.add( it ) ; 
           } 
       } 
    } 
    //---------------------------------------------------
} 
