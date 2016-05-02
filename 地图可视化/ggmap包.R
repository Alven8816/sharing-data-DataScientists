library(ggmap)
library(dplyr)
library(rlist)
bnu<-"BeiJing Normal University"
geocode(bnu)
qmap(bnu,zoom = 14)

travel<-array(c("bei jing","tai yuan","yan an","xi an","xining,qinghai","qinghai lake","zhangye","dunhuang shi","urumqi","ili"),10)

travel1<-apply(travel,1,geocode)

travel3 <- list.stack(travel1)

travel2<-data.frame(travel1$lon,travel1$lat)

map<-get_googlemap('china', zoom=4,maptype='roadmap',markers = travel3,path = travel3,scale=2)

ggmap(map, extent='device')+
        annotate("text",x=81.2,y=43,label="Ili",alpha=0.8)

###################################################################
#1月1日京津地区部分城市的空气质量 
#数据取自中国环境监测总站
library(XML)
library(ggmap)
library(plyr)

url<-"http://www.cnemc.cn/citystatus/airDailyReportMore.jsp?selmCity=&chkmCity=checkbox&selYear=2013&selMonth=1&selDay=1&chkTime=checkbox&txtPolluteRataMin=&txtPolluteRataMax=&selPolluteStyle=%BF%C9%CE%FC%C8%EB%BF%C5%C1%A3%CE%EF&selAirQuality=%C7%E1%CE%A2%CE%DB%C8%BE&selPolluteLevel=I"
table<-readHTMLTable(url)

raw<-table[[6]]

head(raw)

data<-raw[3:9,2]

data1<-as.numeric(gsub(',','',data))

names<-array(c("beijing","tianjin","shijiazhuang","tangshan","qinghuangdao","handan","baoding"),7)
lacation<-apply(names,1,geocode)
list.stack(names)
cnames<-c("北京","天津","石家庄","唐山","秦皇岛","邯郸","保定")

air<-data.frame(lacation,data1,cnames)

airmap<-qmap("tianjin",zoom=12,extent="device",legend="none",darken=.2)
airmap+
        geom_point(data=air,aes(x=lon,y=lat,size=data1),colour="red")+
        geom_text(data=air,colour="black",aes(x=(lon+0.5),y=lat,label=as.factor(data1)),hjust=1,vjust=0)+
        geom_text(data=air,colour="black",aes(x=lon,y=lat,label=cnames,fontface=2),size=6,hjust=1,vjust=0)

#########################
geocode("beijing normal university",output="more")

bnu<-geocode("beijing normal university")
bnu <- as.numeric(bnu)
#[1] 116.3656 39.9622

revgeocode(bnu)

#Google Distance Matrix API，可以计算两个地址之间的距离，
#而且还会根据两地的Google路线计算步行、自行车和汽车所需的相应时间。
mapdist("tianjin", "beijing",mode="driving")

#route（）函数返回地图上两地之间由一系列线段所构成的路线，
#每一个线段都有其起点和终点的经纬度。

#SCAN说明文档
