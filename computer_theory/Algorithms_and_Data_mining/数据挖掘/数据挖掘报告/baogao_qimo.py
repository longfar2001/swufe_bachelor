#查看导入数据
import pandas as pd
data = pd.read_csv('Wholesale customers data.csv')
data.head()
#删除‘Region’
data=data.drop(['Region'],axis=1)

#查看导入数据
import pandas as pd
data = pd.read_csv(r'Wholesale customers data.csv')
data.head()
#删除‘Region’
data=data.drop(['Region'],axis=1)

#查看数据基本信息
data.info()

#描述性统计
data.describe().T

#查看数据集缺失情况
data.isnull().sum()
import missingno as msno 
msno.bar(data)
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

#绘制核密度图
import matplotlib.pyplot as plt
import seaborn as sns
datat=data.drop(['Channel'],axis=1)
column = datat.columns.tolist() # 列表头
fig = plt.figure(figsize=(25, 12), dpi=75)
for i in range(6):
    plt.subplot(2,3, i + 1)
    ax = sns.kdeplot(data=datat[column[i]],color='blue',shade= True)
    plt.ylabel(column[i], fontsize=36)
plt.show()

#绘制六种产品的箱线图
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False
plt.figure(figsize=(10, 8))  # 建立图像
p = data.boxplot(return_type='dict')  # 画箱线图，直接使用DataFrame的方法
x = p['fliers'][0].get_xdata()
y = p['fliers'][0].get_ydata()
y.sort()
for i in range(len(x)):
    if i>0:
        plt.annotate(y[i], xy = (x[i],y[i]), xytext=(x[i]+0.05 -0.8/(y[i]-y[i-1]),y[i]))
    else:
        plt.annotate(y[i], xy = (x[i],y[i]), xytext=(x[i]+0.08,y[i]))
plt.show()  

#删除部分异常值
import numpy as np
def drop_outlier(data, start, end):
    for i in range(start, end):
        field = data.columns[i]
        Q1 = np.quantile(data[field], 0.25)
        Q3 = np.quantile(data[field], 0.75)
        deta = (Q3 - Q1) * 1.5
        data = data[(data[field] >= Q1 - deta) & (data[field] <= Q3 + deta)]
    return data
data1 = drop_outlier(data, 2, 7)
print("原有样本容量:{0}, 剔除后样本容量:{1}".format(data.shape[0], data1.shape[0]))

#绘制删除部分异常值后六种产品的箱线图
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False 
plt.figure(figsize=(10, 8))
p = data1.boxplot(return_type='dict')
x = p['fliers'][0].get_xdata()
y = p['fliers'][0].get_ydata()
y.sort()
for i in range(len(x)):
    if i>0:
        plt.annotate(y[i], xy = (x[i],y[i]), xytext=(x[i]+0.05 -0.8/(y[i]-y[i-1]),y[i]))
    else:
        plt.annotate(y[i], xy = (x[i],y[i]), xytext=(x[i]+0.08,y[i])) 
plt.show()

#将渠道处理为哑变量
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

from scipy.spatial.distance import cdist
from sklearn.cluster import KMeans  
#存放每次结果的误差平方和
SSE=[]
#尝试不同的K
K_list=range (1, 10) 
for k in K_list:
    clustering=KMeans(n_clusters=k)
    clustering.fit(data2)
    SSE.append(clustering.inertia_)
#使用手肘原则进行判断
plt.xlabel("K")
plt.ylabel("SSE")
plt.plot(K_list,SSE, "o-")
plt.show ()

k = 2   #聚类的类别
iteration = 500  #聚类最大循环次数
model = KMeans(n_clusters = k, max_iter = iteration, random_state = 1234)
model.fit(data2)
r1 = pd.Series(model.labels_).value_counts()  #统计各类别数目
r2 = pd.DataFrame(model.cluster_centers_)  #找出聚类中心
data3= pd.concat([r2,r1],axis =1)  #得到聚类中心对应的类别下的数目
data3.columns = list(data2.columns) + ['类别数目']    #重命名表头
print(data3)

data3= pd.concat([data2, pd.Series(model.labels_,index =data2.index)],axis =1)
data3.columns = list(data2.columns) + ['聚类类别']
data3

# 使用TSNE进行数据降维并展示聚类结果
from sklearn.manifold import TSNE
tsne = TSNE()
tsne.fit_transform(data2)  # 进行数据降维
# tsne.embedding_可以获得降维后的数据
tsn = pd.DataFrame(tsne.embedding_, index=data2.index)  # 转换数据格式 
#tsn = pd.DataFrame(tsne.embedding_, index=data3.index,columns=['Dimension 1', 'Dimension 2'])


import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
# 不同类别用不同颜色和样式绘图
color_style = ['r.', 'go']
for i in range(k):
    d = tsn[data3[u'聚类类别'] == i]
    # dataframe格式的数据经过切片之后可以通过d[i]来得到第i列数据
    plt.plot(d[0], d[1], color_style[i], label='聚类' + str(i+1))
plt.legend()
plt.show()

#聚类结果分析
from pandas.plotting import parallel_coordinates
data4=data3.drop(['聚类类别'],axis=1)
#训练模型
km = KMeans(n_clusters=2, random_state=10)
km.fit(data4)
kmeans_cc = km.cluster_centers_ 
kmeans_labels =  km.labels_ # 样本的类别标签
customer = pd.DataFrame({'0': kmeans_cc[0], "1": kmeans_cc[1]}).T
customer.columns = data4.keys()
df_median = pd.DataFrame({'2': data4.median()}).T
customer = pd.concat([customer, df_median])
customer["category"] = ["客户群0", "客户群1",'median']
#绘制图像
plt.figure(figsize=(12, 6))
parallel_coordinates(customer, "category", colormap='flag')
plt.xticks(rotation = 20)
plt.show()

pd.Series(kmeans_labels).value_counts()   # 统计不同类别样本的数目

data4["kind"]=pd.Series(kmeans_labels)
data5=pd.DataFrame(data4,columns=data4.columns[:6])
data5["kind"]=pd.Series(kmeans_labels)
data5

#绘制小提琴图
column = data4.columns.tolist() # 列表头
fig = plt.figure(figsize=(30, 18), dpi=256)  # 指定绘图对象宽度和高度
for i in range(6):
    plt.subplot(2,3, i + 1)  # 2行3列子图
    ax = sns.violinplot(x='kind',y=column[i],width=0.8,saturation=0.9,lw=0.8,palette="Set2",orient="v",inner="box",data=data5)
    plt.xlabel((['客户群' + str(i) for i in range(2)]),fontsize=20)
    plt.ylabel(column[i], fontsize=36)
plt.show()

#绘制各商品相关性热力图
corr = plt.subplots(figsize = (8,6))
corr= sns.heatmap(data4[column].corr(),annot=True,square=True)

cluster_center = pd.DataFrame(kmeans_cc,columns = ['Fresh','Milk','Grocery','Frozen','Detergents_Paper','Delicassen','Channel_1','Channel_2'])   # 将聚类中心放在数据框中
cluster_center.index = pd.DataFrame(kmeans_labels).drop_duplicates().iloc[:,0]  # 将样本类别作为数据框索引
cluster_center

# 客户分群雷达图
labels = ['Fresh','Milk','Grocery','Frozen','Detergents_Paper','Delicassen','Channel_1','Channel_2']
lstype = ['-','--',(0, (3, 5, 1, 5, 1, 5)),':','-.']
kinds = list(cluster_center.iloc[:, 0])
# 由于雷达图要保证数据闭合，因此再添加L列，并转换为 np.ndarray
cluster_center = pd.concat([cluster_center, cluster_center[['Fresh']]], axis=1)
centers = np.array(cluster_center.iloc[:, 0:])
# 分割圆周长，并让其闭合
n = len(labels)
angle = np.linspace(0, 2 * np.pi, n, endpoint=False)
angle = np.concatenate((angle, [angle[0]]))
labels = np.concatenate((labels, [labels[0]]))
# 绘图
fig = plt.figure(figsize = (8,6))
ax = fig.add_subplot(111, polar=True)  # 以极坐标的形式绘制图形
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号 
# 画线
for i in range(len(kinds)):
    ax.plot(angle, centers[i], linestyle=lstype[i], linewidth=2, label=kinds[i])
# 添加属性标签
ax.set_thetagrids(angle * 180 / np.pi,labels)
plt.title('客户所购产品雷达图')
plt.legend(["客户群0","客户群1"])
plt.show()
plt.close

#聚类结果分析
for i in range(2):
    data3[data3[u'聚类类别']==i].plot(kind='hist', linewidth = 2, subplots = True, sharex = False,layout=(1,data3.shape[1]),figsize=(22,3))
    plt.legend()
plt.show()













