# Market Basket Analysis
# Author : Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - November 11, 2021.

# Import Libraries
library(arules)
library(arulesViz)

# Import Dataset
transaksi <- read.transactions(file="C:/Users/Acer/Desktop/project/R/Market Basket Analysis/data_transaksi2.txt", 
                               format="single", sep="\t", cols=c(1,2), skip=1)
summary(transaksi) # Summary
inspect(transaksi) # Inspect the result

# List of Transaction Items
transaksi@itemInfo

# List of Transaction Code
transaksi@itemsetInfo

# Item Frequency
data_item <- itemFrequency(transaksi, type="absolute")
data_item

# Top 3 Stats
data_item <- sort(data_item, decreasing = TRUE)
data_item <- data_item[1:3] # Take the first 3 items
data_item <- data.frame("Product Name"=names(data_item), "Total"=data_item, 
                        row.names=NULL) # Convert to dataframe
print(data_item)

# Item Frequency Graph
itemFrequencyPlot(transaksi, topN=10, type='absolute')

# Rules
mba <- apriori(transaksi, parameter = list(supp = 0.1, minlen=2, confidence = 0.5))
summary(mba)

mba <- sort(mba, by="confidence", decreasing=TRUE) # Inspect the result
inspect(mba[1:10])

# Set LHS and RHS
# RHS
serum_rules_rhs <- apriori(transaksi, parameter = list(supp = 0.1, minlen=2, confidence = 0.5), appearance = list(default="lhs", rhs="Serum Vitamin"))
summary(serum_rules_rhs)
inspect(serum_rules_rhs) # Inspect the result

# LHS
sepatu_rules_lhs <- apriori(transaksi, parameter = list(supp = 0.1, minlen=2, confidence = 0.5), appearance = list(default="rhs", lhs="Sepatu Sandal Anak"))
summary(sepatu_rules_lhs)
inspect(sepatu_rules_lhs) # Inspect the result

# RHS and LHS
sepatu_serum_rules <- apriori(transaksi, parameter = list(supp = 0.1, minlen=2, confidence = 0.5), appearance = list(rhs="Serum Vitamin", lhs="Sepatu Sandal Anak"))
summary(sepatu_serum_rules)
inspect(sepatu_serum_rules) # Inspect the result

# Lift
inspect(subset(mba, (lhs %in% "Sepatu Sandal Anak" | rhs %in% "Serum Vitamin") & lift>1))

# %ain%
inspect(subset(mba, (lhs %ain% c("Baju Batik Wanita", "Sepatu Sandal Anak"))))

# Visualization of Rules
# The Network Graph
subrules <- head(mba, n = 5, by = "confidence")
plot(subrules, method = "graph")

# The Parallel Coordinate Plot
plot(subrules, method="paracoord")

