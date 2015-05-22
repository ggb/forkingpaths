defmodule ForkingPaths.Cooccurrance do
  alias ForkingPaths.GraphNode
  require Logger

  defp add_to_graph(graph, node, incoming, outgoing) do
  	if Dict.has_key?(graph, node) do
  	  old_node = Dict.get(graph, node)
  	  new_node = %GraphNode{ identifier: node, prefLabel: node, 
  	  	related: Enum.uniq(outgoing ++ old_node.related), 
  	  	incoming: Enum.uniq(incoming ++ old_node.incoming) }
  	  Dict.update!(graph, node, new_node)
  	else
  	  new_node = %GraphNode{ identifier: node, prefLabel: node, related: outgoing, incoming: incoming }
  	  Dict.put_new(graph, node, new_node)
  	end
  end

  defp create_graph(n, graph, before, current, []) do
  	add_to_graph(graph, current, Enum.take(before, n), [])
  end
  
  defp create_graph(n, graph, before, current, [ next | rest ] = behind) do
    updated_graph = add_to_graph(graph, current, Enum.take(before, n), Enum.take(behind, n))
  	create_graph(n, updated_graph, [ current | before ], next, rest)
  end

  def get(n, [ head | tail]) do
    create_graph(n, HashDict.new, [], head, tail)
  end

end