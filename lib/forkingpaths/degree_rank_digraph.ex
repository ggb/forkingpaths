defmodule ForkingPaths.DegreeRank2 do
  alias ForkingPaths.Helper

  def degree_rank(graph) do
    :digraph.vertices(graph)
    |> Enum.map(fn vertex ->
      { vertex, :digraph.in_degree(graph, vertex) + :digraph.out_degree(graph, vertex) }
    end)  
  end

  @doc """
  
  """
  def get(graph) do
    graph
    # |> Helper.add_incoming_nodes
    |> degree_rank
    |> Helper.normalize
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end  

end
