gen lncoe=ln(二氧化碳排放量)
destring IFDI, replace force
gen lnifdi=ln(IFDI)
gen lnofdi=ln(OFDI)
gen lnpgdp=ln(人均GDP)

encode 省份,gen(PROVINCE)
xtset PROVINCE YEAR //设置面板数据

***
tsfill
ipolate lnofdi YEAR,gen(lnofdis) //填充缺失值

carryforward lnofdi, gen(lnofdit) //填充缺失值
carryforward lnifdi, gen(lnifdit)
carryforward lncoe, gen(lncoet)
*固定效应回归
xtreg lncoe lnifdit lnofdit lnpgdp,fe
*随机效应
xtreg lncoe lnifdit lnofdit lnpgdp,re

xttest0  //BP检验，用以判断随机效应和混合回归哪个好

*在做hausman检验之前需要对回归结果存储，前面加qui表示不显示回归结果
qui xtreg lncoe lnifdit lnofdit lnpgdp,fe
est store fe
qui xtreg lncoe lnifdit lnofdit lnpgdp,re
est store re
hausman fe re

*描述性统计
tabstat lncoet lnifdit lnofdit lnpgdp , s(N mean max min p50 sd) columns(s)

*面板单位根检验
//同根情形下，LLC检验，异根情形下，ADF-fisher检验,pp-fisher检验
//LLC检验 
//加入时间趋势项 //拒绝单位根，面板是平稳的
//aic准则自动选择滞后阶数
xtunitroot llc lncoet,trend demean lags(aic)                   
//没有趋势项
xtunitroot llc lncoet,demean lags(bic 10)
//没有常数项
xtunitroot llc lncoet, noconstant demean lags(bic 10)
//由图得lncoet是波动的
xtline lncoet, overlay

//LLC检验（原数据+一阶差分）
xtunitroot llc lncoet,trend demean lags(aic)
xtunitroot llc lnifdit,trend demean lags(aic) 
xtunitroot llc lnofdit,trend demean lags(aic) 
xtunitroot llc lnpgdp,trend demean lags(aic) 
xtunitroot llc dlncoet,trend demean lags(aic)
xtunitroot llc dlnifdit,trend demean lags(aic) 
xtunitroot llc dlnofdit,trend demean lags(aic) 
xtunitroot llc dlnpgdp,trend demean lags(aic) 
***

//HQIC准则确定最优滞后阶数
xtunitroot llc lnpgdp,trend demean lags(hqic) 
//一般依据取值最小的准则确定
xtunitroot llc lnpgdp,trend demean lags(bic) 

//ADF检验（原数据+一阶差分）
xtunitroot fisher lncoet, trend dfuller demean lags(1)
xtunitroot fisher lnifdit, trend dfuller demean lags(1)
xtunitroot fisher lnofdit, trend dfuller demean lags(1)
xtunitroot fisher lnpgdp, trend dfuller demean lags(1)
xtunitroot fisher dlncoet, trend dfuller demean lags(1)
xtunitroot fisher dlnifdit, trend dfuller demean lags(1)
xtunitroot fisher dlnofdit, trend dfuller demean lags(1)
xtunitroot fisher dlnpgdp, trend dfuller demean lags(1)

//pperron检验（原数据+一阶差分）
xtunitroot fisher lncoet, trend pperron demean lags(1)
xtunitroot fisher lnifdit, trend pperron demean lags(1)
xtunitroot fisher lnofdit, trend pperron demean lags(1)
xtunitroot fisher lnpgdp, trend pperron demean lags(1)
xtunitroot fisher dlncoet, trend pperron demean lags(1)
xtunitroot fisher dlnifdit, trend pperron demean lags(1)
xtunitroot fisher dlnofdit, trend pperron demean lags(1)
xtunitroot fisher dlnpgdp, trend pperron demean lags(1)

//ht检验（原数据+一阶差分）
xtunitroot ht lncoet,trend demean 
xtunitroot ht lnifdit,trend demean  
xtunitroot ht lnofdit,trend demean
xtunitroot ht lnpgdp,trend demean 
xtunitroot ht dlncoet,trend demean 
xtunitroot ht dlnifdit,trend demean  
xtunitroot ht dlnofdit,trend demean
xtunitroot ht dlnpgdp,trend demean 

//ips检验（原数据+一阶差分）
xtunitroot ips lncoet,trend demean 
xtunitroot ips lnifdit,trend demean  
xtunitroot ips lnofdit,trend demean
xtunitroot ips lnpgdp,trend demean 
xtunitroot ips dlncoet,trend demean 
xtunitroot ips dlnifdit,trend demean  
xtunitroot ips dlnofdit,trend demean
xtunitroot ips dlnpgdp,trend demean 

//一阶差分
gen dlnpgdp=D.lnpgdp
xtunitroot llc dlnpgdp,trend demean lags(bic)
gen dlnifdit=D.lnifdit
gen dlnofdit=D.lnofdit
gen dlncoet=D.lncoet
***

//协整检验 
//kao检验 westerlund检验 pedroni检验
xtcointtest kao lncoet lnifdi lnofdi lnpgdp
xtcointtest kao lncoet lnifdi lnofdi lnpgdp,demean lags(bic 1) kernel(ba 6)
*
xtcointtest kao lncoet lnifdit lnofdit lnpgdp 
xtcointtest kao lncoet lnifdit lnpgdp
xtcointtest kao lncoet lnofdit lnpgdp
xtcointtest kao lncoet lnifdit lnofdit
xtcointtest westerlund lncoet lnifdit lnofdit lnpgdp
xtcointtest westerlund lncoet lnifdi lnofdi lnpgdp,trend
xtcointtest pedroni lncoet lnifdit lnofdit lnpgdp
xtcointtest pedroni lncoet lnifdit lnofdit lnpgdp,ar(same)

//模型最优滞后项的确定
set matsize 11000
pvarsoc lncoet lnifdit lnofdit lnpgdp,maxlag(4) pvaropts(instl(1/5))
pvarsoc lncoet lnifdit lnofdit lnpgdp, pinstl(1/5)
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(4) soc
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(4) soc

//granger因果检验
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(5) granger
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(2) granger
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(4) granger
***
//GMM估计 脉冲响应 方差分解
//将个体变量的变量名更改为系统可以识别的形式id
rename PROVINCE id
//将时间变量的变量名更改为系统可以识别的形式year
rename YEAR year
//将数据改为面板数据
xtset id year
//赫尔默特变换数据以消除固定效果
helm id year lncoet lnifdit lnofdit lnpgdp
helm id year dlncoet dlnifdit dlnofdit dlnpgdp
//m脉冲响应，前期确定的最优滞后阶
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) irf(10)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(2) irf(10)
pvar2 ddlncoet ddlnifdit ddlnofdit ddlnpgdp,lag(2) irf(10)
//方差分解
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) decomp(10)
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) decomp(20)
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) decomp(30)

carryforward dlnofdit, gen(ddlnofdit) //填充缺失值
carryforward dlnifdit, gen(ddlnifdit)
carryforward dlncoet, gen(ddlncoet)
carryforward dlnpgdp, gen(ddlnpgdp)
//差分数据方差分解
pvar2 ddlncoet ddlnifdit ddlnofdit ddlnpgdp,lag(3) decomp(10)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(3) decomp(10)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(3) decomp(20)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(3) decomp(30)

**GMM估计
pvar lncoet lnifdit lnofdit lnpgdp,lags(1)
pvar dlncoet dlnifdit dlnofdit dlnpgdp,lags(4)
pvar lncoet lnifdi lnofdi lnpgdp,lags(3)
pvargranger
//稳健型检验
pvarstable,graph
graph save fig1.gph,replace


