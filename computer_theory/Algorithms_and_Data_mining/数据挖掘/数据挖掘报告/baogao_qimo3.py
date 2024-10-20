# DBSCAN算法
import pandas as pd
import numpy as np #linear algebra 
import pandas as pd #creating and manipulating dataframes
import matplotlib.pyplot as plt #visuals
import seaborn as sns #visuals

from sklearn.cluster import KMeans #K-Means
from sklearn.cluster import DBSCAN #DBSCAN

from sklearn.preprocessing import StandardScaler #scaler

#查看导入数据
import pandas as pd
data = pd.read_csv(r'Wholesale customers data.csv')
data.head()
#删除‘Region’
data=data.drop(['Region'],axis=1)

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

#针对地区分类判断其他字段的两两关系
# sns.pairplot(data,hue='Region',palette='Set1')

#EDA
plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Milk',y='Grocery',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Milk',y='Frozen',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Detergents_Paper',y='Grocery',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Detergents_Paper',y='Frozen',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Detergents_Paper',y='Fresh',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Delicassen',y='Fresh',hue='Channel')
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Frozen',y='Fresh',hue='Channel')
plt.show()

# #EDA
plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Fresh',hue='Channel',multiple="stack")
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Milk',hue='Channel',multiple="stack")
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Grocery',hue='Channel',multiple="stack")
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Frozen',hue='Channel',multiple="stack")
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Detergents_Paper',hue='Channel',multiple="stack")
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.histplot(data,x='Delicassen',hue='Channel',multiple="stack")
plt.show()

#构建没有Channel的热力图
sns.clustermap(data.drop('Channel',axis=1).corr(),annot=True)

#将客户区域位置处理为哑变量
data['Channel'] = data.Channel.astype(str)
data = pd.get_dummies(data)
data

#标准化
from sklearn import preprocessing
zscore_scaler=preprocessing.StandardScaler()
data_scaler=zscore_scaler.fit_transform(data)
data2 = pd.DataFrame(data_scaler)
data2.columns = ['Fresh','Milk','Grocery','Frozen','Detergents_Paper','Delicassen'
                ,'Channel_1','Channel_2']
data2

data=data2

# 扩展数据
scaler = StandardScaler()
scaled_X = scaler.fit_transform(data)
# scaled_X = scaler.fit_transform(tsn)

#用DBSCAN测试不同的epsilon值,设置min_samples等于2倍的特征个数

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

dbscan = DBSCAN(eps=2)
dbscan.fit(scaled_X)


plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Grocery',y='Milk',hue=dbscan.labels_)
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Fresh',y='Frozen',hue=dbscan.labels_)
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Frozen',y='Milk',hue=dbscan.labels_)
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Detergents_Paper',y='Fresh',hue=dbscan.labels_)
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Detergents_Paper',y='Grocery',hue=dbscan.labels_)
plt.show()

plt.figure(figsize = (8,4), dpi = 100)
sns.scatterplot(data=data,x='Delicassen',y='Fresh',hue=dbscan.labels_)
plt.show()

#定义一个label，比较集群和离群值在这些类别上的支出金额的统计平均值
data2['Labels'] = dbscan.labels_

# cats = data2.drop(['Channel','Region'],axis=1)
# cats = data2.drop('Channel',axis=1)
cats=data2
cats.groupby('Labels').mean()




