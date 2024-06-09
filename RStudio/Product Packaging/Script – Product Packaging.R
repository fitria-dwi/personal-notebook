
# Import Library
library(arules)

# Import Dataset
transaksi_retail <- read.transactions(file="https://storage.googleapis.com/dqlab-dataset/transaksi_dqlab_retail.tsv", format="single", sep="\t", cols=c(1,2), skip=1)
transaksi_retail

# Top 10 Product
top_10 <- sort(itemFrequency(transaksi_retail, type="absolute"), decreasing = TRUE)[1:10]
top_10 <- data.frame("Product Names"=names(top_10), "Total"=top_10, row.names=NULL)
print(top_10)

# Bottom 10 Product
bottom_10 <- sort(itemFrequency(transaksi_retail, type="absolute"), decreasing = FALSE)[1:10]
bottom_10 <- data.frame("Product Names"=names(bottom_10), "Total"=bottom_10, row.names=NULL)
print(bottom_10)

# Finding Attractive Product Combinations
apriori_rules <- apriori(transaksi_retail, parameter = list(supp=10/nrow(transaksi_retail), minlen=2, maxlen=3, confidence=0.5))

data_kombinasi <- sort(apriori_rules, by='lift', decreasing = TRUE)[1:10]
inspect(data_kombinasi)

# Finding for Product Packages that can be paired with Slow-Moving Items
apriori_rules2 <- apriori(transaksi_retail, parameter = list(supp=10/nrow(transaksi_retail), minlen=2, maxlen=3, confidence=0.1))

item_slow1 <- subset(apriori_rules2, rhs %in% 'Tas Makeup' & lift>1)
item_slow1 <- sort(item_slow1, by='lift', decreasing = TRUE)[1:3]

item_slow2 <- subset(apriori_rules2, rhs %in% 'Baju Renang Pria Anak-anak' & lift>1)
item_slow2 <- sort(item_slow2, by='lift', decreasing = TRUE)[1:3]

apriori_rules3 <- c(item_slow1,item_slow2)
inspect(apriori_rules3)