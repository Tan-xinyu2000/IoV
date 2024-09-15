cd "D:\STATA_class"
//import excel drivingdata.xlsx,firstrow 
//save paper.dta,replace 
clear
import excel eng317.xlsx,firstrow
save papereng.dta,replace 

use papereng.dta,clear
describe

log using IOV.log,replace

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

qladder fatigdriving

age gender accident drivingexp gcons 
//log_gasoline CO2emission log_co2  mileage totalm log_totalm 
//time log_time  rapid_acc log_acc rapid_deacc log_deacc sharp_turn 
//log_turn fatigdriving nightdriving log_ndri 
drivingscore app_usage  Speed_KMH log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
*/
//删除了age等变量
regress drivingscore ranking alert  totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust
//gcons
//删除空值行
regress drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust

log close

log using IOV2.log,replace
regress drivingscore ranking alert gender drivingexp gcons rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust


regress drivingscore ranking alert  totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage , robust
estat vif

regress drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, robust
estat vif

//逐步回归
sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, pr(0.05)
estat vif

sw reg drivingscore ranking alert age gender accident drivingexp gcons totalm Speed_KMH rapid_acc rapid_deacc sharp_turn fatigdriving nightdriving app_usage log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, pe(0.05)
estat vif

//下面这个很好
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1, robust
estat vif
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
estat vif

//log_g_1 log_co2_1 log_totalm_1 log_time_1 log_acc_1 log_deacc_1 log_turn_1 log_ndri_1
regress drivingscore alert age gender accident drivingexp app_usage log_g_1 log_totalm_1 Speed_KMH rapid_acc rapid_deacc log_turn_1 log_ndri_1
estat vif
log close
