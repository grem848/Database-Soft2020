# Assignment A4 - Graph Algorithms for Search in Graph Database
DESCRIPTION

The objective of this assignment is to provide practice in applying graph algorithms for searching in graph databases.



Graph algorithms can be used for discovering patterns and meaningful information, hidden in the nodes, relations, and properties of graph database components.



Your task is to import or create a sample Neo4j database, appropriate for testing graph algorithms and research this database to

a)    identify the most important nodes, based on their relationships

b)   detect the close connected communities of nodes

c)   discover similarity between nodes, based on their properties or behaviour

d)   find available routes or optimal paths between the nodes



Suggest implementation of the results in the business, related with your data.



Notes:

1.    For inspiration, see Neo4j sandboxes https://sandbox.neo4j.com/ and graphgists https://neo4j.com/graphgists/

2.    For algorithms' reference, see Neo4j documentation at https://neo4j.com/docs/graph-data-science/1.1/

3.    To read more, download the free book Graph Algorithms: Practical Examples in Apache Spark and Neo4j, by Mark Needham & Amy E. Hodler, published by O’Reilly Media from neo4j.com/graph-algorithms-book/



The solution of this assignment brings five study points.


---

# Network Demo
I used a graph containing network services and their dependencies on eachother, I expanded on the data myself to make it a bit more interesting.

## How to use

* Open Neo4j Desktop
* create or open a database
* start the server/database

* Type these console commands in the project root:
    * npm install
    * node app.js
* Open Neo4j and check the data was made
* Have fun!

app.js will throw an exception, ignore it the code worked anyway!


<br>

---

## a) - identify the most important nodes, based on their relationships
Page Rank is an algorithm that measures the influence or importance of nodes in a directed graph.

Results: [Link to pagerank.json file](pagerank.json)

```cypher
CALL gds.pageRank.stream({
  nodeProjection: 'Service',
  relationshipProjection: 'DEPENDS_ON',
  maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC

```

<br>

## b) - detect the close connected communities of nodes

The Label Propagation algorithm (LPA) is a fast algorithm for finding communities in a graph. It detects these communities using network structure alone as its guide, and doesn’t require a pre-defined objective function or prior information about the communities.

Results: [Link to labelPropagation.json file](labelPropagation.json)
```cypher
CALL gds.labelPropagation.stream({
  nodeProjection: 'Service',
  relationshipProjection: 'DEPENDS_ON'
})
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY name ASC
```
<br>

## c) - discover similarity between nodes, based on their properties or behaviour
The Node Similarity algorithm compares a set of nodes based on the nodes they are connected to. Two nodes are considered similar if they share many of the same neighbors. Node Similarity computes pair-wise similarities based on the Jaccard metric, also known as the Jaccard Similarity Score.

Results: [Link to similarity.json file](similarity.json)


```cypher
CALL gds.nodeSimilarity.stream({
      nodeProjection: 'Service',
  relationshipProjection: 'DEPENDS_ON'
})
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).name AS service1, gds.util.asNode(node2).name AS service2, similarity
ORDER BY similarity DESCENDING, service1, service2
```
<br>

## d) - find available routes or optimal paths between the nodes
Since my data doesn't contain a cost, I could'nt use the path finding algorithms. Instead I just used closeness, though it doesn't return paths. So this was just to not leave this answer empty!

Closeness centrality is a way of detecting nodes that are able to spread information very efficiently through a graph.

The closeness centrality of a node measures its average farness (inverse distance) to all other nodes. Nodes with a high closeness score have the shortest distances to all other nodes.

Results: [Link to centrality-closeness.json file](centrality-closeness.json)

```cypher
CALL gds.alpha.closeness.stream({
  nodeProjection: 'Service',
  relationshipProjection: 'DEPENDS_ON'
})
YIELD nodeId, centrality
RETURN gds.util.asNode(nodeId).name AS service, centrality
ORDER BY centrality DESC
```
