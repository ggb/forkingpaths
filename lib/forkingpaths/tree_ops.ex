defmodule ForkingPaths.Helper do
  alias ForkingPaths.GraphNode
  require Logger

   
  @doc """
  The graph ranking functions (PageRank and HITS) need to know, which 
  other nodes point to a specific node. The list of incoming nodes 
  is calculated in this function.
  """
  def add_incoming_nodes(hierarchy) do
    Enum.reduce(hierarchy, hierarchy, fn { _ident, hnode }, acc -> 
      nodes = hnode.broader ++ hnode.narrower ++ hnode.related
      Enum.reduce(nodes, acc, fn outgoing, inner_acc ->
        Dict.update(inner_acc, outgoing, %GraphNode{ identifier: outgoing, incoming: [ hnode.identifier ] }, fn val -> %{ val | incoming: [ hnode.identifier | val.incoming ] } end)
      end)
    end)
  end
  
  @doc """
  Transforms the graph into a vector, i. e. a list of tuples:
    [{'descriptor/15176-2', 0.31}, {'descriptor/19653-2', 0.305},
     {'descriptor/15786-3', 0.27}, ...
    ]
  """
  def vectorize(graph) do
    Enum.map(graph, fn {ident, graph_node} -> { ident, graph_node.value } end)
  end
  
  @doc """
  Transform a graph into a vector and apply L2 normalization.
  """
  def vectorize_and_normalize(graph) do
    vect = vectorize(graph)
    
    norm = Enum.reduce(vect, 0, fn { _identifier, val }, acc -> 
      val * val + acc
    end) |> :math.sqrt

    Enum.map(vect, fn { identifier, val } ->
      { identifier, val / norm }
    end)
  end
  
  
end
