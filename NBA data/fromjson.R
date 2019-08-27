library(pipeR)
library(rlist)
library(jsonlite)



data1 <- "F:\\乐享数据DataScientists(data-sharing)\\sharing-data-DataScientists\\Pagerank Algorithm分析金州勇士队员排名及传球路线\\gsw_passing_network-master" %>>%
        list.files("\\.json",full.names = TRUE) %>>%
        list.load(action = "ungroup")

data_list[1][[1]]$resultSets$rowSet[[1]][,c(1,2,5,7,8)]
data_list[1][[1]]$resultSets$rowSet[[2]][,c(1,2,5,7,8)]

################################
files <- "F:\\乐享数据DataScientists(data-sharing)\\sharing-data-DataScientists\\Pagerank Algorithm分析金州勇士队员排名及传球路线\\gsw_passing_network-master"
files_list <- dir(files,pattern = "\\.json",full.names = TRUE)
data_list <- lapply(files_list,jsonlite::fromJSON)
name_data <- unlist(list.select(data_list,resultSets$headers[[1]])[1])
raw_data <- list.select(data_list,resultSets$rowSet)
b <- sapply(raw_data,rbind)
#made数据集
made = list()
for (i in 1:15){
        made[[i]]= as.data.frame(b[[i]][1])
        made
}
made = list.rbind(made)
names(made) = name_data
#receive数据集
receive = list()
for (i in 1:15){
        receive[[i]]= as.data.frame(b[[i]][2])
        receive
}
receive = list.rbind(receive)
names(receive) = name_data

newdata <- rbind(made,receive)
newdata <- newdata[,c(1,2,5,7,8,10)]

unique(newdata$PLAYER_ID)


