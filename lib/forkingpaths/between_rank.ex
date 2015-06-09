defmodule ForkingPaths.BetweennessRank do
  alias ForkingPaths.Helper

  defp create_pairs(vertices) do
    # that is maybe not the most elegant solution...
    vertices
    |> Enum.map(fn e -> Enum.map(vertices, fn i -> {e, i} end) end) 
    |> List.flatten 
    |> Enum.filter(fn {a, b} -> a != b end)
  end

  defp calculate_shortest_paths(list_of_pairs, graph) do
    list_of_pairs
    |> Enum.reduce(HashDict.new, fn { fst, scd }, acc ->
      # returns false or the shortest path
      Dict.put(acc, { fst, scd }, :digraph.get_short_path(graph, fst, scd))
    end)
  end

  def calculate_rank(pairs_and_paths, vertices) do
    path_count = Enum.count(pairs_and_paths, fn { _key, val } ->
      val != false
    end)

    Enum.map(vertices, fn vertex ->
      val = Enum.reduce(pairs_and_paths, 0, fn { { fst, scd }, path }, acc ->
        if vertex != fst and vertex != scd and Enum.member?(path, vertex) do
          acc + 1
        else
          acc
        end
      end)
      { vertex, val / path_count }
    end)
  end

  def between_rank(graph) do
    vertices = :digraph.vertices(graph)
    
    vertices
    |> create_pairs
    |> calculate_shortest_paths(graph)
    |> calculate_rank(vertices)
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
