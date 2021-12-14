library(ggplot2)
library(dplyr)
library(tidyverse)
library(choroplethr)
library(statebins)
library(maps)
library(ggrepel)
library(patchwork)
library(scales)
library(viridis)
library(ggmosaic)
library(rjson)

###### Preprocessing Treatment Data

tedsa_puf_2000_2019 <- read.csv("data/tedsa_puf_2000_2019.csv")

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% select(AGE, ADMYR, GENDER, RACE, EMPLOY,EDUC,STFIPS,REGION,DIVISION,SERVICES,SUB1,ROUTE1,FREQ1,DETNLF)
metadataJSONPath <- 'data/smetadata.json'
metadata <- fromJSON(file=metadataJSONPath)

tedsa_puf_2000_2019 <- as.data.frame(tedsa_puf_2000_2019)

for (i in colnames(tedsa_puf_2000_2019))
{
  tedsa_puf_2000_2019[[i]] <- sapply(tedsa_puf_2000_2019[[i]], function(col1)
  {
    names(metadata[[i]])[metadata[[i]] == col1]
  }
  )
}

a <- tedsa_puf_2000_2019 %>% group_by(SUB1) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))



tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(SUB1 %in% a$SUB1[1:5])

a <- tedsa_puf_2000_2019 %>% group_by(GENDER) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(GENDER %in% a$GENDER[1:2])

a <- tedsa_puf_2000_2019 %>% group_by(EDUC) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(EDUC %in% a$EDUC[1:5])

a <- tedsa_puf_2000_2019 %>% group_by(REGION) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(REGION %in% a$REGION[1:4])

a <- tedsa_puf_2000_2019 %>% group_by(ROUTE1) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(ROUTE1 %in% a$ROUTE1[1:4])

a <- tedsa_puf_2000_2019 %>% group_by(FREQ1) %>% summarise(No_of_rows = n()) %>%
  mutate(Percentage = round(No_of_rows / sum(No_of_rows), 3) * 100) %>% 
  arrange(desc(Percentage))

tedsa_puf_2000_2019$EMPLOY[tedsa_puf_2000_2019$EMPLOY == 'Not in labor force'] <- tedsa_puf_2000_2019$DETNLF[tedsa_puf_2000_2019$EMPLOY == 'Not in labor force'] 

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% select(-DETNLF)

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% filter(FREQ1 %in% a$FREQ1[1:3])

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% mutate( RACE = case_when(
  RACE == 'White' ~ "White",
  RACE == 'Black or African American'  ~ "Black or African American",
  RACE == 'American Indian'  ~ "American Indian or Alaska Native Alone",
  RACE == 'Alaska Native'  ~ "American Indian or Alaska Native Alone",
  RACE == 'Other single race'  ~ "Others",
  RACE == 'Missing'  ~ "Others",
  RACE == 'Two or more races'  ~ "Others",
  RACE == 'Asian'  ~ "Others",
  RACE == 'Asian or Pacific Islander'  ~ "Others",
  RACE == 'Native Hawaiian or Other Pacific Islander'  ~ "Others"
)
)

tedsa_puf_2000_2019$count = 1

tedsa_puf_2000_2019 <- tedsa_puf_2000_2019 %>% group_by(AGE,ADMYR,GENDER,RACE,EDUC,STFIPS,REGION,DIVISION,SERVICES,SUB1,ROUTE1,FREQ1) %>% dplyr::summarize(gr_sum = sum(`count`)) %>% as.data.frame()

save(tedsa_puf_2000_2019, file = "data/tedsa_puf_2000_2019_final_cleaned.RData")





###### Preprocessing Population Data
population_data <- read.csv("data/sc-est2019-alldata5.csv")
for (i in colnames(population_data))
{
  if (i %in% c("SEX","REGION","DIVISION","RACE"))
  {
    population_data[[i]] <- sapply(population_data[[i]], function(col1)
    {
      names(metadata[[i]])[metadata[[i]] == col1]
    }
    )
  }
}

population_data <- population_data %>% filter(SEX != 'Total') %>% filter(ORIGIN == 0) %>%  select(-
                                                                                                    c('SUMLEV','ORIGIN','STATE','ESTIMATESBASE2010','CENSUS2010POP'))
population_data <- population_data %>% mutate( AGE_CATEGORY = case_when(
  AGE < 12 ~ "Less than 12",
  AGE < 15  ~ "12–14",
  AGE < 18  ~ "15–17",
  AGE < 21  ~ "18–20",
  AGE < 25  ~ "21–24",
  AGE < 30 ~ "25–29",
  AGE < 35  ~ "30–34",
  AGE < 40  ~ "35–39",
  AGE < 45  ~ "40–44",
  AGE < 50  ~ "45–49",
  AGE < 55  ~ "50–54",
  AGE < 65  ~ "55–64",
  AGE >= 65 ~ "65+"
)
)

population_data <- population_data %>% mutate( RACE = case_when(
  RACE == 'White' ~ "White",
  RACE == 'Black or African American'  ~ "Black or African American",
  RACE == 'Native Hawaiian or Other Pacific Islander'  ~ "Others",
  RACE == 'American Indian or Alaska Native Alone' ~ "American Indian or Alaska Native Alone",
  RACE == 'Asian'  ~ "Others",
  RACE == 'Two or more races'  ~ "Others"
)
)
population_data <- population_data %>% select(-c("AGE"))
population_data <- aggregate(.~REGION+DIVISION+NAME+SEX+RACE+AGE_CATEGORY, population_data, sum)
population_data <- population_data %>% pivot_longer(-c("REGION","DIVISION","NAME","SEX","RACE","AGE_CATEGORY"), names_to = "Year", values_to = "Population_count")
population_data$Year <- str_sub(population_data$Year,-4)
population_data1 <- read.csv("data/sc-est2010-alldata5.csv")

for (i in colnames(population_data1))
{
  if (i %in% c("SEX","REGION","DIVISION","RACE"))
  {
    population_data1[[i]] <- sapply(population_data1[[i]], function(col1)
    {
      names(metadata[[i]])[metadata[[i]] == col1]
    }
    )
  }
}

population_data1 <- population_data1 %>% filter(SEX != 'Total') %>% filter(ORIGIN == 0) %>%  select(-c('ORIGIN','STATE','SUMLEV','ESTIMATESBASE2000','CENSUS2000POP'))

population_data1 <- population_data1 %>% mutate( AGE_CATEGORY = case_when(
  AGE < 12 ~ "Less than 12",
  AGE < 15  ~ "12–14",
  AGE < 18  ~ "15–17",
  AGE < 21  ~ "18–20",
  AGE < 25  ~ "21–24",
  AGE < 30 ~ "25–29",
  AGE < 35  ~ "30–34",
  AGE < 40  ~ "35–39",
  AGE < 45  ~ "40–44",
  AGE < 50  ~ "45–49",
  AGE < 55  ~ "50–54",
  AGE < 65  ~ "55–64",
  AGE >= 65 ~ "65+"
)
)

population_data1 <- population_data1 %>% mutate( RACE = case_when(
  RACE == 'White' ~ "White",
  RACE == 'Black or African American'  ~ "Black or African American",
  RACE == 'Native Hawaiian or Other Pacific Islander'  ~ "Others",
  RACE == 'American Indian or Alaska Native Alone' ~ "American Indian or Alaska Native Alone",
  RACE == 'Asian'  ~ "Others",
  RACE == 'Two or more races'  ~ "Others"
)
)

population_data1 <- population_data1 %>% select(-c("AGE","POPESTIMATE72010","POPESTIMATE42010"))

population_data1 <- aggregate(.~REGION+DIVISION+STNAME+SEX+RACE+AGE_CATEGORY, population_data1, sum)

population_data1 <- population_data1 %>% pivot_longer(-c("REGION","DIVISION","STNAME","SEX","RACE","AGE_CATEGORY"), names_to = "Year", values_to = "Population_count")

population_data1$Year <- str_sub(population_data1$Year,-4)

names(population_data1)[names(population_data1) == 'STNAME'] <- "NAME"

final_population_data <- rbind(population_data,population_data1)

final_population_data <- final_population_data %>% rename(AGE = AGE_CATEGORY,GENDER = SEX,ADMYR = Year, STFIPS = NAME)

write.csv(final_population_data, file = "data/final_population_data.csv",row.names = FALSE)

