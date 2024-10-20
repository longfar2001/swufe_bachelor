val = [1,2,5,10,20,30];
TrueResult = [2,1,1,2,1,1,2,2];
%生成扰动数据
for i=1:length(val)
    percent = val(i);
    dir = "rand" + percent;
    mkdir(dir);
    
    fname = "待预测数据.xlsx";
    %备份数据
    copyfile(fname,dir);
    fname = dir + "/" + fname;
    A = xlsread(fname);
    [n,m] = size(A);
    R = rand(n,m-2).*0.01*percent + 1-percent*0.005;%生成扰动矩阵
    A(:,1:m-2) = A(:,1:m-2).*R;%将扰动作用到原始数据上
    xlswrite(fname,A,"C2:R" + (n+1));%写进excel文件
end
pause(1);
%测试扰动数据
error = 0;
total = 0;
for i=1:length(val)
    percent = val(i);
    dir = "rand" + percent;
    fname = dir + "/待预测数据.xlsx";
    
    Result = Test(fname);
    for j=1:length(Result)
       if Result(j)~=TrueResult(j)
           error = error + 1;
       end
       total = total +1;
    end
    CorP(i) = (1 - error/total)*100;
end
CorP
function Result = Test(fileName)
T = xlsread("所有中心点.xlsx");%"所有中心点.xlsx"
P = [[4,5],[2,3,10],[7,8,9,13],[11]];
B = zeros(4,2,13);
B(1,:,:) = T(1:1:2,2:1:14);%高钾类风化
B(2,:,:) = T(3:1:4,2:1:14);%高钾类无风化
B(3,:,:) = T(5:1:6,2:1:14);%铅钡类风化
B(4,:,:) = T(10:1:11,2:1:14);%铅钡类无风化
error = 0;
total = 0;
A = xlsread(fileName);%"待预测数据.xlsx"
[n,m] = size(A);
for i =1:n
    flag = A(i,16);
    p = P(flag);
    t1 = GetNorm(p,A(i,2:14),B(flag,1,:));
    t2 = GetNorm(p,A(i,2:14),B(flag,2,:));
    if t1>t2
        Result(i) = 1;
    else
        Result(i) = 2;
    end
end

end
function val = GetNorm(p,a,b)
val = 0;
for i=1:length(p)
        val = val + (a(1,p(i))-b(1,1,p(i)))*(a(1,p(i))-b(1,1,p(i)));
    end
%     for i=1:13
%         val = val + (a(1,i)-b(1,1,i))*(a(1,i)-b(1,1,i));
%     end
end
