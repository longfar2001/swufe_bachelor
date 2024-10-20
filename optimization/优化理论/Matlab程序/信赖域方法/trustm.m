function [xk,val,k]=trustm(x0)
%����: ţ���������򷽷������Լ���Ż����� min f(x)
%����: x0�ǳ�ʼ������
%���: xk�ǽ��Ƽ�С��, val�ǽ��Ƽ�Сֵ, k�ǵ�������
n=length(x0);  x=x0; dta=1;
eta1=0.15; eta2=0.75;  dtabar=2.0;
tau1=0.5; tau2=2.0; epsilon=1e-6;
k=0;  Bk=Hess(x);  %Bk=eye(n);  
while(k<150)
    gk=gfun(x);   
    if(norm(gk)<epsilon)
        break;
    end
    [d,val,lam,ik]=trustq(gk,Bk,dta);
    deltaq=-qk(x,d);
    deltaf=fun(x)-fun(x+d);
    rk=deltaf/deltaq;
    if(rk<=eta1)
        dta=tau1*dta;
    else if (rk>=eta2&norm(d)==dta)
            dta=min(tau2*dta,dtabar);
        else
            dta=dta;
        end
    end
    if(rk>eta1)
        x0=x;     x=x+d;    
       % sk=x-x0;  yk=gfun(x)-gfun(x0);  
        %vk=sqrt(yk'*Bk*yk)*(sk/(sk'*yk)-Bk*yk/(yk'*Bk*yk));
        %Bk=Bk-Bk*yk*yk'*Bk/(yk'*Bk*yk)+sk*sk'/(sk'*yk)+vk*vk'
        %pause
        Bk=Hess(x);
    end
    k=k+1;
end
xk=x;
val=fun(xk);
%%% Ŀ�꺯��  %%%%%%%%%%%%%%%
function f=fun(x)
 f=100*(x(1)^2-x(2))^2+(x(1)-1)^2;
 %%% ������Ŀ�꺯�� %%%%%%%%%%%%%
function qd=qk(x,d)
gk=gfun(x);  Bk=Hess(x);
qd=gk'*d+0.5*d'*Bk*d;
%%% Ŀ�꺯�����ݶ� %%%%%%%%%%%%%%
function gf=gfun(x)
gf=[400*x(1)*(x(1)^2-x(2))+2*(x(1)-1), -200*(x(1)^2-x(2))]';
%%% Ŀ�꺯����Hesse�� %%%%%%%%%%%%%%
function He=Hess(x)
n=length(x);
He=zeros(n,n);
He=[1200*x(1)^2-400*x(2)+2, -400*x(1); 
         -400*x(1),                         200        ];
