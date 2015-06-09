defmodule ForkingPaths.BetweennessRank do
  alias ForkingPaths.Helper

  def between_rank(graph) do
    vertices = :digraph.vertices(graph)
    
  end

  def get(graph) do
    graph
    |> between_rank
    |> Helper.normalize
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end

end
