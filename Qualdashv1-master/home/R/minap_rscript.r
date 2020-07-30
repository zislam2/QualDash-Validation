 library(readr)
 library(lubridate)
 library(parsedate)

 source_file_path <- "C:/xampp/htdocs/Qualdashv1-master/home/data/source/minap/"
 dest_file_path <- "C:/xampp/htdocs/Qualdashv1-master/home/data/minap_admission/"
 dateFormat <- '%d/%m/%Y %H:%M'
 audit_filename <- "uploaded_file.csv"
 
 source = paste(source_file_path, audit_filename, sep='')
 madmission <- read_csv(source)

 # Select all columns with Date data type

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


# Add other formats 
# dateFormat <- "%d/%m/%Y"
dateFormat <- "%d-%m-%y"
otherDates <- lapply(madmission, function(x) !all(is.na(as.Date(as.character(x), format = dateFormat))))
df2 <- as.data.frame(otherDates)
colnames(df2) <- colnames(madmission)
dateFields2 <- df2[which(df2==TRUE)]

# Unify date formats to ISO format 
for(col in colnames(madmission)){
    if(col %in% colnames(dateFields2)){
     vector <- madmission[col]
     temp <- lapply(vector, function(x) as.POSIXlt(x, format=dateFormat))
     madmission[col] <- temp

    }
}

dateFormat <- "%d-%m-%Y"
otherDates <- lapply(madmission, function(x) !all(is.na(as.Date(as.character(x), format = dateFormat))))
df2 <- as.data.frame(otherDates)
colnames(df2) <- colnames(madmission)
dateFields2 <- df2[which(df2==TRUE)]

# Unify date formats to ISO format 
for(col in colnames(madmission)){
  if(col %in% colnames(dateFields2)){
    vector <- madmission[col]
    temp <- lapply(vector, function(x) as.POSIXlt(x, format=dateFormat))
    madmission[col] <- temp
    
  }
}


# get years in data
admdate <- madmission$`3.06 ArrivalAtHospital`
adyear <- year(admdate)
madmission <- cbind(madmission, adyear)


# Derived columns
v427 <- madmission$`4.27 DischargedOnThieno` == '1. Yes'
v431 <- madmission$`4.31 DischargedOnTicagrelor` == '1. Yes'

madmission$P2Y12 <- as.numeric(v431 | v427)

dtb <- madmission$`3.09 ReperfusionTreatment` - madmission$`3.06 ArrivalAtHospital`
madmission$dtb <- as.numeric(dtb)

ctb <- madmission$`3.09 ReperfusionTreatment` - madmission$`3.02 CallforHelp`
madmission$ctb <- as.numeric(ctb)
madmission$ctbTarget <- as.numeric(ctb <= 120.0)
madmission$ctbNoTarget <- as.numeric(ctb > 120.0)

dta <- madmission$`4.18 LocalAngioDate` - madmission$`3.06 ArrivalAtHospital`
madmission$dta <- as.numeric(dta)
dtaH <- as.numeric(dta) / 60
madmission$dta <- as.numeric(dtaH)
madmission$dtaTarget <- as.numeric(dtaH < 72.0)
madmission$dtaNoTarget <- as.numeric(dtaH > 72.0)

madmission$missingOneDrug <- as.numeric( madmission$'P2Y12' == 0 | madmission$'4.05 Betablocker' == '0. No' | madmission$'4.06 ACEInhibitor' == '0. No' | madmission$'4.07 Statin'== '0. No' | madmission$'4.08 AspirinSecondary' == '0. No' )


 # break it into separate files for individual years
# and store the new files in the MINAP admissions folder under documnt root 
for(year in unique(adyear)){
  tmp = subset(madmission, adyear == year)
  fn = paste(dest_file_path, gsub(' ','', year), '.csv', sep='' )
  write.csv(tmp, fn, row.names = FALSE)
  
}

for(year in sort(unique(adyear))){
  prevYear = year - 1
  start = paste(prevYear, '-04-01 00:00:00 GMT', sep='')
  end = paste(year, '-03-31 00:00:00 GMT', sep='' )
  
  tmp2 = subset(madmission, (pmin(as.Date(madmission$`3.06 ArrivalAtHospital`), as.Date(start)) == as.Date(start)) &  (pmin(as.Date(madmission$`3.06 ArrivalAtHospital`), as.Date(end)) == as.Date(madmission$`3.06 ArrivalAtHospital`)) )
  fn = paste(dest_file_path, gsub(' ','', prevYear),'-', gsub(' ','', year), '.csv', sep='' )
  write.csv(tmp2, fn, row.names = FALSE)
}

# APPEND to existing available years
yfn = paste(dest_file_path, 'avail_years.csv', sep='' );
av <- read_csv(yfn);
temp <- av$x;
vec <- vector() 
for(str in temp){
    if(nchar(str)== 4)
        vec <- c(vec, str)
}

for(year in unique(madmission$adyear)){
  if(!(year %in% vec)){
    temp <- c(temp, year)
  }
}

for(year in unique(madmission$adyear)){
  prev = year -1 
  dashed = paste(gsub(' ','', prev),'-', gsub(' ','', year), sep='')
  if(! (dashed %in% temp))
    temp <- c(temp, dashed) 
}
write.csv(temp, yfn, row.names = FALSE)