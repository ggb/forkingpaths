defmodule ForkingPaths.Cooccurrance do
  alias ForkingPaths.GraphNode
  require Logger

#  defp relation_update_without_reflection(gNode, old, new) do
#  	# TODO: wie heißt die Funktion wirklich?
#  	relation_update(old, new) |> Enum.with_out(gNode)
#  end

  defp relation_update(old, new) do
  	Enum.uniq(old ++ new)
  end

  defp add_to_graph(graph, gNode, incoming, outgoing) do
  	if Dict.has_key?(graph, gNode) do
  	  old_node = Dict.get(graph, gNode)
  	  new_node = %GraphNode{ identifier: gNode, prefLabel: gNode, 
  	  	outgoing: relation_update(outgoing, old_node.outgoing), 
  	  	incoming: relation_update(incoming, old_node.incoming) }
  	  Dict.put(graph, gNode, new_node)
  	else
  	  new_node = %GraphNode{ identifier: gNode, prefLabel: gNode, outgoing: outgoing, incoming: incoming }
  	  Dict.put_new(graph, gNode, new_node)
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