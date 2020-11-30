# knn-graph
Create a kNN-graph from a high-dimensional dataset to visualize each point's nearest neighbors.

**kNNGraph_script.R** can be used to generate a network of nearest neighbors with minimal user input. An example is loaded using SCoPE2 data from [Single-cell proteomic and transcriptomic analysis of macrophage heterogeneity](https://www.biorxiv.org/content/10.1101/665307v4) in which proteomes of single monocytes and macrophage cells are quantified relative to each other. Using a kNN-graph we can visualize the heterogeneity that exists within a cell-type, and in a future patch, investigate clustering by using gradient coloring to indicate the differential abundance of features (e.g. the enrichment of a specific protein or GO-term) 

### **To run an example:**
1. Download the **SCoPE2_processed_data.csv** and **kNNGraph_script.R** files
2. Run the **kNNGraph_script.R** file and it should generate a k-nearest-neighbor network as a .html.


### **To run a user-specific dataset:**
1. Organize a matrix with row names indicating the identity of each future node (e.g. cell-type) and column names indicating the identity of each feature (e.g. protein abundance). 
2. At the top of **kNNGraph_script.R**, set your data path, and specify the names by which to group and color the nodes.
