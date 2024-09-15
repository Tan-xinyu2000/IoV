cd "D:\STATA_class"

clear
import excel eng1123.xlsx,firstrow
save 1123.dta,replace 

use 1123.dta,clear

winsor2 gcons, cut(1 99) //左端不截尾
// histogram gcons,  ylabel(, angle(0)) xtitle("gcons") name(fig1, replace)
// histogram gcons_tr,  ylabel(, angle(0)) xtitle("gcons_tr") name(fig2, replace)
// graph combine fig1 fig2
summarize gcons_w
*开始加入调节
//中心化，相关原理解释见B站
center time app_usage alert isapp
center drivingscore
gen app_time=c_time*c_app_usage 
gen alert_time=c_time*c_alert
gen alert_score=c_drivingscore*c_alert
gen usage_score=c_drivingscore*c_app_usage


center totalm mileage
gen app_totalm=c_totalm*c_app_usage 
gen alert_totalm=c_totalm*c_alert
gen score_totalm=c_totalm*c_drivingscore
gen app_m=c_mileage*c_app_usage 
gen alert_m=c_mileage*c_alert
gen score_m=c_mileage*c_drivingscore

center sudden_change rapid_acc rapid_deacc sharp_turn Speed_KMH
gen app_change=c_app_usage*c_sudden_change
gen app_speed=c_app_usage*c_Speed_KMH
gen alert_speed=c_alert*c_Speed_KMH
gen app_ra=c_app_usage*c_rapid_acc
gen app_rda=c_app_usage*c_rapid_deacc
gen app_turn=c_app_usage*c_sharp_turn
gen alert_ra=c_alert*c_rapid_acc
gen alert_rda=c_alert*c_rapid_deacc
gen alert_turn=c_alert*c_sharp_turn

gen alert_change=c_sudden_change*c_alert

gen isapp_change=c_sudden_change*c_isapp
gen isapp_speed=c_Speed_KMH*c_isapp
gen isapp_ra=c_isapp*c_rapid_acc
gen isapp_rda=c_isapp*c_rapid_deacc
gen isapp_turn=c_isapp*c_sharp_turn
gen isapp_time=c_isapp*c_time

center speed_change //急加速急减速加和
gen isapp_sc=c_isapp*c_speed_change
gen alert_sc=c_alert*c_speed_change
gen app_sc=c_app_usage*c_speed_change

center avg_suddenchange
gen app_asc=c_app_usage*c_avg_suddenchange
gen alert_asc=c_alert*c_avg_suddenchange
gen isapp_asc=c_isapp*c_avg_suddenchange

encode car_style, generate(car_style_n)
encode day, generate(day_n)  //1是周中，2是周末

//模型中，sudden_change 可以拆为加速减速急转弯，也可用speed_change,avg_suddenchange替换
//isapp可以用app/alert替换
//2022.1.18 final
// asdoc regress gcons sudden_change app_change Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
// asdoc estat vif 

// asdoc regress gcons speed_change app_sc Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
// asdoc estat vif 
outreg2 using 描述性统计结果1.doc, replace sum(log) title(Decriptive statistics)

asdoc pwcorr_a gcons app_usage alert speed_change Speed_KMH time totalm age gender car_style_n day_n, star1(0.01) star5(0.05) star10(0.1)
//asdoc corr gcons app_usage alert speed_change Speed_KMH time totalm age gender car_style_n day_n
asdoc regress gcons app_usage alert speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender
asdoc estat vif
//重要结果0
regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w alert speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif

summarize Speed_KMH

regress gcons_w speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm night
estat vif
regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm night
estat vif
regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm night
estat vif


// regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night drivingscore
// estat vif
// regress gcons_w speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night drivingscore
// estat vif
// regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night drivingscore
// estat vif

// regress gcons speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
// estat vif
// regress gcons speed_change isapp_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
// estat vif
// regress gcons speed_change alert_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
// estat vif



//重要结果1------app_time不要了，app只和speed和sc乘
regress gcons app_usage speed_change app_sc Speed_KMH app_speed time app_time car_style_n day_n totalm age gender night if totalm>=20876.87
estat vif
regress gcons app_usage speed_change app_sc Speed_KMH app_speed time app_time car_style_n day_n totalm age gender night if totalm<20876.87
estat vif
regress gcons app_usage speed_change app_sc Speed_KMH app_speed time app_time car_style_n day_n age gender night if totalm>=20876.87
estat vif
regress gcons app_usage speed_change app_sc Speed_KMH app_speed time app_time car_style_n day_n age gender night if totalm<20876.87
estat vif

regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n age gender night if totalm>=20876.87
estat vif
regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n age gender night if totalm<20876.87
estat vif

regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night if totalm>=20876.87
estat vif
regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night if totalm<20876.87
estat vif

// regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night if time>=8.83306
// estat vif
// regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night if time<8.83306
// estat vif

asdoc reg gcons Speed_KMH alert time car_style_n day_n totalm age gender, nest append
asdoc reg gcons speed_change alert time car_style_n day_n totalm age gender, nest append
asdoc reg gcons app_usage speed_change Speed_KMH alert time car_style_n day_n totalm age gender, nest append
asdoc reg gcons app_usage speed_change Speed_KMH alert time car_style_n day_n totalm age gender, nest append
asdoc reg gcons app_usage speed_change Speed_KMH app_sc alert time car_style_n day_n totalm age gender, nest append
asdoc reg gcons app_usage speed_change Speed_KMH app_speed alert time car_style_n day_n totalm age gender, nest append

// asdoc regress gcons app_usage alert speed_change app_sc alert_change Speed_KMH app_speed alert_speed time car_style_n day_n totalm age gender
// asdoc estat vif 






tabstat time, stats (sd mean range)
regress gcons app_usage sudden_change app_change Speed_KMH app_speed car_style_n day_n totalm age gender if time>=8.83306
regress gcons app_usage sudden_change app_change Speed_KMH app_speed car_style_n day_n totalm age gender if time<8.83306
regress gcons app_usage sudden_change app_change Speed_KMH app_speed app_time car_style_n day_n totalm age gender if time>=8.83306
regress gcons app_usage sudden_change app_change Speed_KMH app_speed app_time car_style_n day_n totalm age gender if time<8.83306
estat vif
regress gcons app_usage alert sudden_change app_change Speed_KMH app_speed time app_time car_style_n day_n totalm age gender 
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time app_time car_style_n day_n totalm age gender 
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time app_time car_style_n day_n age gender if totalm<20876.87
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time app_time car_style_n day_n age gender if totalm>=20876.87
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time totalm car_style_n day_n age gender if totalm<20876.87
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time totalm car_style_n day_n age gender if totalm>=20876.87
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time totalm app_time car_style_n day_n age gender if totalm<20876.87
regress gcons app_usage sudden_change app_change Speed_KMH app_speed time totalm app_time car_style_n day_n age gender if totalm>=20876.87



regress gcons alert sudden_change alert_change Speed_KMH alert_speed time alert_time car_style_n day_n age gender if totalm<20876.87
regress gcons alert sudden_change alert_change Speed_KMH alert_speed time alert_time car_style_n day_n age gender if totalm>=20876.87

asdoc regress gcons app_usage alert speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender
asdoc estat vif

// regress gcons app_usage sudden_change app_change Speed_KMH app_speed time car_style_n day_n totalm age gender
// estat vif
//
// regress gcons app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender
// estat vif

// regress gcons isapp sudden_change isapp_change Speed_KMH isapp_speed time car_style_n day_n totalm age gender
// estat vif

// regress gcons isapp sudden_change app_change Speed_KMH app_speed time car_style_n day_n totalm age gender
// estat vif





regress gcons isapp sudden_change isapp_change Speed_KMH isapp_speed time isapp_time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons rapid_acc rapid_deacc sharp_turn isapp_ra isapp_rda isapp_turn Speed_KMH isapp_speed time drivingscore car_style_n day_n totalm age gender
estat vif
//是否使用app对急加速有明显削弱作用，对急减速、急转弯作用不大
regress gcons rapid_acc rapid_deacc sharp_turn app_ra app_rda app_turn Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons speed_change isapp_sc sharp_turn isapp_turn Speed_KMH isapp_speed time drivingscore car_style_n day_n totalm age gender
estat vif

regress gcons speed_change alert_sc sharp_turn alert_turn Speed_KMH alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons speed_change app_sc sharp_turn app_turn Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
estat vif //效果可解释
regress gcons sudden_change app_change Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
estat vif //效果可解释
regress gcons sudden_change isapp_change Speed_KMH isapp_speed time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons sudden_change alert_change Speed_KMH alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif

regress gcons avg_suddenchange isapp_asc Speed_KMH isapp_speed time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons avg_suddenchange alert_asc Speed_KMH alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif
regress gcons avg_suddenchange app_asc Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
estat vif


regress gcons rapid_acc rapid_deacc sharp_turn isapp_ra isapp_rda isapp_turn Speed_KMH isapp_speed time drivingscore car_style_n day_n totalm age gender
estat vif

regress gcons sudden_change app_change Speed_KMH app_speed time drivingscore car_style_n day_n totalm age gender
estat vif 

regress gcons sudden_change app_change Speed_KMH app_speed alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif 
regress gcons sudden_change app_change alert_change Speed_KMH app_speed alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif 

regress gcons sudden_change alert_change Speed_KMH alert_speed time drivingscore car_style_n day_n totalm age gender
estat vif 

regress gcons app_usage alert sudden_change app_change alert_change time app_time Speed_KMH app_speed car_style_n day_n totalm age gender
estat vif 

regress gcons app_usage sudden_change app_change time app_time Speed_KMH app_speed car_style_n day_n totalm age gender
estat vif 

regress gcons app_usage alert sudden_change app_change alert_change time app_time Speed_KMH app_speed alert_speed car_style_n day_n totalm age gender
estat vif 

// regress gcons app_usage alert sudden_change app_change alert_change time app_time Speed_KMH app_speed alert_speed car_style_n day_n age gender if totalm<20876.87 
// estat vif 
//
// regress gcons app_usage alert sudden_change app_change alert_change time app_time Speed_KMH app_speed alert_speed car_style_n day_n age gender if totalm>=20876.87 
// estat vif 




regress gcons app_usage sudden_change app_change Speed_KMH app_speed time car_style_n day_n totalm age gender  
estat vif 



// regress fe app_usage alert sudden_change app_change alert_change time app_time Speed_KMH app_speed car_style_n day_n totalm age gender  
// estat vif 

regress gcons sudden_change time app_usage alert app_time car_style_n day_n totalm age gender Speed_KMH 
estat vif




regress gcons mileage app_usage alert app_m alert_m //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons mileage alert alert_m //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons time app_time alert_time
//mileage app_usage alert app_m alert_m //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress drivingscore time app_time alert_time
//mileage app_usage alert app_m alert_m //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress drivingscore mileage app_m alert_m //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress drivingscore mileage app_usage alert alert_m //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress drivingscore time alert alert_time car_style_n day_n totalm age gender Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving
estat vif

regress gcons mileage app_usage alert alert_m              //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons time app_usage alert alert_time           //app_time alert_time //car_style_n day_n totalm time age gender Speed_KMH
estat vif





regress gcons time app_usage alert app_time alert_time car_style_n day_n totalm age gender Speed_KMH
estat vif

regress gcons time app_usage alert app_time alert_time drivingscore car_style_n day_n totalm age gender Speed_KMH
estat vif

regress gcons time app_usage alert app_time alert_time drivingscore alert_score car_style_n day_n totalm age gender Speed_KMH
estat vif

regress gcons time app_usage alert app_time alert_time drivingscore usage_score car_style_n day_n totalm age gender Speed_KMH
estat vif

regress gcons time app_usage alert app_time alert_time car_style_n day_n totalm age gender Speed_KMH if drivingscore<61.02
estat vif 

regress gcons time app_usage alert app_time alert_time car_style_n day_n totalm age gender Speed_KMH if drivingscore>=61.02
estat vif 





//  2021.12.11
regress gcons time app_usage app_time car_style_n day_n totalm age gender Speed_KMH if drivingscore<61.02
estat vif 

regress gcons time app_usage app_time car_style_n day_n totalm age gender Speed_KMH if drivingscore>=61.02
estat vif



// gen mile=time*Speed_KMH
//
// center mile
// gen app_mile=c_mile*c_app_usage 
// gen alert_mile=c_mile*c_alert
//
//
// regress gcons mile app_usage app_mile car_style_n day_n totalm age gender Speed_KMH if drivingscore<61.02
// estat vif 
//
// regress gcons mile app_usage app_mile car_style_n day_n totalm age gender Speed_KMH if drivingscore>=61.02
// estat vif





// regress gcons time app_usage alert totalm app_totalm alert_totalm car_style_n day_n age gender Speed_KMH
// estat vif
//
// regress drivingscore time app_usage alert totalm app_totalm alert_totalm car_style_n day_n age gender Speed_KMH
// estat vif




//说了fatigdriving rapid_acc rapid_deacc sharp_turn不要了
regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons drivingscore app_usage alert alert_score usage_score score_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif
regress gcons drivingscore app_usage alert ranking alert_score usage_score score_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif

regress gcons drivingscore app_usage score_totalm app_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif


*-----------------------------final model-------------------------
regress gcons drivingscore app_usage alert score_totalm app_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif
regress gcons drivingscore app_usage score_totalm app_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif
regress gcons drivingscore alert score_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
estat vif


regress drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH fatigdriving rapid_acc rapid_deacc sharp_turn
estat vif


*-------------//分组---------------

//按drivingscore分组
tabstat drivingscore, stats (sd median range)
count if drivingscore<61.02
count if drivingscore>=61.02

tabstat time, stats (sd median mean range)


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






