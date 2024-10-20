%第三问预测数据
clc
clear
close all
Result = Test("待预测数据.xlsx")
function Result = Test(fileName)
T = xlsread("所有中心点.xlsx");%"所有中心点.xlsx"
P = [[4,5],[2,3,10],[7,8,9,13],[11]];%分亚类需要考虑的化合物位置
B = zeros(4,2,13);
B(1,:,:) = T(1:1:2,2:1:14);%高钾类风化的两个分类中心坐标数据
B(2,:,:) = T(3:1:4,2:1:14);%高钾类无风化的两个分类中心坐标数据
B(3,:,:) = T(5:1:6,2:1:14);%铅钡类风化的两个分类中心坐标数据
B(4,:,:) = T(10:1:11,2:1:14);%铅钡类无风化的两个分类中心坐标数据
error = 0;
total = 0;
A = xlsread(fileName);%读取给定预测数据
[n,m] = size(A);
for i =1:n
    flag = A(i,16);%获取标记（标记将数据按照风化和高钾/铅钡分成四类）
    p = P(flag);%获取对应类的需要比较的化合物索引
    t1 = GetNorm(p,A(i,2:14),B(flag,1,:));%计算样本与第一类中心的距离
    t2 = GetNorm(p,A(i,2:14),B(flag,2,:));%计算样本与第二类中心的距离
    %做出决定
    if t1>t2
        Result(i) = 1;
    else
        Result(i) = 2;
    end
end

end
function val = GetNorm(p,a,b)
val = 0;
for i=1:length(p)%只计算需要的向量，降低维度
        val = val + (a(1,p(i))-b(1,1,p(i)))*(a(1,p(i))-b(1,1,p(i)));
    end
%     for i=1:13
%         val = val + (a(1,i)-b(1,1,i))*(a(1,i)-b(1,1,i));
%     end
end
