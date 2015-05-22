defmodule ForkingPaths.NaiveCooccurrance do
  alias ForkingPaths.GraphNode
  require Logger

  defp create_cooccurance_graph([ ], dict), do: dict
  defp create_cooccurance_graph(list, dict) when length(list) == 1 do
    dict
  end
  
  defp create_cooccurance_graph([ first_node | rest ], dict) do
    [ second_node | _restrest ] = rest
    
    if first_node == second_node do
      # don't add self-reflexiv nodes
      updated_dict = dict
    else 
      if Dict.has_key?(dict, first_node) do
        updated_dict = Dict.update(dict, first_node, HashSet.new, fn set -> Set.put(set, second_node) end)
      else 
        new_set = HashSet.new |> Set.put(second_node)
        updated_dict = Dict.put_new(dict, first_node, new_set)
      end
    end
    
    create_cooccurance_graph(rest, updated_dict)
  end

  defp transform_to_graph_nodes(nodes) do
    Enum.map(nodes, fn { key, val } ->
      hNode = %GraphNode{ identifier: key, prefLabel: key, related: Set.to_list(val) }
      { key, hNode }
    end) 
    |> Enum.into(HashDict.new)
  end


  @doc """
  Public interface.
  """
  def get_graph(list) do
    list
    |> Enum.map(fn ele ->
      case ele do
        [ _syn, ident ] ->
          ident
        term ->
          term
      end 
    end)
    |> create_cooccurance_graph(HashDict.new)
    |> transform_to_graph_nodes
  end

end