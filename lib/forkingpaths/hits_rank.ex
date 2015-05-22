defmodule ForkingPaths.HitsRank do
  alias ForkingPaths.Helper

  @moduledoc """
  
  
  """

  @iteration_count 40

  # updates for each concept it's authority value  
  defp update_auth(concept_vals, hierarchy) do
    # go through all nodes...
    auth_updated = Enum.map(concept_vals, fn { identifier, { hub_val, _auth_val } } ->
      # grab a node
      hnode = Dict.get(hierarchy, identifier)
      # and calculate on the current node the sum of its predecessors
      new_auth = Enum.reduce(hnode.incoming, 0, fn ele, acc -> 
        { hub, _auth } = Dict.get(concept_vals, ele)
        acc + hub
      end)
      # keep the sum as the new authority value
      { identifier, { hub_val, new_auth } }
    end) 
    # sum up the squares of all auth values and take the square-root
    norm = Enum.reduce(auth_updated, 0, fn { _identifier, { _hub_val, auth_val } }, acc -> 
      # TODO check this!
      auth_val * auth_val + acc
    end) |> :math.sqrt
    # and use this normalisation value to normalise all authority values
    Enum.map(auth_updated, fn { identifier, { hub_val, auth_val } } ->
      { identifier, { hub_val, auth_val / norm }}
    end) |> Enum.into(HashDict.new)
  end

  # updates for each concept it's hub value
  defp update_hubs(concept_vals, hierarchy) do
    # next: update all the hub values
    hub_updated = Enum.map(concept_vals, fn { identifier, { _hub_val, auth_val } } ->
      # again... grab a node
      hnode = Dict.get(hierarchy, identifier)
      # but this time get all outgoing nodes
      outgoing = hnode.broader ++ hnode.narrower ++ hnode.related
      # and now sum up the authority values of the outgoing nodes 
      new_hub = Enum.reduce(outgoing, 0, fn ele, acc ->
        { _hub, auth } = Dict.get(concept_vals, ele)
        acc + auth
      end)
      # the sum is the new auth hub value
      { identifier, { new_hub, auth_val } }
    end)
    # regarding the normalisation: same procedure as before
    norm = Enum.reduce(hub_updated, 0, fn { _identifier, { hub_val, _auth_val } }, acc -> 
      hub_val * hub_val + acc
    end) |> :math.sqrt
    # dito
    Enum.map(hub_updated, fn { identifier, { hub_val, auth_val } } ->
      { identifier, { hub_val / norm, auth_val }}
    end) |> Enum.into(HashDict.new)
  end

  # the iteration function just calls the update_auth and -_hubs functions
  defp concept_hits_graph_iteration(concept_vals, _hierarchy, 0), do: concept_vals
  defp concept_hits_graph_iteration(concept_vals, hierarchy, iteration_num) do
    update_auth(concept_vals, hierarchy)
    |> update_hubs(hierarchy)
    |> concept_hits_graph_iteration(hierarchy, iteration_num - 1)
  end  
  
  @doc """
  This function sets the auth and hub value to an initial value,
  atleast to 1.0. The values are then normalized by the max val,
  so that it is afterwards between 0 and 1. It than applies the 
  hits algorithm to the graph.
  """
  def concept_hits(hierarchy) do
    concept_vals = Enum.map(hierarchy, fn { ident, hnode } -> 
      # identifier, hub,               auth
      { ident,    { hnode.value + 1.0, hnode.value + 1.0 } }
    end)
    # get the max val
    { _ident, { max_val, _scd_val }} = Enum.max_by(concept_vals, fn { _ident, { fst, _scd }} ->
      fst
    end)
    # divide the hub and auth vals by max
    Enum.map(concept_vals, fn { ident, { hub, auth } } -> 
      { ident, { hub / max_val, auth / max_val } }
    end)
    |> Enum.into(HashDict.new) 
    |> concept_hits_graph_iteration(hierarchy, @iteration_count)
  end

  @doc """
  The function first constructs a cooccurance graph from the given concepts.
  It than applies the HITS-algorithm on the graph. It afterwards sorts the 
  algorithms in descanding order.  
  """  
  def run(graph) do
    graph
    |> Helper.add_incoming_nodes
    |> concept_hits
    |> Enum.map(fn { ident, { hub, auth } } ->
      { ident, (hub + auth) / 2 }
    end)
    |> Enum.sort(fn { _, fst }, { _, scd } -> 
      fst > scd
    end)
  end  
  
end
