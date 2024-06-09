**Credit Risk Analysis**
================
**Author : Fitria Dwi Wulandari (<wulan391@sci.ui.ac.id>) - November 13,
2021.**

#### **Goals**:

-   Looking for patterns to create a decision-making model for new loan
    applications.
-   Predict the value in the risk rating column based on other
    variables.

------------------------------------------------------------------------

#### **Import Libraries**

``` r
library(readxl)
```

    ## Warning: package 'readxl' was built under R version 4.1.1

``` r
library("C50")
```

    ## Warning: package 'C50' was built under R version 4.1.1

``` r
library(reshape2)
```

    ## Warning: package 'reshape2' was built under R version 4.1.1

#### **Import Dataset**

``` r
df_credit <- read_excel("C:/Users/Acer/Desktop/project/R/Credit Risk Analysis/credit_scoring.xlsx")
```

``` r
dplyr::glimpse(df_credit)
```

    ## Rows: 900
    ## Columns: 7
    ## $ kode_kontrak            <chr> "AGR-000001", "AGR-000011", "AGR-000030", "AGR~
    ## $ pendapatan_setahun_juta <dbl> 295, 271, 159, 210, 165, 220, 70, 88, 163, 100~
    ## $ kpr_aktif               <chr> "YA", "YA", "TIDAK", "YA", "TIDAK", "TIDAK", "~
    ## $ durasi_pinjaman_bulan   <dbl> 48, 36, 12, 12, 36, 24, 36, 48, 48, 36, 12, 36~
    ## $ jumlah_tanggungan       <dbl> 5, 5, 0, 3, 0, 5, 3, 3, 5, 6, 0, 0, 5, 4, 4, 3~
    ## $ rata_rata_overdue       <chr> "61 - 90 days", "61 - 90 days", "0 - 30 days",~
    ## $ risk_rating             <dbl> 4, 4, 1, 3, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2~

It can be seen that there are 900 data rows (Observations) and 7 columns
(Variables).

-   `kode_kontrak` : Contract ID.
-   `pendapatan_setahun_juta` : Income in millions per year.
-   `kpr_aktif` : Whether have active mortgage or not.
-   `durasi_pinjaman_bulan` : Loan duration in months.
-   `jumlah_tanggungan` : The number of dependents.
-   `rata_rata_overdue` : Late payment.
-   `risk_rating` : Level of risk.

#### **Data Preparation**

``` r
df_credit$risk_rating <- as.factor(df_credit$risk_rating) #Change class Variable data type as factor
str(df_credit)
```

    ## tibble [900 x 7] (S3: tbl_df/tbl/data.frame)
    ##  $ kode_kontrak           : chr [1:900] "AGR-000001" "AGR-000011" "AGR-000030" "AGR-000043" ...
    ##  $ pendapatan_setahun_juta: num [1:900] 295 271 159 210 165 220 70 88 163 100 ...
    ##  $ kpr_aktif              : chr [1:900] "YA" "YA" "TIDAK" "YA" ...
    ##  $ durasi_pinjaman_bulan  : num [1:900] 48 36 12 12 36 24 36 48 48 36 ...
    ##  $ jumlah_tanggungan      : num [1:900] 5 5 0 3 0 5 3 3 5 6 ...
    ##  $ rata_rata_overdue      : chr [1:900] "61 - 90 days" "61 - 90 days" "0 - 30 days" "46 - 60 days" ...
    ##  $ risk_rating            : Factor w/ 5 levels "1","2","3","4",..: 4 4 1 3 2 1 2 2 2 2 ...

``` r
input_columns <- c("durasi_pinjaman_bulan", "jumlah_tanggungan") #Input variable
datafeed <- df_credit[ , input_columns ]
str(datafeed)
```

    ## tibble [900 x 2] (S3: tbl_df/tbl/data.frame)
    ##  $ durasi_pinjaman_bulan: num [1:900] 48 36 12 12 36 24 36 48 48 36 ...
    ##  $ jumlah_tanggungan    : num [1:900] 5 5 0 3 0 5 3 3 5 6 ...

#### **Training Set and Testing Set**

``` r
set.seed(100) #Uniform random number collection
indeks_training_set <- sample(900, 800) #Create a random sequence with a value range of 1 to 900, but taken as many as 800 values
```

``` r
input_training_set <- datafeed[indeks_training_set,]
str(input_training_set)
```

    ## tibble [800 x 2] (S3: tbl_df/tbl/data.frame)
    ##  $ durasi_pinjaman_bulan: num [1:800] 36 24 36 36 36 24 12 48 48 12 ...
    ##  $ jumlah_tanggungan    : num [1:800] 1 1 5 1 5 3 3 3 0 0 ...

``` r
class_training_set <- df_credit[indeks_training_set,]$risk_rating
str(class_training_set)
```

    ##  Factor w/ 5 levels "1","2","3","4",..: 1 1 4 1 5 3 3 3 2 1 ...

``` r
input_testing_set <- datafeed[-indeks_training_set,]
str(input_testing_set)
```

    ## tibble [100 x 2] (S3: tbl_df/tbl/data.frame)
    ##  $ durasi_pinjaman_bulan: num [1:100] 12 36 48 36 48 48 12 12 12 12 ...
    ##  $ jumlah_tanggungan    : num [1:100] 0 0 3 3 6 5 0 0 0 4 ...

#### **Building a Model**

The algorithm used to build the model is a **decision tree algorithm**.

``` r
risk_rating_model <- C5.0(input_training_set, class_training_set, control = C5.0Control(label="Risk Rating"))
summary(risk_rating_model)
```

    ## 
    ## Call:
    ## C5.0.default(x = input_training_set, y = class_training_set, control
    ##  = C5.0Control(label = "Risk Rating"))
    ## 
    ## 
    ## C5.0 [Release 2.07 GPL Edition]      Sat Nov 20 17:53:39 2021
    ## -------------------------------
    ## 
    ## Class specified by attribute `Risk Rating'
    ## 
    ## Read 800 cases (3 attributes) from undefined.data
    ## 
    ## Decision tree:
    ## 
    ## jumlah_tanggungan > 4:
    ## :...durasi_pinjaman_bulan <= 24: 4 (105/30)
    ## :   durasi_pinjaman_bulan > 24: 5 (120/51)
    ## jumlah_tanggungan <= 4:
    ## :...jumlah_tanggungan > 2: 3 (216/20)
    ##     jumlah_tanggungan <= 2:
    ##     :...durasi_pinjaman_bulan <= 36: 1 (264/80)
    ##         durasi_pinjaman_bulan > 36:
    ##         :...jumlah_tanggungan <= 0: 2 (37/7)
    ##             jumlah_tanggungan > 0: 3 (58/4)
    ## 
    ## 
    ## Evaluation on training data (800 cases):
    ## 
    ##      Decision Tree   
    ##    ----------------  
    ##    Size      Errors  
    ## 
    ##       6  192(24.0%)   <<
    ## 
    ## 
    ##     (a)   (b)   (c)   (d)   (e)    <-classified as
    ##    ----  ----  ----  ----  ----
    ##     184     2     5     6     6    (a): class 1
    ##      80    30    19     6    11    (b): class 2
    ##             3   250                (c): class 3
    ##             2          75    34    (d): class 4
    ##                        18    69    (e): class 5
    ## 
    ## 
    ##  Attribute usage:
    ## 
    ##  100.00% jumlah_tanggungan
    ##   73.00% durasi_pinjaman_bulan
    ## 
    ## 
    ## Time: 0.0 secs

**Interpretation:**

1.  The decision-making path to determine the risk rating is, If the
    number of dependents (`jumlah_tanggungan`) &gt; 4 then it is
    necessary to look at the following conditions, namely:
    -   If the loan duration (`durasi_pinjaman_bulan`) is up to 24
        months, then the risk rating classification is 4. This path
        classifies 105 data, but 30 of 105 data are misclassified.
    -   If the loan duration (`durasi_pinjaman_bulan`) more than 24
        months, then the risk rating classification is 5. This path
        classifies 120 data, but 51 of 120 data are misclassified.
    -   etc.
2.  The percentage of model error is shown by the evaluation in training
    data section. The information obtained are:
    -   800 cases is the number of case processed.
    -   Size = 6 is the number of leaf nodes in the decision tree.
    -   Errors = 192 (24%): 192 is the number of misclassified records,
        and 24% is ratio of the entire population.
3.  The level of importance of the use of each variable in the decision
    tree model is shown by the attribute usage section. The first is
    occupied by the number of dependents (`jumlah_tanggungan`) with a
    value of 100% and followed by loan duration
    (`durasi_pinjaman_bulan`) with 73%.

#### **Decision Tree Diagrams**

``` r
plot(risk_rating_model)
```

![Rplot01](https://user-images.githubusercontent.com/74573342/142723734-b69dc1e4-c56c-4b16-86a1-2228deeb9c8f.png)


#### **Save Test Set Prediction Results**

``` r
input_testing_set$risk_rating <- df_credit[-indeks_training_set,]$risk_rating
input_testing_set$prediction_result <- predict(risk_rating_model, input_testing_set)
print(input_testing_set)
```

    ## # A tibble: 100 x 4
    ##    durasi_pinjaman_bulan jumlah_tanggungan risk_rating prediction_result
    ##                    <dbl>             <dbl> <fct>       <fct>            
    ##  1                    12                 0 1           1                
    ##  2                    36                 0 2           1                
    ##  3                    48                 3 2           3                
    ##  4                    36                 3 2           3                
    ##  5                    48                 6 2           5                
    ##  6                    48                 5 2           5                
    ##  7                    12                 0 1           1                
    ##  8                    12                 0 1           1                
    ##  9                    12                 0 1           1                
    ## 10                    12                 4 3           3                
    ## # ... with 90 more rows

#### **Confusion Matrix**

``` r
dcast(prediction_result ~ risk_rating, data=input_testing_set)
```

    ## Using prediction_result as value column: use value.var to override.

    ## Aggregation function missing: defaulting to length

    ##   prediction_result  1 2  3 4  5
    ## 1                 1 24 6  0 0  0
    ## 2                 2  0 3  1 0  0
    ## 3                 3  0 2 37 0  0
    ## 4                 4  0 0  0 7  0
    ## 5                 5  0 2  0 2 16

**Interpretation:**

1.  The number **24** in the first column of the first row indicates the
    number of data that is correctly classified or predicted, where:
    -   The classification of the model on the data gets a `risk_rating`
        of 1.
    -   In actual data, the `risk_rating` value is also 1.
2.  The number **6** in the second column of the first row indicates the
    number of incorrectly predicted data, where:
    -   The classification of the model on the data gets a `risk_rating`
        of 2.
    -   In actual data, the `risk_rating` value is 1.
3.  etc.

**Note:** The lower right diagonal in the confusion matrix shows all the
correct predictions of the model.

#### **The Number of Data with Correct Prediction**

``` r
nrow(input_testing_set[input_testing_set$risk_rating==input_testing_set$prediction_result,])
```

    ## [1] 87

This number 87 shows the amount of data with correct predictions for the
testing set, then the percentage of correct predictions is 87%.

#### **The Number of Data with Wrong Prediction**

``` r
nrow(input_testing_set[input_testing_set$risk_rating!=input_testing_set$prediction_result,])
```

    ## [1] 13

It can be seen that errors that occur due to misclassification by 13%.

#### Application

``` r
new_application <- data.frame(jumlah_tanggungan = 6, durasi_pinjaman_bulan = 12) #New submission data
print(new_application)
```

    ##   jumlah_tanggungan durasi_pinjaman_bulan
    ## 1                 6                    12

``` r
predict(risk_rating_model, new_application) #Predict new submission data
```

    ## [1] 4
    ## Levels: 1 2 3 4 5

This means that the `risk_rating` prediction result for this new
application is 4, out of possibilities 1, 2, 3, 4 and 5. A value of 4 is
a fairly high risk value, so this new application may be rejected in
accordance with the policy of the borrowing institution.
