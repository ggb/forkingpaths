defmodule ForkingPaths.ClosenessRank do
  alias ForkingPaths.Helper

  def closeness_rank(graph) do
    vertices = :digraph.vertices(graph)
    
    vertices
    |> Enum.map(fn vertex ->
      val = Enum.reduce(vertices, 0, fn ele, acc ->
        case :digraph.get_short_path(graph, vertex, ele) do
          false         -> acc
          vertices_list -> acc + length(vertices_list)
        end
      end)
      
      if val == 0 do
        { vertex, 0 }
      else
        { vertex, 1 / val }
      end
    end)
  end

  def get(graph) do
    graph
    |> closeness_rank
    |> Helper.normalize
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end

end
