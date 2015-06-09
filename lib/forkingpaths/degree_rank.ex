defmodule ForkingPaths.DegreeRank do
  alias ForkingPaths.Helper

  def degree_rank(concepts) do
    Enum.map(concepts, fn { ident, hNode } ->
      { ident, length(hNode.incoming) + length(hNode.outgoing) }
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
