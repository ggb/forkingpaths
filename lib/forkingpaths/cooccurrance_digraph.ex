defmodule ForkingPaths.Cooccurrance2 do

  defp add_to_graph(graph, gNode, incoming, outgoing) do
  	# add vertex if not available
  	if :digraph.vertex(graph, gNode) == false do
      :digraph.add_vertex(graph, gNode)
  	end
  	
  	# add edges
  	Enum.each(incoming ++ outgoing, fn ele ->
  	  :digraph.add_edge(graph, gNode, ele)
  	end)
  end

  defp create_graph(n, graph, before, current, []) do
  	add_to_graph(graph, current, Enum.take(before, n), [])
  end
  
  defp create_graph(n, graph, before, current, [ next | rest ] = behind) do
    # update graph
    add_to_graph(graph, current, Enum.take(before, n), Enum.take(behind, n))
    # next nodes
  	create_graph(n, graph, [ current | before ], next, rest)
  end

  def get(n, [ head | tail]) do
    graph = :digraph.new
    create_graph(n, graph, [], head, tail)
    
    graph
  end

end
