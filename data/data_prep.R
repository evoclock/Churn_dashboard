# Data prep refactored script based on the example shown here 
# https://github.com/santma/Telecommunications-Customer-Attrition-Dashboard
# I went mainly for ifelse functions as a matter of choice. While I find 
# individual operations to be readable enough, the logical structure of ifelse
# conditional statements is better imo.

# Importing dataset
dataset = read.csv('./data/Telco-Customer-Churn.csv')

# Handling 'No internet service' and 'No phone service' 
library(dplyr)
dataset = dataset %>%
  mutate_if(is.character, ~ifelse(. %in% c('No internet service', 'No phone service'), 
                                  'No', .)) # I like to place the option to the 
# condition on a separate line as it helps me with readability

# Converting 'SeniorCitizen' to descriptive categories
dataset$SeniorCitizen = ifelse(dataset$SeniorCitizen == 1, 'is Senior Citizen', 
                               'is not Senior Citizen') 

# Replacing values in categorical columns
dataset$Partner = ifelse(dataset$Partner == 'Yes', 'has Partner', 
                         'Single')
dataset$Dependents = ifelse(dataset$Dependents == 'Yes', 'has Dependents', 
                            'no Dependents')
dataset$InternetService = ifelse(dataset$InternetService == 'No', 'No Internet', 
                                 dataset$InternetService)


# Combining 'PhoneService' and 'MultipleLines' into a new column 'PhoneServ'
# If the concatenated value is 'Yes Yes', it replaces it with 'Multiple Lines'.
# If the concatenated value is 'Yes No', it replaces it with 'One Line'.
# If the concatenated value is 'No No', it replaces it with 'No Phone'.
# If none of the above conditions are met it keeps the original value unchanged.

dataset$PhoneServ = paste(dataset$PhoneService, dataset$MultipleLines)
dataset$PhoneServ = ifelse(dataset$PhoneServ == 'Yes Yes', 'Multiple Lines',
                           ifelse(dataset$PhoneServ == 'Yes No', 'One Line',
                                  ifelse(dataset$PhoneServ == 'No No', 'No Phone', 
                                         dataset$PhoneServ)))

# Combining 'StreamingTV' and 'StreamingMovies' into a new column 'Streaming'
# in a similar way as above.
dataset$Streaming = paste(dataset$StreamingTV, dataset$StreamingMovies)
dataset$Streaming = ifelse(dataset$Streaming == 'Yes Yes', 'TV & Movies',
                           ifelse(dataset$Streaming == 'Yes No', 'Only TV',
                                  ifelse(dataset$Streaming == 'No Yes', 
                                         'Only Movies',
                                         ifelse(dataset$Streaming == 'No No', 
                                                'No Streaming', 
                                                dataset$Streaming))))

# Adding Tenure Categories
# The 'tenure' column is used to create a new 'tenure_group' column with 
# categorical values based on specific tenure ranges (e.g., 0-12 Months, 
# 13-24 Months, etc.) and converting to factor type
dataset$tenure_group = cut(dataset$tenure, breaks = c(0, 12, 24, 36, 48, 60, Inf),
                           labels = c("0-12 Months", 
                                      "13-24 Months", 
                                      "25-36 Months", 
                                      "37-48 Months", 
                                      "49-60 Months", 
                                      "over 60 Months"))

# Setting Churn Values (convert to character type with either churn or stayed)
dataset$Churn = ifelse(dataset$Churn == 'Yes', 'Churn', 'Stayed')

# # Convert character columns to factors
# char_columns = c('gender', 'Dependents', 'Partner', 'Churn', 'SeniorCitizen', 
#                  'InternetService', 'PhoneService', 'MultipleLines', 
#                  'StreamingTV', 'StreamingMovies', 'PhoneServ', 'Streaming')
# dataset[char_columns] = lapply(dataset[char_columns], as.factor)

# Separating churn and non-churn customers
churn = filter(dataset, Churn == 'Churn')
non_churn = filter(dataset, Churn == 'Stayed')

