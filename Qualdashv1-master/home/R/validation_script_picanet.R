library(readr)
library(tibble)
library(dplyr)
library(xtable)
library(rjson)

source_file_path <- "C:/xampp/htdocs/Qualdashv1-master/home/data/source/picanet/"
audit_filename <- "uploaded_file.csv"

source = paste(source_file_path, audit_filename, sep='')
madmission <- read_csv(source)

# Give the input file name to the javascript function
result <- fromJSON(file = "C:/xampp/htdocs/Qualdashv1-master/home/js/config_mss_picanet.json")

# Convert JSON file to a data frame.
json_data_frame <- as.data.frame(result)
print(json_data_frame)


# Date Format
dateFormat <- '%d/%m/%Y %H:%M'
allDates <- lapply(madmission, function(x) !all(is.na(as.Date(as.character(x), format =dateFormat))))
df <- as.data.frame(allDates)
colnames(df) <- colnames(madmission)
dateFields <- df[which(df==TRUE)]

# Unify date formats to ISO format 
for(col in colnames(madmission)){
  if(col %in% colnames(dateFields)){
    vector <- madmission[col]
    temp <- lapply(vector, function(x) as.POSIXlt(x, format=dateFormat))
    madmission[col] <- temp
    
  }
}

newdate<- format(as.Date(madmission$"3.06 ArrivalAtHospital"), "%Y-%m")


#CTB Values Conversion
ctb <- madmission$`3.09 ReperfusionTreatment` - madmission$`3.02 CallforHelp`
madmission$ctb <- as.numeric(ctb)
madmission$ctbTarget <- as.numeric(ctb <= 120.0)
madmission$ctbNoTarget <- as.numeric(ctb > 120.0)

#DTA Values Conversion
dta <- madmission$`4.18 LocalAngioDate` - madmission$`3.06 ArrivalAtHospital`
madmission$dta <- as.numeric(dta)
dtaH <- as.numeric(dta) / 60
madmission$dta <- as.numeric(dtaH)
madmission$dtaTarget <- as.numeric(dtaH < 72.0)
madmission$dtaNoTarget <- as.numeric(dtaH > 72.0)

#Gold Standard Drugs Values Conversion
v427 <- madmission$`4.27 DischargedOnThieno` == '1. Yes'
v431 <- madmission$`4.31 DischargedOnTicagrelor` == '1. Yes'
madmission$P2Y12 <- as.numeric(v431 | v427)
madmission$missingOneDrug <- as.numeric( madmission$'P2Y12' == 0 | madmission$'4.05 Betablocker' == '0. No' | madmission$'4.06 ACEInhibitor' == '0. No' | madmission$'4.07 Statin'== '0. No' | madmission$'4.08 AspirinSecondary' == '0. No' )


#select required columns and create frequency tables
mortality_by_month_table <- table(newdate, madmission$`4.04 DeathInHospital`)
call_to_balloon_table <- table(newdate, madmission$ctbNoTarget)
door_to_angio_table <- table(newdate, madmission$dtaNoTarget)
gold_standard_drugs_table <- table(newdate, madmission$missingOneDrug)
cardiac_rehabilitation_table <- table(newdate, madmission$`4.09 CardiacRehabilitation`)
accute_use_of_asprin_table <- table(newdate, madmission$`2.04 Aspirin`)


#print frequency tables to html
print(xtable(mortality_by_month_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/mortality_by_month.html")
print(xtable(call_to_balloon_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/call_to_balloon.html")
print(xtable(door_to_angio_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/door_to_angio.html")
print(xtable(gold_standard_drugs_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/gold_standard_drugs.html")
print(xtable(cardiac_rehabilitation_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/cardiac_rehabilitation.html")
print(xtable(accute_use_of_asprin_table), type="html", file="C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/accute_use_of_asprin.html")

#Save frequency tables as CSV

write.csv(mortality_by_month_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/mortality_by_month.csv")
write.csv(call_to_balloon_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/call_to_balloon.csv")
write.csv(door_to_angio_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/door_to_angio.csv")
write.csv(gold_standard_drugs_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/gold_standard_drugs.csv")
write.csv(cardiac_rehabilitation_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/cardiac_rehabilitation.csv")
write.csv(accute_use_of_asprin_table, "C:/xampp/htdocs/Qualdashv1-master/home/data/validation/picanet/data/accute_use_of_asprin.csv")