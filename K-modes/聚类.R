# ==============================15个国家经济水平================================
# =================================前期准备=====================================
rm(list=ls(all=TRUE))
getwd()
setwd("D:/1哈师大/市调/抖音带货/数据/K-means")
data1 <- read.csv("jl.csv", header = T)
head(data1)      # 查看数据前几行
str(data1)       # 查看数据结构

# 对数据进行标准化，并将各行命名为相应的国家（否则输出的谱系图只会用序号表示）
data11.s <- data.frame(scale(data1[,2:25]),row.names=data1[,1])

# ===============================一、系统聚类法=================================
# 计算距离矩阵
d <- dist(data11.s, method="euclidean", diag=T, upper=F, p=2); d   # 欧式距离

# 采用什么距离计算方法去计算距离矩阵。
# 欧氏距离euclidean、绝对距离manhattan、切氏距离maximum、明氏距离minkowski、兰氏距离canberra；
# diag为是否包括对角元素,upper为是否需要上三角元素，p为minkowski距离的幂次

# 将距离矩阵绘制热力图
library(lattice)
lattice::levelplot(as.matrix(d),xlab="",ylab="")

#--------------------------------------------------------------------------------
# 1.采用最短距离法（single）聚类
HC <- hclust(d,method="single")
# method为系统聚类方法,包括"single"（最短距离法）,"complete"（最长距离法）
# "average"（类平均法）,"median"（中间距离法）,"centroid"（重心法）,"ward.D"（Ward法）

# 绘制最小距离法聚类树状图，当hang为负值时，从底部对齐开始绘制聚类树状图
plot(HC,hang=-1)

# 在图中画合并距离为1.7的水平线,合并成4类
abline(h=1.7,col="blue")

# 2.采用最长距离法（complete）聚类
HC <- hclust(d,method="complete")
plot(HC,hang=-1)
abline(h=4,col="30")

# 3.采用类平均法（average）聚类
HC <- hclust(d,method="average") 
plot(HC,hang=-1)

# 用红色矩形框出聚类数为3的分类结果
rect.hclust(HC,k=3,border="red") 

# 查看具体聚类过程
cbind(HC$merge,HC$height) # HC$height是聚合系数，即距离矩阵中的距离

# ===============================二、K-means聚类法==============================
# 计算距离矩阵
d <- dist(data11.s); d  # 默认欧式距离
# 距离矩阵的热力图
dev.new()
fviz_dist(d, gradient = list(low="white", high="red"))

library(tidyverse)
library(cluster)
library(factoextra)
library(knitr)

# 1.绘制碎石图（定义wss函数计算k类的tot.withniss值）
wss <- function(k){
  kmeans(data11.s, k, nstart = 10)$tot.withinss
}

# 设置聚类数目（x）
k.values <- 1:24
# 提取tot.withniss值，即聚类系数（y）
wss_value <- map_dbl(k.values, wss)
wss_value

# 绘制withinss值随聚类数目变化曲线
dev.new()
plot(k.values,wss_value,
     type = "b", pch=19, frame=F,
     xlab = "Number of clusters K",
     ylab = "Total within-clusters sum of squares")
dev.off()


# 2.利用kmeans聚3类
k3 <- kmeans(data11.s, 3, nstart=25, algorithm="Hartigan-Wong")
# 设定聚类的个数为3, 随机集合的个数为25, 算法有"Hartigan-Wong"、"Lloyd"、"Forgy"、"MacQueen"
# 设定的随机集合个数不同，采用的聚类算法不同，得到的聚类结果可能有所不同。

kable(k3$cluster)                  # 输出分类结果
sort(k3$cluster)                   # 对分类结果进行排序
fviz_cluster(k3,data = data11.s)   # 聚类结果可视化

# ==================================三、模糊聚类================================
library(cluster)
fresult<-fanny(data11.s,3)
summary(fresult)
plot(fresult)   

# ===========================热力图快速聚类（要先标准化）=======================
library(pheatmap)
pheatmap(data11.s)

dev.new()
pheatmap(data11.s, display_numbers=TRUE, cutree_rows=6, cutree_cols=3)
dev.off()

# ==============================使用ape包绘制谱系图=============================
# 1.各种形状的聚类图
library(ape) 
library(RColorBrewer) 
plot(as.phylo(HC), cex = 1.5, font = 1, label.offset = 0.05)    # 基础谱系图

plot(as.phylo(HC), type = "cladogram",
     cex = 1.5, font = 1, label.offset = 0.05)                  # 分支型

plot(as.phylo(HC), type = "radial",
     cex = 1, font = 2, label.offset = 0.05)                    # 放射形
# as.phylo() 函数内为聚类后的数据，cex表示字体的大小
# label.offset表示标签距离树枝的距离，font表示字体形状（粗体、斜体等）
# type表示选择聚类的样式，有cladogram、unrooted、fan、radial等形式。

# 2.根据聚类进行着色
# 使用tip.color() 函数，同时指定颜色的数量与聚类的数量cutree()，要一致
library(RColorBrewer)
mypal = brewer.pal(3, "Dark2") # 设置颜色
clus6 = cutree(HC, 3)          # 设置分支

plot(as.phylo(HC), cex = 0.9, tip.color = mypal[clus6], 
     label.offset = 0.05,font = 1, no.margin = TRUE)              # 基础谱系图

plot(as.phylo(HC), type = "unrooted", tip.color = mypal[clus6], 
     cex = 1, font = 1, label.offset = 0.05)                      # 树形

plot(as.phylo(HC), type = "fan", tip.color = mypal[clus6], 
     cex = 1, font = 3, label.offset = 0.05)                      # 扇形

