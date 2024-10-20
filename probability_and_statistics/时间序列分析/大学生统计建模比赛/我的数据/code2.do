//使用GMM-style instruments
pvar lncoet lnifdit lnofdit lnpgdp, instlags(1/3)
//使用GMMde option选项
pvar lncoet lnifdit lnofdit lnpgdp, instlags(1/3) gmmstyle
pvar2 lncoet lnifdit lnofdit lnpgdp
pvarsoc lncoet lnifdit lnofdit lnpgdp
pvargranger
pvarstable,graph


































