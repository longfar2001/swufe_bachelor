import numpy as np #linear algebra 
import pandas as pd #creating and manipulating dataframes
import matplotlib.pyplot as plt #visuals
import seaborn as sns #visuals

from sklearn.cluster import KMeans #K-Means
from sklearn.cluster import DBSCAN #DBSCAN

from sklearn.preprocessing import StandardScaler #scaler

blobs = pd.read_csv('cluster_blobs.csv')


def display_categories(model,data):
    labels = model.fit_predict(data)
    plt.figure(figsize = (8,4), dpi = 100)
    sns.scatterplot(data=data,x='X1',y='X2',hue=labels,palette='Set1')
    plt.show()
    
model = DBSCAN(eps=0.6)
display_categories(model,blobs)

df = pd.read_csv('Wholesale customers data.csv')

df.head()

scaler = StandardScaler()
scaled_X = scaler.fit_transform(df)



outlier_percent = []

for eps in np.linspace(0.001,3,50):
    
    # Create Model
    dbscan = DBSCAN(eps=eps,min_samples=2*scaled_X.shape[1])
    dbscan.fit(scaled_X)
   
     
    # Log percentage of points that are outliers
    perc_outliers = 100 * np.sum(dbscan.labels_ == -1) / len(dbscan.labels_)
    
    outlier_percent.append(perc_outliers)

dbscan = DBSCAN(eps=2)
dbscan.fit(scaled_X)










