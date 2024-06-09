**Project Machine Learning for Retail: Product Packaging**
================
**Author: Fitria Dwi Wulandari (<wulan391@sci.ui.ac.id>) - September 21,
2021.**


#### **Problems**:

1.  More competitors.
2.  There are still many products that are in abundant stock.

#### **Goals**:

Create innovative packages, where products that previously did not sell
well but have market share can be packaged and sold.

#### **Responsibilities**:

In order to increase profits and customer loyalty, companies have to
identify attractive product packages.

1.  Gain insights from the top 10 and bottom 10 products sold.
2.  Get a list of all product package combinations with strong
    correlations.
3.  Get a list of all product package combinations with a specific item.

------------------------------------------------------------------------

#### **Import Library**

``` r
library(arules)
```

    ## Warning: package 'arules' was built under R version 4.1.1

#### **Import Dataset**

-   Transaction data for 3 months.
-   Consisting of 2 variables (transaction code, product name).

``` r
transaksi_retail <- read.transactions(file="https://storage.googleapis.com/dqlab-dataset/transaksi_dqlab_retail.tsv", format="single", sep="\t", cols=c(1,2), skip=1)
transaksi_retail
```

    ## transactions in sparse format with
    ##  3450 transactions (rows) and
    ##  69 items (columns)

#### **Top 10 Product**

``` r
top_10 <- sort(itemFrequency(transaksi_retail, type="absolute"), decreasing = TRUE)[1:10]
top_10 <- data.frame("Product Names"=names(top_10), "Total"=top_10, row.names=NULL)
print(top_10)
```

    ##                Product.Names Total
    ## 1               Shampo Biasa  2075
    ## 2              Serum Vitamin  1685
    ## 3          Baju Batik Wanita  1312
    ## 4          Baju Kemeja Putih  1255
    ## 5       Celana Jogger Casual  1136
    ## 6                Cover Koper  1086
    ## 7         Sepatu Sandal Anak  1062
    ## 8  Tali Pinggang Gesper Pria  1003
    ## 9        Sepatu Sport merk Z   888
    ## 10              Wedges Hitam   849

#### **Bottom 10 Product**

``` r
bottom_10 <- sort(itemFrequency(transaksi_retail, type="absolute"), decreasing = FALSE)[1:10]
bottom_10 <- data.frame("Product Names"=names(bottom_10), "Total"=bottom_10, row.names=NULL)
print(bottom_10)
```

    ##                 Product.Names Total
    ## 1     Celana Jeans Sobek Pria     9
    ## 2                Tas Kosmetik    11
    ## 3                Stripe Pants    19
    ## 4                    Pelembab    24
    ## 5      Tali Ban Ikat Pinggang    27
    ## 6  Baju Renang Pria Anak-anak    32
    ## 7                    Hair Dye    46
    ## 8          Atasan Baju Belang    56
    ## 9  Tas Sekolah Anak Perempuan    71
    ## 10              Dompet Unisex    75

#### **Finding Attractive Product Combinations**

The 10 most “attractive” product combination packages with the following
conditions:

1.  Having close associations or relationships.
2.  A minimum of 2 product combinations and a maximum of 3 items.
3.  The product combination appears in at least 10 of all transactions.
4.  Have a minimum confidence level of 50 percent.

``` r
apriori_rules <- apriori(transaksi_retail, parameter = list(supp=10/nrow(transaksi_retail), minlen=2, maxlen=3, confidence=0.5))
```

    ## Apriori
    ## 
    ## Parameter specification:
    ##  confidence minval smax arem  aval originalSupport maxtime     support minlen
    ##         0.5    0.1    1 none FALSE            TRUE       5 0.002898551      2
    ##  maxlen target  ext
    ##       3  rules TRUE
    ## 
    ## Algorithmic control:
    ##  filter tree heap memopt load sort verbose
    ##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
    ## 
    ## Absolute minimum support count: 10 
    ## 
    ## set item appearances ...[0 item(s)] done [0.00s].
    ## set transactions ...[69 item(s), 3450 transaction(s)] done [0.00s].
    ## sorting and recoding items ... [68 item(s)] done [0.00s].
    ## creating transaction tree ... done [0.00s].
    ## checking subsets of size 1 2 3

    ## Warning in apriori(transaksi_retail, parameter = list(supp = 10/
    ## nrow(transaksi_retail), : Mining stopped (maxlen reached). Only patterns up to a
    ## length of 3 returned!

    ##  done [0.01s].
    ## writing ... [4637 rule(s)] done [0.00s].
    ## creating S4 object  ... done [0.00s].

``` r
data_kombinasi <- sort(apriori_rules, by='lift', decreasing = TRUE)[1:10]
inspect(data_kombinasi)
```

    ##      lhs                             rhs                              support confidence    coverage     lift count
    ## [1]  {Tas Makeup,                                                                                                  
    ##       Tas Pinggang Wanita}        => {Baju Renang Anak Perempuan} 0.010434783  0.8780488 0.011884058 24.42958    36
    ## [2]  {Tas Makeup,                                                                                                  
    ##       Tas Travel}                 => {Baju Renang Anak Perempuan} 0.010144928  0.8139535 0.012463768 22.64629    35
    ## [3]  {Tas Makeup,                                                                                                  
    ##       Tas Ransel Mini}            => {Baju Renang Anak Perempuan} 0.011304348  0.7358491 0.015362319 20.47322    39
    ## [4]  {Sunblock Cream,                                                                                              
    ##       Tas Pinggang Wanita}        => {Kuas Makeup }               0.016231884  0.6913580 0.023478261 20.21343    56
    ## [5]  {Baju Renang Anak Perempuan,                                                                                  
    ##       Tas Pinggang Wanita}        => {Tas Makeup}                 0.010434783  0.8000000 0.013043478 19.57447    36
    ## [6]  {Baju Renang Anak Perempuan,                                                                                  
    ##       Tas Ransel Mini}            => {Tas Makeup}                 0.011304348  0.7959184 0.014202899 19.47460    39
    ## [7]  {Baju Renang Anak Perempuan,                                                                                  
    ##       Celana Pendek Green/Hijau}  => {Tas Makeup}                 0.010144928  0.7777778 0.013043478 19.03073    35
    ## [8]  {Tas Makeup,                                                                                                  
    ##       Tas Waist Bag}              => {Baju Renang Anak Perempuan} 0.004347826  0.6818182 0.006376812 18.96994    15
    ## [9]  {Celana Pendek Green/Hijau,                                                                                   
    ##       Tas Makeup}                 => {Baju Renang Anak Perempuan} 0.010144928  0.6730769 0.015072464 18.72674    35
    ## [10] {Dompet Flip Cover,                                                                                           
    ##       Sunblock Cream}             => {Kuas Makeup }               0.016231884  0.6292135 0.025797101 18.39650    56

``` r
write(data_kombinasi, file="kombinasi_retail.txt")
```

#### **Finding for Product Packages that can be paired with Slow-Moving Items**

Slow-moving items are products whose sales movements are slow or not
fast enough. This will be problematic if the product items are still
piling up. The reason why it doesn’t sell may be because the price is
not good and it is rarely needed if sold individually.

**Solution**: Create an attractive package consisting of slow-moving
products and other products that have strong associations with these
slow-moving products. The two product items are “Tas Makeup” and “Baju
Renang Pria Anak-anak”. The following are the conditions for product
combination packages:

1.  Having close associations or relationships.
2.  A minimum of 2 product combinations and a maximum of 3 items.
3.  The product combination appears in at least 10 of all transactions.
4.  Have a minimum confidence level of 10 percent.

``` r
apriori_rules2 <- apriori(transaksi_retail, parameter = list(supp=10/nrow(transaksi_retail), minlen=2, maxlen=3, confidence=0.1))
```

    ## Apriori
    ## 
    ## Parameter specification:
    ##  confidence minval smax arem  aval originalSupport maxtime     support minlen
    ##         0.1    0.1    1 none FALSE            TRUE       5 0.002898551      2
    ##  maxlen target  ext
    ##       3  rules TRUE
    ## 
    ## Algorithmic control:
    ##  filter tree heap memopt load sort verbose
    ##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
    ## 
    ## Absolute minimum support count: 10 
    ## 
    ## set item appearances ...[0 item(s)] done [0.00s].
    ## set transactions ...[69 item(s), 3450 transaction(s)] done [0.00s].
    ## sorting and recoding items ... [68 item(s)] done [0.00s].
    ## creating transaction tree ... done [0.00s].
    ## checking subsets of size 1 2 3

    ## Warning in apriori(transaksi_retail, parameter = list(supp = 10/
    ## nrow(transaksi_retail), : Mining stopped (maxlen reached). Only patterns up to a
    ## length of 3 returned!

    ##  done [0.00s].
    ## writing ... [39832 rule(s)] done [0.00s].
    ## creating S4 object  ... done [0.01s].

``` r
item_slow1 <- subset(apriori_rules2, rhs %in% 'Tas Makeup' & lift>1)
item_slow1 <- sort(item_slow1, by='lift', decreasing = TRUE)[1:3]

item_slow2 <- subset(apriori_rules2, rhs %in% 'Baju Renang Pria Anak-anak' & lift>1)
item_slow2 <- sort(item_slow2, by='lift', decreasing = TRUE)[1:3]

apriori_rules3 <- c(item_slow1,item_slow2)
inspect(apriori_rules3)
```

    ##     lhs                             rhs                              support confidence   coverage     lift count
    ## [1] {Baju Renang Anak Perempuan,                                                                                 
    ##      Tas Pinggang Wanita}        => {Tas Makeup}                 0.010434783  0.8000000 0.01304348 19.57447    36
    ## [2] {Baju Renang Anak Perempuan,                                                                                 
    ##      Tas Ransel Mini}            => {Tas Makeup}                 0.011304348  0.7959184 0.01420290 19.47460    39
    ## [3] {Baju Renang Anak Perempuan,                                                                                 
    ##      Celana Pendek Green/Hijau}  => {Tas Makeup}                 0.010144928  0.7777778 0.01304348 19.03073    35
    ## [4] {Gembok Koper,                                                                                               
    ##      Tas Waist Bag}              => {Baju Renang Pria Anak-anak} 0.004057971  0.2745098 0.01478261 29.59559    14
    ## [5] {Flat Shoes Ballerina,                                                                                       
    ##      Gembok Koper}               => {Baju Renang Pria Anak-anak} 0.004057971  0.1866667 0.02173913 20.12500    14
    ## [6] {Celana Jeans Sobek Wanita,                                                                                  
    ##      Jeans Jumbo}                => {Baju Renang Pria Anak-anak} 0.005507246  0.1210191 0.04550725 13.04737    19

``` r
write(apriori_rules3,file= "kombinasi_retail_slow_moving.txt")
```
