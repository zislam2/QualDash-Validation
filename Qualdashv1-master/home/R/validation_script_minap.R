library(readr)
library(tibble)
library(dplyr)
library(xtable)
library(rjson)
library(data.table)

source_file_path <- "C:/xampp/htdocs/Qualdashv1-master/home/data/source/minap/"
audit_filename <- "uploaded_file.csv"

#source_file_path <- "C:/Bitnami/wampstack-7.0.12-0/apache2/htdocs/Qualdashv1/home/data/source/"
#audit_filename <- "MINAP_dummy_values_2.csv"

source = paste(source_file_path, audit_filename, sep='')
madmission <- read_csv(source)

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


#Give the input file name to the javascript function
result <- fromJSON(file = "C:/xampp/htdocs/Qualdashv1-master/home/js/config_mss_minap.json")


display <- result[['displayVariables']]
admission_date <- unique(newdate)
for (i in names(display[[1]]$yfilters)) {
  entry <- display[[1]]$yfilters[i]
  y_value <- select(madmission, i )
  condition <- entry[[i]][['where']]
  print(i)
  print(condition)
  for(c in names(condition)){
    filtered_value <- filter(y_value, c == "condition")
    combine <- cbind(newdate, filtered_value)
    validation <- table(combine)
    write.table(validation, file= file.path('C:/xampp/htdocs/Qualdashv1-master/home/data/validation/minap/data/', paste0(display[[1]]$metric,'.csv')))
  }
}
