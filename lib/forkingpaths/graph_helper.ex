defmodule ForkingPaths.Helper do
  alias ForkingPaths.GraphNode
  require Logger
  
  @doc """
  The graph ranking functions (PageRank and HITS) need to know, which 
  other nodes point to a specific node. The list of incoming nodes 
  is calculated in this function.

  Only required if naive cooccurrance is used.
  """
  def add_incoming_nodes(hierarchy) do
    Enum.reduce(hierarchy, hierarchy, fn { _ident, hnode }, acc -> 
      nodes = hnode.outgoing # hnode.broader ++ hnode.narrower ++ hnode.related
      Enum.reduce(nodes, acc, fn outgoing, inner_acc ->
        Dict.update(inner_acc, outgoing, %GraphNode{ identifier: outgoing, 
          incoming: [ hnode.identifier ] }, 
          fn val -> 
            %{ val | incoming: [ hnode.identifier | val.incoming ] } 
          end)
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
  Applies L2 normalization´.
  """
  def normalize(vector) do
    norm = Enum.reduce(vector, 0, fn { _identifier, val }, acc -> 
      val * val + acc
    end) |> :math.sqrt

    Enum.map(vector, fn { identifier, val } ->
      IO.puts "#{identifier}, #{val}, #{norm}"
      { identifier, val / norm }
    end)
  end

  @doc """
  Transform a graph into a vector and apply L2 normalization.
  """
  def vectorize_and_normalize(graph) do
    vectorize(graph) |> normalize
  end
  
  @doc """
  Merges graph1 into graph2.
  """
  def merge(graph1, graph2) do
    # create vertices
    Enum.each(:digraph.vertices(graph1), fn vertex ->
      :digraph.add_vertex(graph2, vertex)
    end)

    # create edges
    Enum.each(:digraph.edges(graph1), fn edge ->
      { _edge, v1, v2, _label } =  :digraph.edge(graph1, edge)
      :digraph.add_edge(graph2, v1, v2)
    end)

    # delete graph1 
    :digraph.delete(graph1)

    # return reference to graph2
    graph2
  end
  
end
