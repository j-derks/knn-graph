
#Load libraries:
#install.packages("fuzzyjoin")
library(fuzzyjoin)
library(reshape2)
library(dplyr)
library(tidyr)
library(tidygraph)
library(ggraph)
library(igraph)
library(magrittr)
library(networkD3)
library(htmlwidgets)
library(htmltools)


###################################################### User input:

data_path <- "SCoPE2_processed_data.csv"       #Change path to your dataset. Rows specify the points you wish to plot. Columns are the features.
group_names <- c("M0", "U")                  #(OPTIONAL) Rownames should reflect the different groups in your dataset. Specify how to separate them by name.
ColourScale <- 'd3.scaleOrdinal()
            .domain(["M0", "U"])          
           .range(["green", "purple"]);'     #Specify the names of the points to group/color by (same as group_names) and which color you want each group.     
n <- 3                                       #Specify how many nearest neighbors to include per point.


###################################################### Data wrangling:

data <- read.csv(data_path, row.names = 1)
dat_mat_d <- as.matrix(dist(data))                                     #calculates Euclidean distance between all points
melt_dist_mat <- melt(dat_mat_d)                                       #melt the Euclidean-distance matrix
colnames(melt_dist_mat) <- c("point1","point2","euc_distance")
melt_dist_mat <- melt_dist_mat[which(melt_dist_mat$euc_distance >0),]  #removes rows that calculate distance to self, which = 0. 

#find the nearest neighbors for each point.
neighbors <- melt_dist_mat %>% group_by(point1) %>% arrange(euc_distance) %>% slice(1:n)
neighbors <- neighbors %>% dplyr::rename("from" = 1, "to" = 2, "weight" = 3)
graph_data <- tbl_graph(edges = neighbors, directed = FALSE)

#igraph contains functions to parse the tbl_graph output. Use it to prepare the plot.
cluster_info <- cluster_walktrap(graph_data)
group_info <- membership(cluster_info)
net_3d <- igraph_to_networkD3(graph_data, group = group_info)

#name the nodes by the groups specified in the "user input" section.
node_names <- net_3d$nodes 
df_gnames <- data.frame(group_names)
temp_name <- node_names %>% regex_inner_join(df_gnames, by = c(name = "group_names"))

net_3d$nodes <- temp_name

link_info <- net_3d$links
node_info <- net_3d$nodes

########## count number of times each node is involved in an edge:
point1 <- plyr::count(link_info$source)
point2 <- plyr::count(link_info$target)
points <- point1 %>% full_join(point2, by = c("x" = "x"))
points[is.na(points)] <- 0
points <- points %>% mutate("num_edges" = freq.x+freq.y)

########## associate the index with its real identity:
graph_df <- data.frame(graph_data)
graph_df$index <- 0:(nrow(graph_df)-1)

##########

points <- points %>% left_join(graph_df, by =c("x" = "index"))
dotsize <- points %>% dplyr::select("name", "num_edges")
node_info <- node_info %>% left_join(dotsize, by =c("name" = "name"))
node_info$num_edges <- ((node_info$num_edges)^2)/2                      #scaling up the Nodesize; otherwise the difference is sometimes too small to notice.



###################################################### Generate a 3D network plot!

plot1 <- forceNetwork(Links = link_info, Nodes = node_info,  opacityNoHover = 1,
                      opacity = 1, Source = 'source', Target = 'target', NodeID = 'name', 
                      Group = 'group_names', zoom = TRUE, Nodesize = 'num_edges',
                      colourScale = JS(ColourScale),
                      charge = -30,
                      linkDistance = JS('function(){d3.select("body").style("background-color", "black");return 50;}')) 

onRender(plot1, "function(el,x) { d3.selectAll('.node').on('mouseover', null); }") %>% saveNetwork(file = 'knnGraph.html')

