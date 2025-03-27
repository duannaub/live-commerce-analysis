"""
Author: duan
"""
import numpy as np
import pandas as pd

# 读取数据
data = pd.read_csv('gld.csv')

# 提取因变量Y和自变量X
Y = data['Y营销策略的影响程度'].values
X = data.iloc[:, 2:].values  # 从第3列开始是自变量X1到X9


# 均值化标准化函数
def mean_normalization(data):
    mean_values = np.mean(data, axis=0)
    normalized_data = data / mean_values
    return normalized_data


# 对Y和X进行均值化标准化
Y_normalized = mean_normalization(Y.reshape(-1, 1)).flatten()
X_normalized = mean_normalization(X)


# 计算灰色关联系数
def grey_relational_coefficient(Y, X, rho=0.5):
    n = len(Y)
    m = X.shape[1]
    gamma = np.zeros((n, m))

    for i in range(n):
        for j in range(m):
            delta = np.abs(Y[i] - X[i, j])
            min_delta = np.min(np.abs(Y - X[:, j]))
            max_delta = np.max(np.abs(Y - X[:, j]))
            gamma[i, j] = (min_delta + rho * max_delta) / (delta + rho * max_delta)

    return gamma


# 计算灰色关联度
def grey_relational_grade(gamma):
    return np.mean(gamma, axis=0)


# 计算关联系数
gamma = grey_relational_coefficient(Y_normalized, X_normalized)

# 计算灰色关联度
grey_grade = grey_relational_grade(gamma)

# 输出结果
factors = ['商品质量', '商品独特性', '商品影响力', '商品性价比', '促销活动吸引力', '商品福利', '互动程度', '平台口碑',
           '平台规则完善度']
result = pd.DataFrame({'因素': factors, '灰色关联度': grey_grade})
result = result.sort_values(by='灰色关联度', ascending=False)

print("灰色关联度排序结果：")
print(result)