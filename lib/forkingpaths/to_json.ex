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
  	Enum.zip(0..len-1, vertices)
  	|> Enum.into(Map.new)
  end

  def get(values, graph) do
  	vertices = :digraph.vertices(graph)
  	value_map = Enum.into(values, Map.new)

  	node_list = create_node_list(value_map, vertices, [])
  end

end