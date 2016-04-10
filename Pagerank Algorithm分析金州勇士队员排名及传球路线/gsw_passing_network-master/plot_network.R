library(networkD3)

setwd(WD)
passes <- read.csv("passes.csv")
groups <- read.csv("groups.csv")
size <- read.csv("size.csv")

passes$source <- as.numeric(as.factor(passes$PLAYER))-1
passes$target <- as.numeric(as.factor(passes$PASS_TO))-1
passes$PASS <- passes$PASS/50

groups$nodeid <- groups$name
groups$name <- as.numeric(as.factor(groups$name))-1
groups$group <- as.numeric(as.factor(groups$label))-1
nodes <- merge(groups,size[-1],by="id")
nodes$pagerank <- nodes$pagerank^2*100


forceNetwork(Links = passes,
             Nodes = nodes,
             Source = "source",
             fontFamily = "Arial",
             colourScale = JS("d3.scale.category10()"),
             Target = "target",
             Value = "PASS",
             NodeID = "nodeid",
             Nodesize = "pagerank",
             linkDistance = 350,
             Group = "group", 
             opacity = 0.8,
             fontSize = 16,
             zoom = TRUE,
             opacityNoHover = TRUE)
