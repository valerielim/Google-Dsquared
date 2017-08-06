# Made by: Valerie
# Date: 19 July 2017
# Title: Making a Correlation matrix with P values

# ----------------  Making a Correlation matrix with P values ---------------- #

install.packages("Hmisc")
library(Hmisc)
?rcorr

### Finding Correlations

# Select only numerical columns
iris_num <- iris[,1:4]

# Version 1 - correlations using COR
cor(iris_num[,unlist(lapply(iris_num, is.numeric))])

# Version 2 - correlations using RCORR
# Prints p value too, so more useful than COR
rcorr(as.matrix(iris_num))
