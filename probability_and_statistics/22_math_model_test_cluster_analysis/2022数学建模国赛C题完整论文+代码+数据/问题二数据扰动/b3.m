fName = ["高钾类风化","高钾类无风化","铅钡类风化","铅钡类无风化"];
val = [1,2,5,10,20,30,50,100];
for i=1:length(val)
    percent = val(i);
    dir = "rand" + percent;
    mkdir(dir);
    for t=1:4
        fname = fName(t) + ".xlsx";
        %target = fullfile
        copyfile(fname,dir);
        fname = dir + "/" + fname;
        A = xlsread(fname);
        [n,m] = size(A);
        R = rand(n,m-3).*0.01*percent + 1-percent*0.005;
        A(:,3:m-1) = A(:,3:m-1).*R;
        A(:,m) = sum(A(:,3:m-1),2);
        xlswrite(fname,A,"E2:U" + (n+1));
    end
end