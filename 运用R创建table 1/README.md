---
title: "运用R创建描述基本特征“Table 1”"
author: "余文华"
date: "2016年4月4日"
output: html_document
---



    描述病人基本特征应该算是每个医学研究论文所必须的步骤，而且常以“Table 1”表示，说明其在研究中的重要位置。 R非 常人性化的方便了我们医学生来处理研究资料的病人基本特征。tableone包就是为描述人群基本特征的R包之一。我们来一起分享R的方便和强大吧！
    
##例子引入

    为了说明tableone包，我们采用了SCAN中tableone的说明文档中的例子。数据来自survival包中梅奥诊所原发性胆汁性肝硬化pbc数据(Mayo Clinic Primary Biliary Cirrhosis Data)。共424例PBC患者参与10年的生存分析，具体数据描述可以在R帮助中搜索pbc查看。
    

```r
## 载入Mayo Clinic Primary Biliary Cirrhosis数据
library(survival)
library(pander)
data(pbc)
## 检查变量
head(pbc)
```

```
##   id time status trt      age sex ascites hepato spiders edema bili chol
## 1  1  400      2   1 58.76523   f       1      1       1   1.0 14.5  261
## 2  2 4500      0   1 56.44627   f       0      1       1   0.0  1.1  302
## 3  3 1012      2   1 70.07255   m       0      0       0   0.5  1.4  176
## 4  4 1925      2   1 54.74059   f       0      1       1   0.5  1.8  244
## 5  5 1504      1   2 38.10541   f       0      1       1   0.0  3.4  279
## 6  6 2503      2   2 66.25873   f       0      1       0   0.0  0.8  248
##   albumin copper alk.phos    ast trig platelet protime stage
## 1    2.60    156   1718.0 137.95  172      190    12.2     4
## 2    4.14     54   7394.8 113.52   88      221    10.6     3
## 3    3.48    210    516.0  96.10   55      151    12.0     4
## 4    2.54     64   6121.8  60.63   92      183    10.3     4
## 5    3.53    143    671.0 113.15   72      136    10.9     3
## 6    3.98     50    944.0  93.00   63       NA    11.0     3
```

```r
str(pbc)
```

```
## 'data.frame':	418 obs. of  20 variables:
##  $ id      : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ time    : int  400 4500 1012 1925 1504 2503 1832 2466 2400 51 ...
##  $ status  : int  2 0 2 2 1 2 0 2 2 2 ...
##  $ trt     : int  1 1 1 1 2 2 2 2 1 2 ...
##  $ age     : num  58.8 56.4 70.1 54.7 38.1 ...
##  $ sex     : Factor w/ 2 levels "m","f": 2 2 1 2 2 2 2 2 2 2 ...
##  $ ascites : int  1 0 0 0 0 0 0 0 0 1 ...
##  $ hepato  : int  1 1 0 1 1 1 1 0 0 0 ...
##  $ spiders : int  1 1 0 1 1 0 0 0 1 1 ...
##  $ edema   : num  1 0 0.5 0.5 0 0 0 0 0 1 ...
##  $ bili    : num  14.5 1.1 1.4 1.8 3.4 0.8 1 0.3 3.2 12.6 ...
##  $ chol    : int  261 302 176 244 279 248 322 280 562 200 ...
##  $ albumin : num  2.6 4.14 3.48 2.54 3.53 3.98 4.09 4 3.08 2.74 ...
##  $ copper  : int  156 54 210 64 143 50 52 52 79 140 ...
##  $ alk.phos: num  1718 7395 516 6122 671 ...
##  $ ast     : num  137.9 113.5 96.1 60.6 113.2 ...
##  $ trig    : int  172 88 55 92 72 63 213 189 88 143 ...
##  $ platelet: int  190 221 151 183 136 NA 204 373 251 302 ...
##  $ protime : num  12.2 10.6 12 10.3 10.9 11 9.7 11 11 11.5 ...
##  $ stage   : int  4 3 4 4 3 3 3 3 2 4 ...
```

##数据处理

    我们查看了数据结构，发现许多分类变量仍然是整数型或数值型。现在需要把这些变量转换为因子型。至于为什么都需要转换，看到后面就知道了。
 

```r
varsToFactor <- c("status","trt","ascites","hepato","spiders","edema","stage")
pbc[varsToFactor] <- lapply(pbc[varsToFactor], factor)
```

##开始运用tableone包

###创建需要描述的变量列表

    在本例中，我们想知道D-penicillamine药物组和安慰剂组在生存时间(time)、生存状态(status)、年龄(age)、性别(sex)及一些临床指标等资料的基本特征及差异。创建vars变量列表存放需要比较和描述的变量名。
    

```r
dput(names(pbc))
```

```
## c("id", "time", "status", "trt", "age", "sex", "ascites", "hepato", 
## "spiders", "edema", "bili", "chol", "albumin", "copper", "alk.phos", 
## "ast", "trig", "platelet", "protime", "stage")
```

```r
vars <- c("time","status","age","sex","ascites","hepato",
          "spiders","edema","bili","chol","albumin",
          "copper","alk.phos","ast","trig","platelet",
          "protime","stage")
```

###以不同组(trt)分层创建Table 1

    创建table one的函数非常简单，CreatTableOne()函数，只需要指出需描述的变量，即前面的vars变量列表，strata参数说明按照trt变量分层即可。注意的是如果前面没有指定分类变量类型，tableone会以数值型变量处理你的变量的，这也就是需要提前指定分类变量的原因。
    

```r
library(tableone)
tableOne <- CreateTableOne(vars = vars, strata = c("trt"), data = pbc)
table1 <- print(tableOne)
```

```
##                       Stratified by trt
##                        1                 2                 p      test
##   n                        158               154                      
##   time (mean (sd))     2015.62 (1094.12) 1996.86 (1155.93)  0.883     
##   status (%)                                                0.894     
##      0                      83 (52.5)         85 (55.2)               
##      1                      10 ( 6.3)          9 ( 5.8)               
##      2                      65 (41.1)         60 (39.0)               
##   age (mean (sd))        51.42 (11.01)     48.58 (9.96)     0.018     
##   sex = f (%)              137 (86.7)        139 (90.3)     0.421     
##   ascites = 1 (%)           14 ( 8.9)         10 ( 6.5)     0.567     
##   hepato = 1 (%)            73 (46.2)         87 (56.5)     0.088     
##   spiders = 1 (%)           45 (28.5)         45 (29.2)     0.985     
##   edema (%)                                                 0.877     
##      0                     132 (83.5)        131 (85.1)               
##      0.5                    16 (10.1)         13 ( 8.4)               
##      1                      10 ( 6.3)         10 ( 6.5)               
##   bili (mean (sd))        2.87 (3.63)       3.65 (5.28)     0.131     
##   chol (mean (sd))      365.01 (209.54)   373.88 (252.48)   0.748     
##   albumin (mean (sd))     3.52 (0.44)       3.52 (0.40)     0.874     
##   copper (mean (sd))     97.64 (90.59)     97.65 (80.49)    0.999     
##   alk.phos (mean (sd)) 2021.30 (2183.44) 1943.01 (2101.69)  0.747     
##   ast (mean (sd))       120.21 (54.52)    124.97 (58.93)    0.460     
##   trig (mean (sd))      124.14 (71.54)    125.25 (58.52)    0.886     
##   platelet (mean (sd))  258.75 (100.32)   265.20 (90.73)    0.555     
##   protime (mean (sd))    10.65 (0.85)      10.80 (1.14)     0.197     
##   stage (%)                                                 0.201     
##      1                      12 ( 7.6)          4 ( 2.6)               
##      2                      35 (22.2)         32 (20.8)               
##      3                      56 (35.4)         64 (41.6)               
##      4                      55 (34.8)         54 (35.1)
```

    可以看到一个非常熟悉的table one了，行分别为n(病例个数)、time、status等等。可以发现计量变量都是用“(mean (sd))”描述、分类变量用“ (%) ”表示，还神奇的算出了P值。大家肯定喜出望外，妈妈再也不用担心我不会算P值了。这个表好像就能用了。但是你太“simple”了，统计如果这么简单，还用我们学统计的干嘛-_-。
    大家也许注意到了最后一列还有个test是空着的，问题就在这里，这些P值是用什么test算出来的呢？还有像本例中的临床生化指标，肯定是偏态分布的，用“(mean (sd))”描述也是错误的呀。下面让我们来完善这个table one吧！
    


 
###指定变量分析方法

    默认情况下，tableone使用正态分布方法分析资料，因此会出现“(mean (sd))”的描述，两组计量资料用oneway.test函数，t检验分析，分类资料用 chisq.test函数，卡方检验分析，默认有矫正卡方，精确性检验用fisher.test函数Fisher检验等等。
    我们可以指定变量是进行正态或非正态检验方法。
    

```r
table1 <- print(tableOne, nonnormal = c("bili","chol","copper","alk.phos","trig"),
      exact = c("status","stage"), cramVars = "hepato", smd = TRUE)
```

```
##                          Stratified by trt
##                           1                        
##   n                           158                  
##   time (mean (sd))        2015.62 (1094.12)        
##   status (%)                                       
##      0                         83 (52.5)           
##      1                         10 ( 6.3)           
##      2                         65 (41.1)           
##   age (mean (sd))           51.42 (11.01)          
##   sex = f (%)                 137 (86.7)           
##   ascites = 1 (%)              14 ( 8.9)           
##   hepato = 0/1 (%)          85/73 (53.8/46.2)      
##   spiders = 1 (%)              45 (28.5)           
##   edema (%)                                        
##      0                        132 (83.5)           
##      0.5                       16 (10.1)           
##      1                         10 ( 6.3)           
##   bili (median [IQR])        1.40 [0.80, 3.20]     
##   chol (median [IQR])      315.50 [247.75, 417.00] 
##   albumin (mean (sd))        3.52 (0.44)           
##   copper (median [IQR])     73.00 [40.00, 121.00]  
##   alk.phos (median [IQR]) 1214.50 [840.75, 2028.00]
##   ast (mean (sd))          120.21 (54.52)          
##   trig (median [IQR])      106.00 [84.50, 146.00]  
##   platelet (mean (sd))     258.75 (100.32)         
##   protime (mean (sd))       10.65 (0.85)           
##   stage (%)                                        
##      1                         12 ( 7.6)           
##      2                         35 (22.2)           
##      3                         56 (35.4)           
##      4                         55 (34.8)           
##                          Stratified by trt
##                           2                         p      test    SMD   
##   n                           154                                        
##   time (mean (sd))        1996.86 (1155.93)          0.883          0.017
##   status (%)                                         0.884 exact    0.054
##      0                         85 (55.2)                                 
##      1                          9 ( 5.8)                                 
##      2                         60 (39.0)                                 
##   age (mean (sd))           48.58 (9.96)             0.018          0.270
##   sex = f (%)                 139 (90.3)             0.421          0.111
##   ascites = 1 (%)              10 ( 6.5)             0.567          0.089
##   hepato = 0/1 (%)          67/87 (43.5/56.5)        0.088          0.207
##   spiders = 1 (%)              45 (29.2)             0.985          0.016
##   edema (%)                                          0.877          0.058
##      0                        131 (85.1)                                 
##      0.5                       13 ( 8.4)                                 
##      1                         10 ( 6.5)                                 
##   bili (median [IQR])        1.30 [0.72, 3.60]       0.842 nonnorm  0.171
##   chol (median [IQR])      303.50 [254.25, 377.00]   0.544 nonnorm  0.038
##   albumin (mean (sd))        3.52 (0.40)             0.874          0.018
##   copper (median [IQR])     73.00 [43.00, 139.00]    0.717 nonnorm <0.001
##   alk.phos (median [IQR]) 1283.00 [922.50, 1949.75]  0.812 nonnorm  0.037
##   ast (mean (sd))          124.97 (58.93)            0.460          0.084
##   trig (median [IQR])      113.00 [84.50, 155.00]    0.370 nonnorm  0.017
##   platelet (mean (sd))     265.20 (90.73)            0.555          0.067
##   protime (mean (sd))       10.80 (1.14)             0.197          0.146
##   stage (%)                                          0.205 exact    0.246
##      1                          4 ( 2.6)                                 
##      2                         32 (20.8)                                 
##      3                         64 (41.6)                                 
##      4                         54 (35.1)
```



    在这里我们通过nonnormal =指定对血清胆红素bili)、血清胆固醇(chol)、尿铜(copper)等临床生化非正态指标用非参检验方法，对生存状态（"status"）、临床分期（stage）用Fisher检验。同时用cramVars参数可以显示两个水平的分类变量构成比，smd参数为显示standardized mean differences。
    可以看到指定的非正态资料使用“median [IQR]”来表示数据了，而且在test列也出现了P值计算使用的方法，最后一列为SMD数值，这一切都是我们需要的。
    
###通过Summary查看tableone

    我们也可以通过 summary.TableOne方法，查看更详细的数据信息。里面包含了按照trt分层，计量资料及分类资料的基本统计描述和正态及非正态方法下的P值等信息。
    

```r
library(printr)
summary(tableOne)
```

```
## 
##      ### Summary of continuous variables ###
## 
## trt: 1
##            n miss p.miss mean    sd median   p25  p75   min   max  skew
## time     158    0    0.0 2016 1e+03   1895 1e+03 2632  41.0  4556  0.41
## age      158    0    0.0   51 1e+01     52 4e+01   59  26.3    78  0.06
## bili     158    0    0.0    3 4e+00      1 8e-01    3   0.3    20  2.67
## chol     158   18   11.4  365 2e+02    316 2e+02  417 127.0  1712  3.83
## albumin  158    0    0.0    4 4e-01      4 3e+00    4   2.1     5 -0.40
## copper   158    1    0.6   98 9e+01     73 4e+01  121   9.0   588  2.50
## alk.phos 158    0    0.0 2021 2e+03   1214 8e+02 2028 369.0 11552  2.71
## ast      158    0    0.0  120 5e+01    112 8e+01  152  26.4   338  1.09
## trig     158   19   12.0  124 7e+01    106 8e+01  146  33.0   598  2.95
## platelet 158    2    1.3  259 1e+02    255 2e+02  322  62.0   563  0.50
## protime  158    0    0.0   11 9e-01     11 1e+01   11   9.0    14  1.10
##          kurt
## time     -0.4
## age      -0.5
## bili      7.6
## chol     20.2
## albumin   0.3
## copper    8.2
## alk.phos  7.4
## ast       1.6
## trig     14.3
## platelet  0.2
## protime   1.6
## -------------------------------------------------------- 
## trt: 2
##            n miss p.miss mean    sd median   p25  p75   min   max skew
## time     154    0    0.0 1997 1e+03   1811 1e+03 2771  51.0  4523  0.4
## age      154    0    0.0   49 1e+01     48 4e+01   56  30.6    75  0.2
## bili     154    0    0.0    4 5e+00      1 7e-01    4   0.3    28  2.7
## chol     154   10    6.5  374 3e+02    304 3e+02  377 120.0  1775  3.1
## albumin  154    0    0.0    4 4e-01      4 3e+00    4   2.0     4 -0.8
## copper   154    1    0.6   98 8e+01     73 4e+01  139   4.0   558  2.0
## alk.phos 154    0    0.0 1943 2e+03   1283 9e+02 1950 289.0 13862  3.3
## ast      154    0    0.0  125 6e+01    117 8e+01  152  28.4   457  1.7
## trig     154   11    7.1  125 6e+01    113 8e+01  155  44.0   432  1.7
## platelet 154    2    1.3  265 9e+01    260 2e+02  322  71.0   487  0.2
## protime  154    0    0.0   11 1e+00     11 1e+01   11   9.2    17  1.9
##          kurt
## time     -0.7
## age      -0.5
## bili      7.3
## chol     11.1
## albumin   2.0
## copper    6.6
## alk.phos 12.8
## ast       6.3
## trig      5.5
## platelet -0.3
## protime   6.4
## 
## p-values
##             pNormal pNonNormal
## time     0.88304691 0.82661809
## age      0.01767247 0.01962155
## bili     0.13093942 0.84168460
## chol     0.74799072 0.54433899
## albumin  0.87388074 0.95045176
## copper   0.99915849 0.71745444
## alk.phos 0.74726165 0.81198200
## ast      0.45969842 0.45892358
## trig     0.88604213 0.36980434
## platelet 0.55451136 0.45482564
## protime  0.19714026 0.58802048
## 
## Standardize mean differences
##                1 vs 2
## time     0.0166658751
## age      0.2702619258
## bili     0.1710905651
## chol     0.0382210537
## albumin  0.0180021838
## copper   0.0001200022
## alk.phos 0.0365323630
## ast      0.0837836058
## trig     0.0170615337
## platelet 0.0674763888
## protime  0.1460939117
## 
## =======================================================================================
## 
##      ### Summary of categorical variables ### 
## 
## trt: 1
##      var   n miss p.miss level freq percent cum.percent
##   status 158    0    0.0     0   83    52.5        52.5
##                              1   10     6.3        58.9
##                              2   65    41.1       100.0
##                                                        
##      sex 158    0    0.0     m   21    13.3        13.3
##                              f  137    86.7       100.0
##                                                        
##  ascites 158    0    0.0     0  144    91.1        91.1
##                              1   14     8.9       100.0
##                                                        
##   hepato 158    0    0.0     0   85    53.8        53.8
##                              1   73    46.2       100.0
##                                                        
##  spiders 158    0    0.0     0  113    71.5        71.5
##                              1   45    28.5       100.0
##                                                        
##    edema 158    0    0.0     0  132    83.5        83.5
##                            0.5   16    10.1        93.7
##                              1   10     6.3       100.0
##                                                        
##    stage 158    0    0.0     1   12     7.6         7.6
##                              2   35    22.2        29.7
##                              3   56    35.4        65.2
##                              4   55    34.8       100.0
##                                                        
## -------------------------------------------------------- 
## trt: 2
##      var   n miss p.miss level freq percent cum.percent
##   status 154    0    0.0     0   85    55.2        55.2
##                              1    9     5.8        61.0
##                              2   60    39.0       100.0
##                                                        
##      sex 154    0    0.0     m   15     9.7         9.7
##                              f  139    90.3       100.0
##                                                        
##  ascites 154    0    0.0     0  144    93.5        93.5
##                              1   10     6.5       100.0
##                                                        
##   hepato 154    0    0.0     0   67    43.5        43.5
##                              1   87    56.5       100.0
##                                                        
##  spiders 154    0    0.0     0  109    70.8        70.8
##                              1   45    29.2       100.0
##                                                        
##    edema 154    0    0.0     0  131    85.1        85.1
##                            0.5   13     8.4        93.5
##                              1   10     6.5       100.0
##                                                        
##    stage 154    0    0.0     1    4     2.6         2.6
##                              2   32    20.8        23.4
##                              3   64    41.6        64.9
##                              4   54    35.1       100.0
##                                                        
## 
## p-values
##            pApprox     pExact
## status  0.89350975 0.88422188
## sex     0.42122610 0.37743235
## ascites 0.56728647 0.52558267
## hepato  0.08820884 0.07137522
## spiders 0.98466036 0.90113734
## edema   0.87681949 0.89370131
## stage   0.20129629 0.20455558
## 
## Standardize mean differences
##             1 vs 2
## status  0.05375763
## sex     0.11141161
## ascites 0.08900618
## hepato  0.20699413
## spiders 0.01632844
## edema   0.05811659
## stage   0.24600834
```


    
