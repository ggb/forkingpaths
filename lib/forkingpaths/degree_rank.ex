defmodule ForkingPaths.DegreeRank do
  alias ForkingPaths.Helper

  def degree_rank(concepts) do
    Enum.map(concepts, fn { ident, hNode } ->
      { ident, length(hNode.incoming) + length(hNode.outgoing) }
    end)  
  end

  defp normalize_ranks(ranked_concepts) do
    { _ident, max_val } = Enum.max_by(ranked_concepts, fn { _ident, val } ->
      val
    end)
    
    Enum.map(ranked_concepts, fn { ident, val } ->
      { ident, val / max_val }
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
