# Credit Risk Analysis
# Author : Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - November 13, 2021.

# Import Libraries
library(readxl)
library("C50")
library(reshape2)

# Import Dataset
df_credit <- read_excel("C:/Users/Acer/Desktop/project/R/Credit Risk Analysis/credit_scoring.xlsx")
dplyr::glimpse(df_credit)

# Data Preparation 
df_credit$risk_rating <- as.factor(df_credit$risk_rating) #Change class Variable data type as factor
str(df_credit)

input_columns <- c("durasi_pinjaman_bulan", "jumlah_tanggungan") #Input variable
datafeed <- df_credit[ , input_columns ]
str(datafeed)

# Training Set and Testing Set
set.seed(100) #Uniform random number collection
indeks_training_set <- sample(900, 800) #Create a random sequence with a value range of 1 to 900, but taken as many as 800 values

input_training_set <- datafeed[indeks_training_set,] #Create Training Set and Testing Set
class_training_set <- df_credit[indeks_training_set,]$risk_rating
input_testing_set <- datafeed[-indeks_training_set,]
str(input_training_set)
str(class_training_set)
str(input_testing_set)

# Building a Model (Decision Tree Algorithm)
risk_rating_model <- C5.0(input_training_set, class_training_set, control = C5.0Control(label="Risk Rating"))
summary(risk_rating_model)

# Decision Tree Diagrams
plot(risk_rating_model)

# Save Test Set Prediction Results
input_testing_set$risk_rating <- df_credit[-indeks_training_set,]$risk_rating
input_testing_set$prediction_result <- predict(risk_rating_model, input_testing_set)
print(input_testing_set)

# Confusion Matrix
dcast(prediction_result ~ risk_rating, data=input_testing_set)

# The Number of Data with Correct Prediction
nrow(input_testing_set[input_testing_set$risk_rating==input_testing_set$prediction_result,])

# The Number of Data with Wrong Prediction
nrow(input_testing_set[input_testing_set$risk_rating!=input_testing_set$prediction_result,])

# Application
new_application <- data.frame(jumlah_tanggungan = 6, durasi_pinjaman_bulan = 12) #New submission data
print(new_application)

predict(risk_rating_model, new_application) #Predict new submission data