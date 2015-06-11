# ForkingPaths

**Please note:** The module is still under construction and major API changes will happen in the near future.

ForkingPaths is an elixir module for the creation of cooccurrance graphs from texts. It consumes a vector of words, phrases or entities (for example the output from the [aleph-module](http://github.com/ggb/alpeh) as input. It then builds a cooccurrance graph and allows the application of different centrality and ranking algorithms to get scores for the candidates. The output is a list of tuples where the first element is a candidate and the second the corresponding score.

## Ranking algorithms

The following algorithms are already implemented:

* [Degree Centralitiy](http://en.wikipedia.org/wiki/Centrality#Degree_centrality) (ForkingPaths.DegreeRank)
* [Closeness Centrality](http://en.wikipedia.org/wiki/Centrality#Closeness_centrality) (ForkingPaths.ClosenessRank)
* [Betweenness Centrality](http://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) (ForkingPaths.BetweennessRank)
* [HITS](http://en.wikipedia.org/wiki/HITS_algorithm) (ForkingPaths.HitsRank)
* [PageRank](http://en.wikipedia.org/wiki/PageRank) (ForkingPaths.PageRank)
 
ToDo:

* [Eigenvector Centrality](http://en.wikipedia.org/wiki/Centrality#Eigenvector_centrality)
* [KeyGraph](http://candy.yonsei.ac.kr/courses/06mobile/4-1.pdf)

## Examples

First, create some input data, e. g. using the aleph-module.

```elixir
text = "Computer science is the scientific and practical approach to computation and its applications..."
entities = Aleph.Entities.get(text, :ccs)
```

Create a cooccurrance graph and apply one of the scoring algorithms mentioned above.

```elixir
# the first parameter sets the 'frame' for cooccurrance
graph = ForkingPaths.Cooccurrance2.get(1, graph)
ranked = ForkingPaths.ClosenessRank.get(graph)
```

Output the graph as json. See [this gist](https://gist.github.com/ggb/871edb94134fdead2a2d) to get an impression how the json could be used to visualize the graph.

```elixir
json = ForkingPaths.JSON.get(ranked, graph)
```
