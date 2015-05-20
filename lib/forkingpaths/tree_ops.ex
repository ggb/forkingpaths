defmodule ForkingPaths.TreeOperations do
  alias ForkingPaths.HierarchyNode
  require Logger

   
  @doc """
  The graph ranking functions (PageRank and HITS) need to know, which 
  other nodes point to a specific node. The list of incoming nodes 
  is calculated in this function.
  """
  def add_incoming_nodes(hierarchy) do
    Enum.reduce(hierarchy, hierarchy, fn { _ident, hnode }, acc -> 
      nodes = hnode.broader ++ hnode.narrower ++ hnode.related
      Enum.reduce(nodes, acc, fn outgoing, inner_acc ->
        Dict.update(inner_acc, outgoing, %HierarchyNode{ identifier: outgoing, incoming: [ hnode.identifier ] }, fn val -> %{ val | incoming: [ hnode.identifier | val.incoming ] } end)
      end)
    end)
  end

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

  defp transform_to_hierarchynodes(nodes) do
    Enum.map(nodes, fn { key, val } ->
      hNode = %HierarchyNode{ identifier: key, prefLabel: key, related: Set.to_list(val) }
      { key, hNode }
    end) 
    |> Enum.into(HashDict.new)
  end

  def get_cooccurance_graph(list) do
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
    |> transform_to_hierarchynodes
  end

  @doc """
  Write a list of tuples into an empty hierarchy. 
  """
  def list_to_hierarchy(list, hierarchy) when is_list(list) do
    Enum.reduce(list, hierarchy, fn { ident, new_val }, acc -> 
      Dict.update(acc, ident, %HierarchyNode{ identifier: ident, value: new_val }, fn val -> %{ val | value: new_val } end)
    end)
  end
  
  def list_to_hierarchy(list, hierarchy) do
    Enum.to_list(list) |> list_to_hierarchy(hierarchy)
  end 
  
  @doc """
  Returns the top level concepts.
  """
  def broadest_nodes(dict) do
    Enum.filter(dict, fn { _key, val } -> val.broader == [] end)
  end
  
  @doc """
  Returns the top level concepts for stw thesaurus.
  (Some special filtering is necessary.)
  """
  def broadest_nodes(dict, :stw) do
    broadest_nodes(dict) |> Enum.filter(fn { key, _val } -> String.starts_with?(to_string(key), "thsys") end)
  end
  
  @doc """
  Returns the lowest/narrowest hierarchy nodes.
  """
  def narrowest_nodes(dict) do
    Enum.filter(dict, fn { _key, val } -> val.narrower == [] end)
  end
  
  @doc """
  Transforms the hierarchy into a vector, i. e. a list of tuples:
    [{'descriptor/15176-2', 0.31}, {'descriptor/19653-2', 0.305},
     {'descriptor/15786-3', 0.27}, ...
    ]
  """
  def vectorize(hierarchy) do
    Enum.map(hierarchy, fn {ident, hierarchy_node} -> { ident, hierarchy_node.value } end)
  end
  
  def vectorize_and_normalize(hierarchy) do
    vect = vectorize(hierarchy)
    
    norm = Enum.reduce(vect, 0, fn { _identifier, val }, acc -> 
      val * val + acc
    end) |> :math.sqrt

    Enum.map(vect, fn { identifier, val } ->
      { identifier, val / norm }
    end)
  end
  
  @doc """
  Calculates the height of a node; the function therefore follows all branches to the leafs and returns the longest path.
  """
  def calculate_height(node_id, dict, height) do
    %HierarchyNode{ narrower: children } = Dict.get(dict, node_id)
    
    if children == [] do
      height
    else
      Enum.map(children, fn ele -> 
        calculate_height(ele, dict, height + 1)
      end) |> Enum.max
    end
  end
  
  @doc """
  Calculates the depth of a node; the function therefore follows all branches to the roots and returns the longest path.
  """
  def calculate_depth(node_id, dict, depth) do
    %HierarchyNode{ broader: ancestors } = Dict.get(dict, node_id)
    
    if ancestors == [] do
      depth
    else
      Enum.map(ancestors, fn ele -> 
        calculate_height(ele, dict, depth + 1)
      end) |> Enum.max
    end
  end
  
  @doc """
  Calculates how many nodes are on one level.
  """
  def calculate_breadth(node_id, dict, 0) do
    %HierarchyNode{ narrower: children } = Dict.get(dict, node_id)
    length(children)
  end
  
  def calculate_breadth(node_id, dict, height) do
    %HierarchyNode{ narrower: children } = Dict.get(dict, node_id)
    
    if children == [] do
      0
    else
      Enum.reduce(children, 0, fn ele, acc -> acc + calculate_breadth(ele, dict, height - 1)  end)
    end    
  end

end
