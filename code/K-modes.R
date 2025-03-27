rm(list=ls(all=TRUE))
# 安装并加载必要的包
install.packages("kmodes")
library(klaR)
library(ggplot2)
library(factoextra)
library(cluster)
library(kmodes)

# 读取数据
setwd("D:/1哈师大/市调/抖音带货/数据/K-modes")
data <- read.csv('jl.csv')

# 删除序号列（第一列）
data <- data[, -1]

# 将数据转换为分类数据（K-modes 需要分类数据）
data <- data.frame(lapply(data, as.factor))

# 使用K-Modes进行聚类
#set.seed(123)  # 设置随机种子以确保结果可重复
k <- 3  # 假设我们选择3个聚类
kmodes_result <- kmodes(data, modes = k)

# 将聚类结果添加到原始数据中
data$Cluster <- as.factor(kmodes_result$cluster)

# 保存聚类结果到新的CSV文件
write.csv(data, 'jl_clustered.csv', row.names = FALSE)

# 将因子列转换为数值型（使用虚拟变量）
data_numeric <- model.matrix(~ . - 1, data = data[, -ncol(data)])

# 使用PCA降维
pca_result <- prcomp(data_numeric, scale. = TRUE)
pca_data <- as.data.frame(pca_result$x[, 1:2])
pca_data$Cluster <- data$Cluster

# 绘制聚类结果
ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(size = 2) +
  stat_ellipse(aes(fill = Cluster), geom = "polygon", alpha = 0.2, level = 0.95) +
  labs(title = "K-modes Clustering Results (2D PCA)",
       x = "PCA Component 1",
       y = "PCA Component 2") +
  theme_minimal()

# 输出聚类结果
head(data)


