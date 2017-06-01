### All data manipulation

### Maybe should make district a factor?

### Training
load("C:/Users/Sydney/Desktop/training.RData")

library(lubridate)
training$`Incident Creation Time (GMT)` <- 
  hms(training$`Incident Creation Time (GMT)`)

training$hour <- hour(training$`Incident Creation Time (GMT)`)
training$min <- minute(training$`Incident Creation Time (GMT)`)
training$second <- second(training$`Incident Creation Time (GMT)`)

# Model did way worse with these variables (like 18 million worse for the MSE!)
# so, maybe the correlation between the variables is a problem?
# or, maybe the incident.ids got scrambled somehow?
# library(dplyr) 
# training <- training %>% group_by(incident.ID) %>% mutate(NumUnits = n(), MaxDispatch = max(`Dispatch Sequence`))

# removing the row.id, incident.id, time
training2 <- training[,-c(1,2, 9)]

### One hot encoding -- converting the categoricals to numerical variables

###  taking out spaces in variable names 
colnames(training2) <- c("year", "First_in_District",
                      "Dispatch_Sequence", "Dispatch_Status",
                      "Unit_Type", "PPE_Level", 
                      "elapsed_time", "hour", "min", "second")

training2[,c("Dispatch_Status", "Unit_Type", "PPE_Level")] <- as.data.frame(apply(training2[,c("Dispatch_Status", "Unit_Type", "PPE_Level")], 2, as.factor))




### Testing
load("C:/Users/Sydney/Desktop/testing.RData")

testing$`Incident Creation Time (GMT)` <- 
  hms(testing$`Incident Creation Time (GMT)`)

testing$hour <- hour(testing$`Incident Creation Time (GMT)`)
testing$min <- minute(testing$`Incident Creation Time (GMT)`)
testing$second <- second(testing$`Incident Creation Time (GMT)`)

# Model did worse with these variables
# testing <- testing %>% group_by(incident.ID) %>% mutate(NumUnits = n(), MaxDispatch = max(`Dispatch Sequence`))

# removing the row.id, incident.id, time
testing2 <- testing[,-c(1,2, 9)]

colnames(testing2) <- c("year", "First_in_District",
                         "Dispatch_Sequence", "Dispatch_Status",
                         "Unit_Type", "PPE_Level", 
                         "hour", "min", "second")

testing2[,c("Dispatch_Status", "Unit_Type", "PPE_Level")] <- as.data.frame(apply(testing2[,c("Dispatch_Status", "Unit_Type", "PPE_Level")], 2, as.factor))




### External Data

library(readr)
FireStations <- read_csv("C:/Users/Sydney/Downloads/FireStations.csv")

length(table(FireStations$FS_CD)) ### 106 stations
length(table(training$`First in District`)) ### 102 stations

## Our data doesn't include Stations	80	(LAX),	110	(Boat	5), 111	(Boat	1)	&	114	(Air	Operations)



## This icludes data on the median home price of the neighborhood the fire station is in
## I collected this by entering the adress of each fire station by hand into a real estate website
First.in.District <- c(1:21,23:29,33:44,46:52,55:112,114)
length(First.in.District)
median.realestate <- c(500307,490180,490180,595792,907746,605157,378457,710996,413696,200000,300000,441828,798865,798865,798865,581328,537994,802783,3393174,651694,388484,2026991,809661,338113,826575,871435,760905,947933,395772,487674,757535,754940,667094,577322,562106,412941,785267,705179,615354,503893,397357,492213,492213,456515,595107,1223464,1243510,608612,467225,394311,971754,903370,366542,1739490,1117160,2109582,488844,407696,429829,853038,875174,2054795,512834,2853956,352911,450235,488747,476019,1178134,731106,997840,534785,1500000,377762,1100000,948839,764283,438477,648383,581261,748063,452539,499396,433763,1796586,1112877,600000,527082,754930,1279778,384660,1397444,637193,753871,743680,483528,597810,924630,569097,854039,3081536,2233751,679915,852948,600000,1500000)
length(median.realestate)
station.neighborhood <- data.frame(First.in.District,median.realestate)

library(dplyr)
training <- inner_join(x=training,y=station.neighborhood)
testing <- inner_join(x=testing,y=station.neighborhood)


