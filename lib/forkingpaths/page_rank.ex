defmodule ForkingPaths.PageRank do
  alias ForkingPaths.Helper
  require Logger

  @moduledoc """
  """

  @damping_factor 0.85
  @iteration_count 35
  
  # iterates over the graph and calculates a new value for each node
  defp concept_rank_graph_iteration(graph, 0), do: graph
  defp concept_rank_graph_iteration(graph, iteration_num) do
    new_graph = Enum.map(graph, fn { ident, hnode } -> 
      pre_sum = Enum.reduce(hnode.incoming, 0, fn preident, acc ->
        prenode = Dict.get(graph, preident)
        acc + prenode.value / length(prenode.outgoing) # length(prenode.broader ++ prenode.narrower ++ prenode.related)
      end)
      # the calculation follows Mihalcau and Tarau, 2004
      { ident, %{ hnode | value: ( 1 - @damping_factor ) + @damping_factor * pre_sum } }
    end) |> Enum.into(HashDict.new)
    
    concept_rank_graph_iteration(new_graph, iteration_num - 1)
  end

  @doc """
  Calculates the PageRank on a SKOS-concept graph.
  """
  def concept_rank(hierarchy) do
    # add 1.0 to each node value, so that its value is at least 1.0
    updated_hierarchy = Enum.map(hierarchy, fn { ident, hnode } -> 
      { ident, %{ hnode | value: hnode.value + 1.0 } }
    end)
    
    # calculate the maximum value in the hierarchy
    { _ident, max_val_node } = Enum.max_by(updated_hierarchy, fn { _ident, hnode } -> 
      hnode.value
    end)
    norm = max_val_node.value
    
    # update all values by dividing each value by the max value
    # so that afterwards the value is between 0 and 1.0
    updated_norm_hierarchy = Enum.map(hierarchy, fn { ident, hnode } -> 
      { ident, %{ hnode | value: hnode.value / norm } }
#      { ident, %{ hnode | value: 1.0 } }
    end)
    
    # last, transform everything back into a HashDict and call the
    # iteration function
    updated_norm_hierarchy
    |> Enum.into(HashDict.new)
    |> concept_rank_graph_iteration(@iteration_count)
  end

  @doc """
  
  """
  def run(graph) do
    graph
    # |> Helper.add_incoming_nodes
    |> concept_rank
    |> Helper.vectorize_and_normalize
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end 

end
