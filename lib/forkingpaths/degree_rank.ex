defmodule ForkingPaths.DegreeRank do
  alias ForkingPaths.TreeOperations

  def degree_rank(concepts) do
    Enum.map(concepts, fn { ident, hNode } ->
      { ident, length(hNode.incoming) + length(hNode.related) }
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
  def run(concepts) do
    TreeOperations.get_cooccurance_graph(concepts)
    |> TreeOperations.add_incoming_nodes
    |> degree_rank
    |> normalize_ranks
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end
  

end
