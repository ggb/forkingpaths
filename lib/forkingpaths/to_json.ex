defmodule ForkingPaths.JSON do

  defp create_node_list(_value_map, [], result), do: result

  defp create_node_list(value_map, [ { name, descriptor } = vertex | rest ], result) do
  	current = %{ 
  		"name" => name, 
  		"descriptor" => descriptor, 
  		"value" => Map.get(value_map, vertex) 
  	}
  	create_node_list(value_map, rest, [ current | result ])
  end

  defp create_node_list(value_map, [ vertex | rest ], result) do
	current = %{ 
  		"name" => vertex, 
  		"value" => Map.get(value_map, vertex) 
  	}
  	create_node_list(value_map, rest, [ current | result ])
  end

  defp vertices_with_indizes(vertices) do
  	len = Enum.count(vertices)
  	Enum.zip(vertices, 0..len-1)
  	|> Enum.into(Map.new)
  end

  def create_link_list(_with_indizes, [], _graph, result), do: result

  def create_link_list(with_indizes, [ vertex | rest ], graph, result) do
  	current = Map.get(with_indizes, vertex)
  	edges = :digraph.out_neighbours(graph, vertex) ++ :digraph.in_neighbours(graph, vertex)
  	|> Enum.map(fn neighbour -> 
  	  %{ "source" => current, "target" => Map.get(with_indizes, neighbour), "value" => 1 }
  	end)

  	create_link_list(with_indizes, rest, graph, edges ++ result)
  end


  def get(values, graph) do
  	vertices = :digraph.vertices(graph)
  	value_map = Enum.into(values, Map.new)

  	# create a list of nodes
  	node_list = create_node_list(value_map, vertices, [])

  	# create a list of links
  	with_indizes = vertices_with_indizes(vertices)
  	link_list = create_link_list(with_indizes, vertices, graph, [])

  	case JSX.encode(%{ "nodes" => node_list, "links" => link_list }) do
  	  { :ok, json } -> json
  	  { :error, reason } -> IO.inspect reason
  	end
  end

end
