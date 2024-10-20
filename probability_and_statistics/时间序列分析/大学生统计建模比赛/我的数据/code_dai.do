gen lncoe=ln(二氧化碳排放量)
destring IFDI, replace force
destring OFDI, replace force
gen lnifdi=ln(IFDI)
gen lnofdi=ln(OFDI)
gen lnpgdp=ln(人均GDP)

replace IFDI=. if IFDI==0
replace OFDI=. if OFDI==0
carryforward IFDI, gen(ifdit)
carryforward OFDI, gen(ofdit)
gen difdi= sqrt(2*(ifdit*ofdit)/(ifdit+ofdit))
gen lndifdi=ln(difdi)

//缺失值线性差值处理
ipolate lnifdi lnifdit, gen(lnifdix) epolate 
ipolate lnofdi lnofdit, gen(lnofdix) epolate 

encode 省份,gen(PROVINCE)

xtset PROVINCE YEAR

carryforward lnofdi, gen(lnofdit) //填充缺失值
carryforward lnifdi, gen(lnifdit)
carryforward lncoe, gen(lncoet)



tabstat lncoet lnifdit lnofdit lnpgdp lndifdi dlncoet dlnifdit dlnofdit dlnpgdp dlndifdi, s(N mean max min p50 sd) columns(s)

gen dlnpgdp=D.lnpgdp
gen dlnifdit=D.lnifdit
gen dlnofdit=D.lnofdit
gen dlncoet=D.lncoet
gen dlndifdi=D.lndifdi

//LLC检验（原数据+一阶差分）
xtunitroot llc lncoet,trend demean lags(aic)
xtunitroot llc lnifdit,trend demean lags(aic) 
xtunitroot llc lnofdit,trend demean lags(aic) 
xtunitroot llc lnpgdp,trend demean lags(aic) 
xtunitroot llc lndifdi,trend demean lags(aic)
xtunitroot llc dlncoet,trend demean lags(aic)
xtunitroot llc dlnifdit,trend demean lags(aic) 
xtunitroot llc dlnofdit,trend demean lags(aic) 
xtunitroot llc dlnpgdp,trend demean lags(aic) 
xtunitroot llc dlndifdi,trend demean lags(aic) 

//ADF检验（原数据+一阶差分）
xtunitroot fisher lncoet, trend dfuller demean lags(1)
xtunitroot fisher lnifdit, trend dfuller demean lags(1) //
xtunitroot fisher lnofdit, trend dfuller demean lags(1) //
xtunitroot fisher lnpgdp, trend dfuller demean lags(1) //
xtunitroot fisher lndifdi, trend dfuller demean lags(1) //
xtunitroot fisher dlncoet, trend dfuller demean lags(1)
xtunitroot fisher dlnifdit, trend dfuller demean lags(1)
xtunitroot fisher dlnofdit, trend dfuller demean lags(1)
xtunitroot fisher dlnpgdp, trend dfuller demean lags(1) //
xtunitroot fisher dlndifdi, trend dfuller demean lags(1)

//pperron检验（原数据+一阶差分）
xtunitroot fisher lncoet, trend pperron demean lags(1) //
xtunitroot fisher lnifdit, trend pperron demean lags(1) //
xtunitroot fisher lnofdit, trend pperron demean lags(1)
xtunitroot fisher lnpgdp, trend pperron demean lags(1) //
xtunitroot fisher lndifdi, trend pperron demean lags(1) //
xtunitroot fisher dlncoet, trend pperron demean lags(1)
xtunitroot fisher dlnifdit, trend pperron demean lags(1)
xtunitroot fisher dlnofdit, trend pperron demean lags(1)
xtunitroot fisher dlnpgdp, trend pperron demean lags(1)
xtunitroot fisher dlndifdi, trend pperron demean lags(1)

//ht检验（原数据+一阶差分）
xtunitroot ht lncoet,trend demean 
xtunitroot ht lnifdit,trend demean  
xtunitroot ht lnofdit,trend demean
xtunitroot ht lnpgdp,trend demean //
xtunitroot ht lndifdi,trend demean 
xtunitroot ht dlncoet,trend demean 
xtunitroot ht dlnifdit,trend demean  
xtunitroot ht dlnofdit,trend demean
xtunitroot ht dlnpgdp,trend demean 
xtunitroot ht dlndifdi,trend demean 

//ips检验（原数据+一阶差分）
xtunitroot ips lncoet,trend demean 
xtunitroot ips lnifdit,trend demean  
xtunitroot ips lnofdit,trend demean
xtunitroot ips lnpgdp,trend demean //
xtunitroot ips lndifdi,trend demean
xtunitroot ips dlncoet,trend demean 
xtunitroot ips dlnifdit,trend demean  
xtunitroot ips dlnofdit,trend demean
xtunitroot ips dlnpgdp,trend demean 
xtunitroot ips dlndifdi,trend demean 

xtcointtest kao lncoet lnifdi lnofdi lnpgdp
xtcointtest kao lncoet lnifdi lnofdi lnpgdp,demean lags(bic 1) kernel(ba 6)
xtcointtest kao dlncoet dlnifdi dlnofdi dlnpgdp dlndifdi, demean  lags(bic 1) kernel(ba 6)
xtcointtest westerlund lncoet lnifdit lnofdit lnpgdp lndifdi
xtcointtest pedroni lncoet lnifdit lnofdit lnpgdp

//模型最优滞后项的确定
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) soc
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(4) soc
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(3) soc

pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(2) soc

//granger因果检验
//dai
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(2) granger
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(1) granger
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(1) granger

//lu
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(3) granger
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(2) granger
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(2) granger

rename PROVINCE id
rename YEAR year
//脉冲响应 方差分解
xtset id year
helm id year lncoet lnifdit lnofdit lnpgdp
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(2) irf(10)
pvar2 lncoet lnifdit lnofdit lnpgdp,lag(2) decomp(30)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(1) irf(10)
pvar2 dlncoet dlnifdit dlnofdit dlnpgdp,lag(1) decomp(30)
//dai
helm id year lncoet dlnifdit dlnofdit dlnpgdp dlndifdi
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(1) irf(10)
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(1) decomp(30)
//lu
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(2) irf(10)
pvar2 lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lag(2) decomp(30)

//GMM估计
pvar lncoet lnifdit lnofdit lnpgdp,lags(3)
pvar dlncoet dlnifdit dlnofdit dlnpgdp,lags(2)
//dai
pvar lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lags(2)
//lu
pvar lncoet dlnifdit dlnofdit dlnpgdp dlndifdi,lags(2)


pvarsoc lncoet lnifdit lnofdit lnpgdp,maxlag(4) pvaropts(instl(1/5))
pvarsoc lncoet lnifdit lnofdit lnpgdp, pinstl(1/5)

pvarstable,graph



xtset id year
helm id year lncoet lndifdi lnifdit lnofdit lnpgdp
pvar2 lncoet lnpgdp lnifdit lnofdit,lag(1) irf(10)
pvar2 lncoet lndifdi lnpgdp lnifdit lnofdit,lag(1) decomp(30)
pvar lncoet lndifdi lnpgdp lnifdit lnofdit,lags(2)

xtset id year
helm id year lncoet lndifdi lnifdit lnofdit lnpgdp
pvar2 dlncoet dlndifdi dlnpgdp dlnifdit dlnofdit,lag(2) irf(10)
pvar2 dlncoet dlndifdi dlnpgdp dlnifdit dlnofdit,lag(2) decomp(30)
pvar dlncoet dlndifdi dlnpgdp dlnifdit dlnofdit,lags(2)


