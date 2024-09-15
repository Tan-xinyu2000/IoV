cd "E:\STATA_IOV"
//import excel drivingdata.xlsx,firstrow 
//save paper.dta,replace 
clear
import excel eng317.xlsx,firstrow
save papereng.dta,replace 

use papereng.dta,clear
describe

log using IOV.log,replace

* 旧内容
*男1 女0
//在实验中，group、lpnumber、date暂时不需要
/*sktest gender
sktest accident
sktest drivingexp
sktest gcons
sktest log_gasoline 
sktest drivingscore
sktest app_usage  
sktest Speed_KMH 
sktest log_g_1 
sktest log_co2_1 
sktest log_totalm_1 
sktest log_time_1 
sktest log_acc_1 
sktest log_deacc_1 
sktest log_turn_1 
sktest log_ndri_1
sktest CO2emission 
sktest rapid_deacc
sktest rapid_acc
sktest time 
sktest mileage 
sktest totalm
sktest sharp_turn 
sktest nightdriving
sktest fatigdriving //这个不符合正态分布
sktest sudden_change
sktest dangerous_action

qladder fatigdriving

summarize drivingexp

age gender accident drivingexp gcons 
//log_gasoline CO2emission log_co2  mileage totalm log_totalm 
//time log_time  rapid_acc log_acc rapid_deacc log_deacc sharp_turn 
//log_turn fatigdriving nightdriving log_ndri 
drivingscore app_usage  Speed_KMH log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
*/
//删除了age等变量
asdoc regress drivingscore ranking alert  totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust
//gcons
//删除空值行
asdoc regress drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust

log close

log using IOV2.log,replace
regress drivingscore ranking alert gender drivingexp gcons rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust


regress drivingscore ranking alert  totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust
estat vif //全部显著，R方0.59

asdoc regress drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, robust
estat vif //存在共线性，R方0.64，并非全部显著

//逐步回归  全部显著，R方0.62
sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, pr(0.05)
estat vif

asdoc sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, pe(0.05)
asdoc estat vif

//下面这个很好  全部显著，R方0.49
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, robust
estat vif
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
estat vif

//log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_totalm_1 Speed_KMH rapid_acc rapid_deacc log_turn_1 log_ndri_1
estat vif  //R方0.46
log close









*2021.09.12
*----------drivingscore-------- 

//所有变量(除去CO2、mileage、time)逐步回归
//3 原始变量(跟上面那个逐步回归结果一样)，但是有变量重复，不科学
sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, pr(0.05)
estat vif
//3.1 删除重复的变量（最后移除了alert和ranking，不行）
sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1, pr(0.05)
estat vif
//4 换为dangerous_action R方0.46，全显著，剔除了drivingexp和app_usage
asdoc sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH dangerous_action nightdriving app_usage log_time_1, pr(0.05)
estat vif //无共线 均1.73

//手动放变量
//5.1 -drivingexp->totalm 
regress drivingscore ranking alert age gender accident gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage 
estat vif //no, ranking alert app_usage不显著
//5.2 5.1+交互效应
asdoc regress drivingscore ranking alert age gender accident gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//5.3 5.2-age gender accident 比5.2效果好
asdoc regress drivingscore ranking alert gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//5.4 5.3-gcons 实现5.3的全部显著 0.595
asdoc regress drivingscore ranking alert totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//5.5 使用dangerous_action  alert-0.051不够显著，R方0.5，
asdoc regress drivingscore ranking alert totalm Speed_KMH dangerous_action nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//5.6 5.5+gcons 全部显著，R方0.53
asdoc regress drivingscore ranking alert gcons totalm Speed_KMH dangerous_action nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//5.7 5.6+age gender accident 结果拉跨 R方0.45，还有四五个不显著的
regress drivingscore ranking alert age gender accident gcons totalm Speed_KMH dangerous_action nightdriving app_usage c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif
//5.8 无age gender accid,去除app_usage,用dangerous_action
asdoc regress drivingscore ranking alert gcons totalm Speed_KMH dangerous_action nightdriving c.totalm#ranking c.totalm#alert
estat vif //no 全部显著，但是没有app_usage,R 0.529,略逊于5.6
//5.9 5.8 dagerous展开。gcons和c.total#alert不显著，R方0.59
asdoc 
regress drivingscore ranking alert gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.totalm#ranking c.totalm#alert
estat vif 
//5.10 5.9+app_usage  gcons不显著，R 0.595
asdoc regress drivingscore ranking alert app_usage gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif 
//5.11 5.10-gcons  全显著，R 0.595
asdoc regress drivingscore ranking alert app_usage totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif 

//regress drivingscore ranking alert gcons app_usage totalm Speed_KMH dangerous_action nightdriving去除交互效应R方降低，所以不用了

regress drivingscore dangerous_action
regress drivingscore c.dangerous_action#c.dangerous_action
gen lnd = log(dangerous_action+1)
regress drivingscore lnd   //R方较低，但是显著相关

*---------------dangerou_action作因变量----------------
//6 不加交互变量，最全，逐步回归 剔除app_usage accident speed_kmh totalm,全显著，但R方0.366
asdoc sw reg dangerous_action ranking alert app_usage gcons totalm age gender accident Speed_KMH nightdriving, pr(0.05)
estat vif

//6.1 手动添加
//全变量+全交互项
regress dangerous_action ranking alert app_usage gcons totalm age gender accident Speed_KMH c.Speed_KMH#app_usage c.Speed_KMH#ranking c.Speed_KMH#alert nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif  //vif出问题了，c.speed_kmh的几个和app的变量
//看app功能与speedkmh的关系 发现单独之间相关性不强
//删除，看vif
regress dangerous_action ranking alert app_usage gcons totalm age gender accident Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no  app_u#c.totalm、accident不显著，R方0.38
//6.1.1 删除方式1，0.39，全显著
asdoc regress dangerous_action ranking alert app_usage gcons totalm age gender Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#ranking c.totalm#alert
estat vif
//6.1.2 删除方式2，结果与6.1.1基本一致
regress dangerous_action ranking alert gcons totalm age gender Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif
//6.2 感觉gcons不好解释，删掉.虽然也全部显著，但是R方0.24，比6.1差
asdoc regress dangerous_action ranking alert app_usage totalm age gender Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#ranking c.totalm#alert
estat vif
//6.3 去掉age gender R方0.51，但是好几个不显著的自变量
asdoc regress dangerous_action ranking alert gcons totalm Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif


*-------------------------gcons-------------------------
//7 不加交互变量，最全，逐步回归 剔除ranking,全显著，但R方0.61
asdoc sw reg gcons ranking alert app_usage totalm age gender accident Speed_KMH dangerous_action nightdriving, pr(0.05)
estat vif //no
//7.1 dangerous_action展开 0.72，啥都没剔除,good
asdoc sw reg gcons ranking alert app_usage totalm age gender accident Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving, pr(0.05)
estat vif
//7.2 加交互项,R方0.736，但有几个appusage相关不显著
asdoc regress gcons ranking alert app_usage totalm age gender accident Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif //no
//7.3 删除不显著的一些项 0.736 alert不显著
asdoc regress gcons ranking alert totalm age gender accident Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.nightdriving#ranking c.nightdriving#alert c.totalm#ranking c.totalm#alert
estat vif
//7.3.1 删除alert R方不变
asdoc 
//7.3.2 删ranking
regress gcons alert app_usage totalm age gender accident Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.nightdriving#app_usage c.nightdriving#alert c.totalm#alert c.totalm#app_usage
estat vif
//将危险驾驶用合并的dangerous_action,全显著，但是R方降低变成0.63
regress gcons ranking totalm age gender accident Speed_KMH dangerous_action nightdriving  c.nightdriving#alert c.totalm#ranking c.totalm#alert
estat vif


*----------------因变量为疲劳驾驶/sudden_change-----------------------
//8 remove accident R方0.28
sw reg fatigdriving ranking alert app_usage totalm age gender accident Speed_KMH nightdriving,pr(0.05)
estat vif
//8.1 加交互项 R方0.28，totalm不显著
asdoc regress fatigdriving ranking alert age gender totalm Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#alert c.totalm#app_usage c.totalm#ranking
estat vif

//9 --app_usage totalm accident Speed_KMH  R方0.36
asdoc sw reg sudden_change ranking alert app_usage gcons totalm age gender accident Speed_KMH fatigdriving nightdriving,pr(0.05)
estat vif
//9.1 加交互项 
regress sudden_change ranking alert app_usage gcons totalm age gender Speed_KMH fatigdriving c.fatigdriving#app_usage c.fatigdriving#ranking c.fatigdriving#alert nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif
//删除一些项（无疲劳驾驶了）
regress sudden_change ranking alert app_usage gcons totalm age gender Speed_KMH nightdriving c.nightdriving#app_usage c.nightdriving#ranking c.nightdriving#alert c.totalm#ranking c.totalm#alert
estat vif
//10
regress drivingscore totalm gcons Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif 

regress drivingscore ranking alert app_usage gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving c.totalm#app_usage c.totalm#ranking c.totalm#alert
estat vif 
//rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving 
regress drivingscore nightdriving mileage Speed_KMH c.mileage#app_usage c.mileage#alert c.nightdriving#app_usage c.nightdriving#alert c.Speed_KMH#app_usage c.Speed_KMH#alert
estat vif 
regress drivingscore nightdriving time Speed_KMH fatigdriving c.nightdriving#app_usage c.nightdriving#alert c.Speed_KMH#app_usage c.Speed_KMH#alert
estat vif 


//gcons 因变量 删7.3.2 accident和危险驾驶行为使alert显著，不能删Time,不好换log
regress gcons alert app_usage totalm age gender Speed_KMH time fatigdriving c.totalm#alert c.totalm#app_usage
estat vif //这个可 1
regress gcons alert app_usage totalm age gender Speed_KMH fatigdriving c.totalm#alert c.totalm#app_usage
estat vif
regress gcons alert app_usage totalm age gender Speed_KMH log_time_1 fatigdriving c.totalm#alert c.totalm#app_usage
estat vif
//11  这个也可 2
asdoc regress gcons alert app_usage totalm age gender Speed_KMH time fatigdriving rapid_acc rapid_deacc sharp_turn c.totalm#alert c.totalm#app_usage
estat vif

//drivingscore
regress drivingscore alert app_usage totalm age gender Speed_KMH time fatigdriving c.totalm#alert c.totalm#app_usage
estat vif
regress drivingscore alert app_usage totalm age gender Speed_KMH time c.totalm#alert c.totalm#app_usage
estat vif

//sudden_change
sw reg sudden_change ranking alert app_usage gcons totalm age gender accident time Speed_KMH fatigdriving nightdriving,pr(0.05)
estat vif

regress sudden_change alert app_usage gcons totalm age gender accident time Speed_KMH fatigdriving nightdriving
estat vif
regress sudden_change ranking alert app_usage gcons totalm age gender accident time Speed_KMH fatigdriving nightdriving c.totalm#alert c.totalm#app_usage c.fatigdriving#alert c.fatigdriving#app_usage c.nightdriving#alert c.nightdriving#app_usage
estat vif
regress accident alert app_usage gcons totalm age gender time Speed_KMH fatigdriving nightdriving
estat vif


*-------------------------10.4 重新讨论----------------------------------

//所有危险驾驶行为与alert app_usage相乘
regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.rapid_deacc#alert c.sharp_turn#alert c.totalm#alert c.fatigdriving#app_usage c.rapid_acc#app_usage c.rapid_deacc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

//消除共线
regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.sharp_turn#alert c.totalm#alert c.fatigdriving#app_usage c.rapid_acc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

//只看alert
regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.sharp_turn#alert c.totalm#alert totalm age gender Speed_KMH time
estat vif

//只看app_usage
regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#app_usage c.rapid_acc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

//去掉age gender speed   R方0.9245
regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.sharp_turn#alert c.totalm#alert c.fatigdriving#app_usage c.rapid_acc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm time
estat vif

//自变量同上，把因变量变成drivingscore
regress drivingscore gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.sharp_turn#alert c.totalm#alert c.fatigdriving#app_usage c.rapid_acc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif



cd "E:\STATA_IOV"
//import excel drivingdata.xlsx,firstrow 
//save paper.dta,replace 
clear
import excel eng317.xlsx,firstrow
save papereng.dta,replace 
use papereng.dta,clear

replace drivingscore=0 if drivingscore<0


regress drivingscore alert app_usage log_avg_sudchange log_fatigd c.log_fatigd#alert c.log_fatigd#app_usage totalm age gender Speed_KMH time
estat vif

//
regress drivingscore alert app_usage log_avg_sudchange log_fatigd totalm age gender Speed_KMH time
estat vif

regress gcons alert app_usage log_avg_sudchange log_fatigd totalm age gender Speed_KMH time
estat vif

regress gcons alert app_usage log_avg_sudchange log_fatigd c.log_avg_sudchange#alert c.log_fatigd#alert totalm age gender Speed_KMH time
estat vif

regress drivingscore alert app_usage log_avg_sudchange log_fatigd c.log_avg_sudchange#alert c.log_fatigd#alert totalm age gender Speed_KMH time
estat vif


regress gcons alert app_usage log_avg_sudchange log_fatigd c.log_fatigd#alert totalm age gender Speed_KMH time
estat vif

regress drivingscore alert app_usage log_avg_sudchange log_fatigd c.log_fatigd#alert totalm age gender Speed_KMH time
estat vif

//
regress gcons alert app_usage log_avg_sudchange c.totalm#alert c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

regress drivingscore alert app_usage log_avg_sudchange c.totalm#alert c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

//
regress gcons app_usage log_avg_sudchange c.log_avg_sudchange#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

regress drivingscore app_usage log_avg_sudchange c.log_avg_sudchange#app_usage c.totalm#app_usage totalm age gender Speed_KMH time
estat vif

regress drivingscore app_usage alert log_fatigd totalm Speed_KMH
estat vif

regress drivingscore alert log_fatigd totalm c.log_fatigd#alert c.totalm#alert
estat vif

regress drivingscore log_avg_sudchange log_fatigd c.log_fatigd#alert c.log_avg_sudchange#alert c.totalm#alert totalm age gender time Speed_KMH
estat vif

//加上所有alert的交互项，并去掉共线的项，全部显著
regress drivingscore log_fatigd c.log_fatigd#alert c.log_avg_sudchange#alert c.totalm#alert totalm age gender time Speed_KMH
estat vif

regress drivingscore log_fatigd c.log_fatigd#app_usage c.log_avg_sudchange#app_usage c.totalm#app_usage totalm age gender time Speed_KMH
estat vif

//
regress gcons alert log_avg_sudchange log_fatigd totalm c.log_fatigd#alert c.totalm#alert age gender time Speed_KMH
estat vif

regress drivingscore alert log_avg_sudchange log_fatigd totalm c.log_fatigd#alert c.totalm#alert age gender time Speed_KMH
estat vif

// 只看alert usage totalm 以及危险驾驶行为，对drivingscore和gcons回归结果
regress drivingscore alert app_usage log_avg_sudchange log_fatigd totalm age gender Speed_KMH time
estat vif

regress gcons alert app_usage log_avg_sudchange log_fatigd totalm age gender Speed_KMH time
estat vif


//在上述基础上单纯加totalm和alert, app的交互
regress drivingscore alert app_usage log_avg_sudchange log_fatigd totalm c.totalm#app_usage c.totalm#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage log_avg_sudchange log_fatigd totalm c.totalm#app_usage c.totalm#alert age gender Speed_KMH time
estat vif

regress drivingscore alert app_usage totalm c.totalm#app_usage c.totalm#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.totalm#app_usage c.totalm#alert age gender Speed_KMH time
estat vif
//
regress drivingscore alert app_usage totalm c.age#app_usage c.age#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.age#app_usage c.age#alert age gender Speed_KMH time
estat vif

//
regress drivingscore alert app_usage totalm c.Speed_KMH#app_usage c.Speed_KMH#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.Speed_KMH#app_usage c.Speed_KMH#alert age gender Speed_KMH time
estat vif

//
regress drivingscore alert app_usage totalm c.time#app_usage c.time#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.time#app_usage c.time#alert age gender Speed_KMH time
estat vif


//在上述基础上删除危险驾驶行为，加和alert, app的交互
regress drivingscore alert app_usage totalm c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH time
estat vif

regress drivingscore alert app_usage c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH
estat vif

regress gcons alert app_usage c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH
estat vif

regress drivingscore alert app_usage app_usage#c.totalm alert#c.totalm app_usage#c.time alert#c.time age gender Speed_KMH
estat vif

regress gcons alert app_usage c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH
estat vif

//sum log_avg_sudchange,d

//
regress drivingscore alert app_usage totalm c.totalm#app_usage c.totalm#alert c.time#app_usage c.time#alert age gender Speed_KMH time
estat vif

regress gcons alert app_usage totalm c.totalm#app_usage c.totalm#alert c.log_avg_sudchange#app_usage c.log_avg_sudchange#alert age gender Speed_KMH time
estat vif



//result1 ==model1  只看time和time的交互项  ----note:调节效应和交互效应还是有所不同的
cd "E:\STATA_IOV"
clear
import excel eng317.xlsx,firstrow
save papereng.dta,replace 
use papereng.dta,clear

replace drivingscore=0 if drivingscore<0

//中心化，相关原理解释见B站
center time app_usage alert
gen app_time=c_time*c_app_usage 
gen alert_time=c_time*c_alert

center totalm
gen app_totalm=c_totalm*c_app_usage 
gen alert_totalm=c_totalm*c_alert

// regress gcons alert app_usage c.time#app_usage c.time#alert age gender Speed_KMH //time
// estat vif
//
// regress gcons alert app_usage c.time#app_usage c.time#alert time age gender Speed_KMH 
// estat vif
//
// regress drivingscore alert app_usage c.time#app_usage c.time#alert time age gender Speed_KMH 
// estat vif
// regress drivingscore alert app_usage c.time#app_usage c.time#alert age gender Speed_KMH 
// estat vif

//区分高低风险
sum dangerous_action,d //中位数 171
return list 
r(p50)

sum totalm,d //中位数20876.87
*-----------------gcons-------------------
*若无time totalm，R方会很低，且app_usage全部显著
regress gcons alert app_usage app_time alert_time time totalm age gender Speed_KMH if dangerous_action<171
estat vif
regress gcons alert app_usage app_time alert_time time totalm age gender Speed_KMH if dangerous_action>=171
estat vif

regress gcons alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action<171
estat vif
regress gcons alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action>=171
estat vif

regress gcons alert app_usage app_time alert_time time age gender Speed_KMH if totalm<20876.87
estat vif
regress gcons alert app_usage app_time alert_time time age gender Speed_KMH if totalm>=20876.87
estat vif

regress gcons alert app_usage app_time alert_time age gender Speed_KMH
estat vif
regress gcons alert app_usage app_time alert_time time age gender Speed_KMH
estat vif

regress log_gcons alert app_usage app_time alert_time time age gender Speed_KMH
estat vif

regress log_gcons alert app_usage app_time alert_time age gender Speed_KMH
estat vif

regress log_gcons alert app_usage app_time alert_time time age gender Speed_KMH if dangerous_action<171
estat vif
regress log_gcons alert app_usage app_time alert_time time age gender Speed_KMH if dangerous_action>=171
estat vif


*-----------------drivingscore-----------------------

regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action<171
estat vif
regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action>=171
estat vif

regress drivingscore alert app_usage app_time alert_time time totalm log_avg_sudchange log_fatigd age gender Speed_KMH if totalm<20876.87
estat vif
regress drivingscore alert app_usage app_time alert_time time totalm log_avg_sudchange log_fatigd age gender Speed_KMH if totalm>=20876.87
estat vif

regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action<171
estat vif
regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if dangerous_action>=171
estat vif

regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if totalm<20876.87
estat vif
regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH if totalm>=20876.87
estat vif

regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH log_avg_sudchange log_fatigd totalm time
estat vif
regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH log_avg_sudchange log_fatigd time
estat vif
regress drivingscore alert app_usage app_time alert_time app_totalm alert_totalm age gender Speed_KMH log_avg_sudchange log_fatigd time
estat vif

*--------------------CO2emission-----------------------------

regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH
estat vif
regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH time
estat vif

regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH time if dangerous_action<171
estat vif
regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH time if dangerous_action>=171
estat vif

regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH time if totalm<20876.87
estat vif
regress CO2emission alert app_usage app_time alert_time age gender Speed_KMH time if totalm>=20876.87
estat vif

regress drivingscore alert app_usage app_time alert_time age gender Speed_KMH time
estat vif
