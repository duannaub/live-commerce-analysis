"""
Author: duan
"""
import pandas as pd
import matplotlib.pyplot as plt
from kmodes.kmodes import KModes
from sklearn.preprocessing import LabelEncoder

# 读取数据
data = pd.read_csv('jl.csv')

# 删除序号列（第一列）
data = data.drop(columns=['序号'])

# 将数据转换为分类数据（K-modes 需要分类数据）
data = data.astype(str)

# 使用肘部法确定最佳聚类数
costs = []
K = range(1, 10)
for k in K:
    kmodes = KModes(n_clusters=k, init='Huang', n_init=5, verbose=0)
    kmodes.fit(data)
    costs.append(kmodes.cost_)

# 绘制碎石图
plt.figure(figsize=(8, 5))
plt.plot(K, costs, 'bo-')
plt.xlabel('Number of clusters')
plt.ylabel('Cost')
plt.title('Elbow Method For Optimal k')
plt.show()

# 根据碎石图选择最佳聚类数（假设选择 k=3）
k = 3
kmodes = KModes(n_clusters=k, init='Huang', n_init=5, verbose=0)
clusters = kmodes.fit_predict(data)

# 将聚类结果添加到原始数据中
data['Cluster'] = clusters

# 将包含聚类结果的数据保存到一个新的文件中
data.to_csv('jl_clustered.csv', index=False)

# 可视化聚类结果（使用 PCA 降维）
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# 将分类数据转换为数值型数据（用于 PCA）
label_encoders = {}
data_encoded = data.copy()
for column in data_encoded.columns[:-1]:  # 排除最后一列（Cluster）
    le = LabelEncoder()
    data_encoded[column] = le.fit_transform(data_encoded[column])
    label_encoders[column] = le

# 标准化数据
scaler = StandardScaler()
data_scaled = scaler.fit_transform(data_encoded.drop(columns=['Cluster']))

# 使用 PCA 降维到 2D
pca = PCA(n_components=2)
data_pca = pca.fit_transform(data_scaled)

# 绘制聚类结果
plt.figure(figsize=(10, 6))
for i in range(k):
    plt.scatter(data_pca[data['Cluster'] == i, 0], data_pca[data['Cluster'] == i, 1], label=f'Cluster {i}')
plt.xlabel('PCA Component 1')
plt.ylabel('PCA Component 2')
plt.title('K-modes Clustering Results (2D PCA)')
plt.legend()
plt.show()

# 输出聚类结果
print(data.head())
