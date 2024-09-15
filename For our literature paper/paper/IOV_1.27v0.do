cd "D:\STATA_class"

clear
import excel eng1123.xlsx,firstrow
save 1123.dta,replace 

use 1123.dta,clear

winsor2 gcons, cut(1 99) //左端不截尾
summarize gcons_w
// histogram gcons,  ylabel(, angle(0)) xtitle("gcons") name(fig1, replace)
// histogram gcons_tr,  ylabel(, angle(0)) xtitle("gcons_tr") name(fig2, replace)
// graph combine fig1 fig2
encode car_style, generate(car_style_n)
encode day, generate(day_n)  //1是周中，2是周末


*开始加入调节
center time drivingscore
gen app_time=c_time*app_usage 
gen alert_time=c_time*alert
gen alert_score=c_drivingscore*alert
gen usage_score=c_drivingscore*app_usage


center totalm mileage
gen app_totalm=c_totalm*app_usage 
gen alert_totalm=c_totalm*alert
gen score_totalm=c_totalm*c_drivingscore
gen app_m=c_mileage*app_usage 
gen alert_m=c_mileage*alert
gen score_m=c_mileage*c_drivingscore

center sudden_change rapid_acc rapid_deacc sharp_turn Speed_KMH
gen app_change=app_usage*c_sudden_change
gen app_speed=app_usage*c_Speed_KMH
gen app_ra=app_usage*c_rapid_acc
gen app_rda=app_usage*c_rapid_deacc
gen app_turn=app_usage*c_sharp_turn

gen alert_speed=alert*c_Speed_KMH
gen alert_ra=alert*c_rapid_acc
gen alert_rda=alert*c_rapid_deacc
gen alert_turn=alert*c_sharp_turn
gen alert_change=c_sudden_change*alert

gen isapp_change=c_sudden_change*isapp
gen isapp_speed=c_Speed_KMH*isapp
gen isapp_ra=isapp*c_rapid_acc
gen isapp_rda=isapp*c_rapid_deacc
gen isapp_turn=isapp*c_sharp_turn
gen isapp_time=isapp*c_time

center speed_change //急加速急减速加和
gen isapp_sc=isapp*c_speed_change
gen alert_sc=alert*c_speed_change
gen app_sc=app_usage*c_speed_change



//模型中，sudden_change 可以拆为加速减速急转弯，也可用speed_change替换
//isapp可以用app/alert替换

outreg2 using 描述性统计结果1.doc, replace sum(log) title(Decriptive statistics)
//相关性
asdoc pwcorr_a gcons app_usage alert speed_change Speed_KMH time totalm age gender car_style_n day_n, star1(0.01) star5(0.05) star10(0.1)


//重要结果1
regress gcons_w app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w alert speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif
//去掉app
regress gcons_w speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif

//gcons
regress gcons app_usage speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons alert speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif
//去掉app
regress gcons speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif
regress gcons speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif


// regress gcons_w speed_change app_sc Speed_KMH app_speed time car_style_n day_n totalm night
// estat vif
// regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm night
// estat vif
// regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm night
// estat vif
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



//重要结果2----app_time不要，app只和speed和sc乘
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

// //fatigdriving rapid_acc rapid_deacc sharp_turn不要了
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH
// estat vif
//
// regress gcons drivingscore app_usage alert alert_score usage_score score_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
// regress gcons drivingscore app_usage alert ranking alert_score usage_score score_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
//
// regress gcons drivingscore app_usage score_totalm app_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
//
//
// *-----------------------------final model-------------------------
// regress gcons drivingscore app_usage alert score_totalm app_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
// regress gcons drivingscore app_usage score_totalm app_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
// regress gcons drivingscore alert score_totalm alert_totalm car_style_n day_n totalm time age gender Speed_KMH
// estat vif
//
//
// regress drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH fatigdriving rapid_acc rapid_deacc sharp_turn
// estat vif
//
//
// *-------------//分组---------------
//
// //按drivingscore分组
// tabstat drivingscore, stats (sd median range)
// count if drivingscore<61.02
// count if drivingscore>=61.02
//
// tabstat time, stats (sd median mean range)
//
//
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if drivingscore<61.02
// estat vif
//
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if drivingscore>=61.02
// estat vif
//
// //按drivingscore分组，不带性别年龄则分组才有差异了，app_usage上不显著下显著
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if drivingscore<61.02
// estat vif
//
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if drivingscore>=61.02
// estat vif
//
// //按驾龄(totalm)分组，不带性别年龄则分组才有差异了，app_usage上不显著下显著
// tabstat totalm, stats (sd median range)
// count if totalm<20876.87
// count if totalm>=20876.87
//
// //已然有差异，app_usage上不显著下显著
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if totalm<20876.87
// estat vif
//
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time age gender Speed_KMH if totalm>=20876.87
// estat vif
//
// //去掉性别年龄，也是上不显著下显著
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if totalm<20876.87
// estat vif
//
// regress gcons drivingscore app_usage alert alert_score usage_score car_style_n day_n totalm time Speed_KMH if totalm>=20876.87
// estat vif






