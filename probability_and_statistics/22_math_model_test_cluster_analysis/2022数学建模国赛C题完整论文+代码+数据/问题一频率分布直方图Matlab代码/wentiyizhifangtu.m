clc
clear
close all
fName = ["GKN.xlsx","GKF.xlsx","KBN.xlsx","KBF.xlsx"];
yLabels = ["高钾类未风化","高钾类风化","铅钡类未风化","铅钡类风化"];
xLabels = ["二氧化硅(SiO2)","氧化钾(K2O)","氧化钙(CaO)","氧化铝(Al2O3)","氧化铁(Fe2O3)","氧化铜(CuO)","五氧化二磷(P2O5)"];
for t=1:4
    A = xlsread(fName(t));
    [n,m] = size(A);
    
    idx = [2,4,5,7,8,9,12]
    for k=1:length(idx)
        for i = 1:n
            x(i)=A(i,idx(k));
        end
        
        picPos = k + (t-1)*7;
        subplot(4,7,picPos);
       
        
        h = histogram(x,5)
        if t ==2 || t == 4
            h.FaceColor = [0.1 0.1 0.5];
            h.EdgeColor = 'r';
        end
        hold on
        
        [counts,centers] = hist(x,5);
        x2 = centers(1)*0.5:((centers(end)-centers(1)))/1000:centers(end)*1.5;
        
        [mu,sigma]=normfit(x);%用正态分布拟合出平均值和标准差
        delta = centers(2)-centers(1);
        y2 = pdf('Normal', x2, mu,sigma)*10;%求在x2处的pdf值
        
        axis([centers(1)-delta,centers(end)+delta,0,max(counts)+0.5]);%限定x坐标范围
        
        hh = plot(x2,y2)
        set(hh,'LineWidth',5);
        
        if picPos==4
            title("不同玻璃类型风化前后不同化学成分频率分布直方图")
        end
        if t==4
           xlabel(xLabels(k)); 
        end
        if k==1
           ylabel(yLabels(t));
        end
    end
end