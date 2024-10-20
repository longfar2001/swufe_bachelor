clc
clear
close all
fName = ["高钾类风化.xlsx","高钾类无风化.xlsx","铅钡类风化.xlsx","铅钡类无风化.xlsx"];
dicName = [1,2,5,10,20,30];
T = xlsread("所有中心点.xlsx");
P = [[4,5],[2,3,10],[7,8,9,13],[11]];
B = zeros(4,2,13);
B(1,:,:) = T(1:1:2,2:1:14);%高钾类风化
B(2,:,:) = T(3:1:4,2:1:14);%高钾类无风化
B(3,:,:) = T(5:1:6,2:1:14);%铅钡类风化
B(4,:,:) = T(10:1:11,2:1:14);%铅钡类无风化
error = 0;
total = 0;
for t=1:4
    p = P(t);
    A = xlsread(fName(t));
    [n,m] = size(A);
    Data = A(:,4:m-1);
    for i=1:n      
       t1 = GetNorm(p,Data(i,:),B(t,1,:));
       t2 = GetNorm(p,Data(i,:),B(t,2,:));
       if t1>t2
           Result(t,i) = 1;
       else
           Result(t,i) = 2;
       end
    end
    for j = 1:length(dicName)
        D =  xlsread( "扰动后数据\rand" + dicName(j) + "\" + fName(t));
        [n,m] = size(D);
        Data = D(:,4:m-1);
        for ii=1:n
            t1 = GetNorm(p,Data(ii,:),B(t,1,:));
            t2 = GetNorm(p,Data(ii,:),B(t,2,:));
            if t1>t2
                res = 1;
            else
                res = 2;
            end
            if res ~= Result(t,ii)
                error = error + 1;
            end
            total = total + 1;
        end
        
        er(t,j) =(1- error/total)*100;
        total = 0;
        error = 0;
    end
end
er

function val = GetNorm(p,a,b)
    val = 0;
    for i=1:length(p)
        val = val + (a(1,p(i))-b(1,1,p(i)))*(a(1,p(i))-b(1,1,p(i)));
    end
%     for i=1:13
%         val = val + (a(1,i)-b(1,1,i))*(a(1,i)-b(1,1,i));
%     end
end
