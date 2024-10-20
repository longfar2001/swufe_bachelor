from mpl_toolkits.mplot3d import Axes3D
import pandas as pd
import numpy as np #linear algebra 
import pandas as pd #creating and manipulating dataframes
import matplotlib.pyplot as plt #visuals
import seaborn as sns #visuals

from sklearn.cluster import KMeans #K-Means
from sklearn.cluster import DBSCAN #DBSCAN

from sklearn.preprocessing import StandardScaler #scaler

 #查看导入数据

data = pd.read_csv('Wholesale customers data.csv')
data.head()
#删除‘Region’
data=data.drop(['Region'],axis=1)

#查看导入数据
data = pd.read_csv(r'Wholesale customers data.csv')
data.head()
#删除‘Region’
data=data.drop(['Region'],axis=1)

#描述性统计
data.describe().T

#查看数据集缺失情况
data.isnull().sum()

#查看Grocery缺失值的所在行
data[data['Grocery'].isnull()]

#用Grocery中位数填充缺失值
data['Grocery']=data['Grocery'].fillna(data['Grocery'].median())

#查看Frozen缺失值的所在行
data[data['Frozen'].isnull()]

#用Frozen中位数填充缺失值
data['Frozen']=data['Frozen'].fillna(data['Frozen'].median())

#查看数据集缺失情况
data.isnull().sum()

data1=data
data1['Channel'] = data1.Channel.astype(str)
data1 = pd.get_dummies(data1)
data1

#标准化
from sklearn import preprocessing
zscore_scaler=preprocessing.StandardScaler()
data_scaler=zscore_scaler.fit_transform(data1)
data2 = pd.DataFrame(data_scaler)
data2.columns = ['Fresh','Milk','Grocery','Frozen','Detergents_Paper','Delicassen'
                ,'Channel_1','Channel_2']
data2



from sklearn.manifold import TSNE
tsne = TSNE()
tsne.fit_transform(data2)
tsn = pd.DataFrame(tsne.embedding_, index=data2.index,columns=['Dimension 1', 'Dimension 2'])

scaler = StandardScaler()
scaled_X = scaler.fit_transform(tsn)

outlier_percent = []

for eps in np.linspace(0.001,3,100):
    #建立模型
    dbscan = DBSCAN(eps=eps,min_samples=2*scaled_X.shape[1])
    dbscan.fit(scaled_X)
    #异常点的对数百分比
    perc_outliers = 100 * np.sum(dbscan.labels_ == -1) / len(dbscan.labels_)
    outlier_percent.append(perc_outliers)
    
#离群点百分比与epsilon值选择的线形图
plt.figure(figsize = (8,4), dpi = 100)
sns.lineplot(x=np.linspace(0.001,3,100),y=outlier_percent)
plt.ylabel("Percentage of Points Classified as Outliers")
plt.xlabel("Epsilon Value")
plt.show()

dbscan = DBSCAN(eps=0.2)
dbscan.fit(scaled_X)

tsn['Cluster'] = dbscan.labels_

# 创建三维坐标轴
fig = plt.figure(figsize=(10, 10))
ax = fig.add_subplot(111, projection='3d')
 
# 根据聚类标签绘制散点图
colors = ['red', 'green', 'blue', 'purple', 'orange', 'brown', 'pink', 'gray', 'olive']
for label in set(dbscan.labels_):
    if label == -1:
        cidx = -1
    else:
        cidx = label % len(colors)
    ax.scatter(tsn.loc[tsn['Cluster']==label, 'Dimension 1'],
               tsn.loc[tsn['Cluster']==label, 'Dimension 2'],
               c=colors[cidx], marker='.', label='Cluster '+str(label))
 
# 添加坐标轴标签和图例
ax.set_xlabel('Dimension 1')
ax.set_ylabel('Dimension 2')
ax.set_zlabel('Dimension 3')
ax.set_title('DBSCAN Clustering (TSNE)')
 
plt.legend()
plt.show()