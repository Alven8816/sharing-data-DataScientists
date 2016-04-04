res <- EUtilsSummary("Wenhua Yu",type = "esearch",db = "pubmed")
summary(res)
QueryId(res)
res2 <- EUtilsSummary("Wenhua Yu",type = "esearch",db = "pubmed",
                     mindate = "2014",maxdate = "2014")
t<-ArticleTitle(EUtilsGet(res2))
y <- YearPubmed(EUtilsGet(res2))
r <- YearReceived(EUtilsGet(res2))
auths<-Author(EUtilsGet(res2))
country <- Country(EUtilsGet(res2))
abstract <- AbstractText(EUtilsGet(res2))
aff <- Affiliation(EUtilsGet(res2))
agency <- Agency(EUtilsGet(res2))
CollectiveName(EUtilsGet(res2))
CopyrightInformation(EUtilsGet(res2))
ELocationID(EUtilsGet(res2))
Volume(EUtilsGet(res2))
typeof(auths)
Last<-sapply(auths, function(x) paste(x$LastName))#¶ÁÈ¡lastname
citations <- Cited(res)






library(qdap)
myFunc<-function(argument){
        articles1<-data.frame('Abstract'=AbstractText(fetch), 'Year'=YearPubmed(fetch))
        abstracts1<-articles1[which(articles1$Year==argument),]
        abstracts1<-data.frame(abstracts1)
        abstractsOnly<-as.character(abstracts1$Abstract)
        abstractsOnly<-paste(abstractsOnly, sep="", collapse="")
        abstractsOnly<-as.vector(abstractsOnly)
        abstractsOnly<-strip(abstractsOnly)
        stsp<-rm_stopwords(abstractsOnly, stopwords = qdapDictionaries::Top100Words)
        ord<-as.data.frame(table(stsp))
        ord<-ord[order(ord$Freq, decreasing=TRUE),]
        head(ord,20)
}
oSix<-myFunc(2006)
oSeven<-myFunc(2007)
all<-cbind(oSix, oSeven)
names(all)<-c("2006","freq","2007","freq")