cd "D:\STATA_class"

clear
import excel eng1123.xlsx,firstrow
save 1123.dta,replace 

use 1123.dta,clear


//drop varname2
//xtile varname2=drivingscore, nq(5)

// *基础变量
// regress varname2 alert app_usage age gender Speed_KMH   //R方0.03
// estat vif
//
// regress varname2 alert app_usage age gender Speed_KMH rapid_acc rapid_deacc sharp_turn time CO2emission
// estat vif
//
// *best1
// regress varname2 alert app_usage age gender Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving time CO2emission
// estat vif
//
// regress varname2 ranking alert app_usage age gender Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving time CO2emission
// estat vif



*开始加入调节
//中心化，相关原理解释见B站
center time app_usage alert 
center drivingscore
gen app_time=c_time*c_app_usage 
gen alert_time=c_time*c_alert
gen alert_score=c_drivingscore*c_alert
gen usage_score=c_drivingscore*c_app_usage

center totalm
gen app_totalm=c_totalm*c_app_usage 
gen alert_totalm=c_totalm*c_alert
gen score_totalm=c_totalm*c_drivingscore

//
// *基础变量
// regress varname2 alert app_usage app_time alert_time age gender Speed_KMH   //R方0.03
// estat vif
//
// regress varname2 alert app_usage app_time alert_time age gender Speed_KMH rapid_acc rapid_deacc sharp_turn
// estat vif

encode car_style, generate(car_style_n)
encode day, generate(day_n)  //1是周中，2是周末


*****gcons
// regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn c.fatigdriving#alert c.rapid_acc#alert c.sharp_turn#alert c.totalm#alert c.fatigdriving#app_usage c.rapid_acc#app_usage c.sharp_turn#app_usage c.totalm#app_usage totalm time
// estat vif
// regress gcons alert app_usage fatigdriving rapid_acc rapid_deacc sharp_turn app_time alert_time totalm time
// estat vif


// drop varname2
// regress gcons drivingscore app_usage fatigdriving rapid_acc rapid_deacc sharp_turn totalm time
// estat vif
//
// regress gcons drivingscore alert fatigdriving rapid_acc rapid_deacc sharp_turn totalm time
// estat vif
//
// regress gcons drivingscore alert alert_score fatigdriving rapid_acc rapid_deacc sharp_turn totalm time
// estat vif
//
// regress gcons drivingscore alert usage_score fatigdriving rapid_acc rapid_deacc sharp_turn totalm time
// estat vif
//
// regress gcons drivingscore app_usage usage_score fatigdriving rapid_acc rapid_deacc sharp_turn totalm time
// estat vif

//说了fatigdriving rapid_acc rapid_deacc sharp_turn不要了
regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score score_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons drivingscore app_usage score_totalm app_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif



*-------------//分组---------------
tabstat drivingscore, stats (sd median range)
count if drivingscore<61.02
count if drivingscore>=61.02

regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if drivingscore<61.02
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if drivingscore>=61.02
estat vif

//按drivingscore分组，不带性别年龄则分组才有差异了，app_usage上不显著下显著
regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if drivingscore<61.02
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if drivingscore>=61.02
estat vif

//按驾龄(totalm)分组，不带性别年龄则分组才有差异了，app_usage上不显著下显著
tabstat totalm, stats (sd median range)
count if totalm<20876.87
count if totalm>=20876.87

//已然有差异，app_usage上不显著下显著
regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if totalm<20876.87
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if totalm>=20876.87
estat vif

//去掉性别年龄，也是上不显著下显著
regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if totalm<20876.87
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if totalm>=20876.87
estat vif






