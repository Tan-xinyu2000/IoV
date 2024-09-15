cd "D:\STATA_class"

clear
import excel eng1123.xlsx,firstrow
save 1123.dta,replace 

use 1123.dta,clear

winsor2 gcons, cut(1 99) //左端不截尾
summarize gcons_w

winsor2 CO2emission, cut(1 99) //左端不截尾
summarize CO2emission_w
histogram CO2emission_w,kden

// histogram gcons,  ylabel(, angle(0)) xtitle("gcons") name(fig1, replace)
// histogram gcons_tr,  ylabel(, angle(0)) xtitle("gcons_tr") name(fig2, replace)
// graph combine fig1 fig2
encode car_style, generate(car_style_n)
encode day, generate(day_n)  //1是周中，2是周末
tabstat time, stats (sd mean median range)
tabstat totalm, stats (sd mean median range)

tabstat Speed_KMH, stats (sd mean median range)
histogram Speed_KMH,kden

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

// gen fcr=gcons/mileage
// winsor2 fcr, cut(1 99) //左端不截尾

//模型中，sudden_change 可以拆为加速减速急转弯，也可用speed_change替换
//isapp可以用app/alert替换

outreg2 using 描述性统计结果1.doc, replace sum(log) title(Decriptive statistics)
//相关性
asdoc pwcorr_a gcons_w speed_change Speed_KMH time totalm age gender car_style_n day_n night, star1(0.01) star5(0.05) star10(0.1)


// regress fcr isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
// estat vif
regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif

regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed mileage car_style_n day_n totalm age gender night
estat vif

regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed mileage time car_style_n day_n totalm age gender night
estat vif

regress CO2emission_w speed_change isapp_sc Speed_KMH isapp_speed mileage car_style_n day_n totalm age gender night
estat vif
regress CO2emission_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
estat vif

//
// summarize Speed_KMH

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
asdoc pwcorr_a gcons_w speed_change Speed_KMH time totalm age gender car_style_n day_n night, star1(0.01) star5(0.05) star10(0.1)
asdoc regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
asdoc estat vif
regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif

regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time isapp_time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change app_sc Speed_KMH app_speed time app_time car_style_n day_n totalm age gender night
estat vif
regress gcons_w speed_change alert_sc Speed_KMH alert_speed time car_style_n day_n totalm age gender night
estat vif

regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night if time>=9.32
estat vif
regress gcons_w speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night if time<9.32
estat vif
regress gcons_w isapp speed_change isapp_sc Speed_KMH isapp_speed time car_style_n day_n totalm age gender night
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
