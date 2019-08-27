#读取原始数据
options(digits = 4)

passes <- read.csv("passes.csv",header = TRUE,stringsAsFactors = TRUE)
groups <- read.csv("groups.csv",header = TRUE,stringsAsFactors = FALSE)

passes$source <- as.numeric(as.factor(passes$PLAYER))-1
passes$target <- as.numeric(as.factor(passes$PASS_TO))-1
passes$PASS <- passes$PASS/50

#构造邻接表
passes$source2 <- as.numeric(as.factor(passes$PLAYER))
passes$target2 <- as.numeric(as.factor(passes$PASS_TO))
adjacencyMatrix<-function(pages){
        n<-max(apply(pages[c("source2","target2")],2,max))
        A <- matrix(0,n,n)
        for(i in 1:nrow(pages)) A[pages[i,]$target2,pages[i,]$source2]<-pages[i,3]
        A
}
A <- adjacencyMatrix(passes)

#变换概率矩阵,考虑阻尼系统的情况
dProbabilityMatrix<-function(G,d=0.85){
        cs <- colSums(G)
        cs[cs==0] <- 1
        n <- nrow(G)
        delta <- (1-d)/n
        A <- matrix(delta,nrow(G),ncol(G))
        for (i in 1:n) A[i,] <- A[i,] + d*G[i,]/cs
        A
}
G <- dProbabilityMatrix(A)

#递归计算矩阵特征值
eigenMatrix<-function(G,iter=100){
        iter<-10
        n<-nrow(G)
        x <- rep(1,n)
        for (i in 1:iter) x <- G %*% x
        x/sum(x)
}

q<-eigenMatrix(G,100)
q <- cbind(levels(passes$PLAYER),q)
q <- q[order(q[,2],decreasing = TRUE),]
size <- as.data.frame(q)
names(size) <- c("name","pagerank")
size$pagerank <- as.numeric(as.character(size$pagerank))
size$name <- as.numeric(as.factor(size$name))

############################################################################
#可交互的 D3 制图
library(networkD3)

groups$nodeid <- groups$name
groups$name <- as.numeric(as.factor(groups$name))
groups$group <- as.numeric(as.factor(groups$label))-1
nodes <- merge(groups,size, by.x = "name",by.y = "name")
nodes$pagerank <- nodes$pagerank*1000

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
##################################################################################

library(network)
mat <- A
net <- network.initialize(15)
net <- network(mat,loops = TRUE)
plot(net,displayisolates = TRUE,vertex.cex =1, 
     boxed.labels= TRUE,labels.cex = TRUE,uselen= TRUE,edge.len = 0.5)
####################################################################################
