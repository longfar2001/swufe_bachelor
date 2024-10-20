clc;clear;% 清空
A=xlsread('高钾类未风化数据-K均值++聚类');
% A=xlsread('高钾类风化数据-K均值++聚类');
% A=xlsread('铅钡类未风化数据-K均值++聚类');
% A=xlsread('铅钡类风化数据-K均值++聚类');
%导入数据，注意：必须将数据与代码文件放在同一个文件夹下
% 使用指定范围选择最佳簇个数(K 值)
fh = @(X,K)(kmeans(X,K));
eva = evalclusters(A,fh,"CalinskiHarabasz","KList",2:5);
clear fh
K = eva.OptimalK;
clusterIndices = eva.OptimalY;

% 显示簇计算标准值
figure
bar(eva.InspectedK,eva.CriterionValues);
xticks(eva.InspectedK);
xlabel("分类数目");
ylabel("分类评价指标-CH值");
legend("最优分类数目是" + num2str(K));
title("簇计算标准值图");
disp("最优分类数目是" + num2str(K));
% clear eva

% 计算质心
centroids = grpstats(A,clusterIndices,"mean");

% 显示结果

% 显示二维散点图(PCA)
figure
[~,score] = pca(A);
clusterMeans = grpstats(score,clusterIndices,"mean");
h = gscatter(score(:,1),score(:,2),clusterIndices,colormap("lines"));
for i = 1:numel(h)
    h(i).DisplayName = strcat("类型",h(i).DisplayName);
end
clear h i score
hold on
h = scatter(clusterMeans(:,1),clusterMeans(:,2),50,"kx","LineWidth",2);
hold off
h.DisplayName = "聚类方法";
clear h clusterMeans
legend;
title("二维散点图(PCA)");
xlabel("第一主成分");
ylabel("第二主成分");

% 矩阵图
figure
selectedCols = sort([1,2]);
[~,ax] = gplotmatrix(A(:,selectedCols),[],clusterIndices,colormap("lines"),[],[],[],"grpbars");
title("集群数据中列的比较");
clear K
clusterMeans = grpstats(A,clusterIndices,"mean");
hold(ax,"on");
for i = 1 : size(selectedCols,2)
  for j = 1 : size(selectedCols,2)
      if i ~= j  
          scatter(ax(j,i),clusterMeans(:,selectedCols(i)),clusterMeans(:,selectedCols(j)), ...
            50,"kx","LineWidth",1.5,"DisplayName","聚类方法");
          xlabel(ax(size(selectedCols,2),i),("列" + selectedCols(i)));
          ylabel(ax(i,1),("列" + selectedCols(i)));
      end
   end
end
clear ax clusterMeans i j selectedCols

% clusterIndices = eva.OptimalY;% 聚类标签
% 计算其他评价标准
eva_CHI=max(eva.CriterionValues);%CHI指数
eva2 = evalclusters(A,clusterIndices,"DaviesBouldin");%Davies-Bouldin准则
eva_DBI=eva2.CriterionValues;% DBI指数
eva3 = evalclusters(A,clusterIndices,"silhouette");%轮廓准则
eva_SC=eva3.CriterionValues;% 轮廓系数
%% *优化前后聚类效果指标输出*

disp(['-----------------------','优化前评价指标','--------------------------'])
disp(['K-means++聚类CHI指数：',num2str(eva_CHI)])
%CHI指标是数据集的分离度与紧密度的比值，
% 以各类中心点与数据集的中心点的距离平方和来度量数据集的分离度，
% 以类内各点与其类中心的距离平方和来度量数据的紧密度。
% 聚类效果越好，类间差距应该越大，类内差距越小，即类自身越紧密，
% 类间越分散，CH指标值越大聚类效果越好。
disp(['K-means++聚类DBI指数：',num2str(eva_DBI)])
%评价指标：Davies-Bouldin 准测基于簇内和簇间距离的比率，
% 最优聚类解决方案具有最小的 Davies-Bouldin 指数值（DBI）（越小越好）
disp(['K-means++聚类轮廓系数：',num2str(eva_SC)])
%轮廓系数评价指标说明：轮廓系数的取值在[-1,1]之间，
% 越趋近于1代表内聚度和分离度都相对较优，即聚类效果越好。
% （当簇内只有一点时，我们定义轮廓系数s(i)为0）

