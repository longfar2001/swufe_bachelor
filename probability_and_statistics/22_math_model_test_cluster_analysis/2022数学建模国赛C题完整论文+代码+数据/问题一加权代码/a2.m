clc
clear
close all
fName = ["GKN.xlsx","GKF.xlsx","KBN.xlsx","KBF.xlsx"];
average = zeros(4,16);
for t=1:4
    A = xlsread(fName(t));
    [n,m] = size(A);
    for i = 1:m
       temp = sort(A(:,i));
       ave = 0;
       sum = 0;
       for j=1:n
           alpha = normpdf((j/n-0.5)*3);
           ave = ave + temp(j)*alpha;
           sum = sum + alpha;
       end
       ave = ave / sum;
       average(t,i)=ave;
    end
    
end
average