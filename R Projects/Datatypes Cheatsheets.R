# Title: Cheatsheet R - Datatypes
# Date: 14 Aug 2017 Monday
# Made By: Valerie

#### Variables
# Qualitative -- Often string, usually Categorical in nature. 
# Data can be nominal (gender categories) or ordinal (Level of education). 
# Quantitative -- Often numerical, discrete or continuous
# Data can be interval (IQ, no true zero) or ratio (true zero, monetary values). 

#### Vectors
foo <- c(1,2,3,4)
bar <- c("rowname", "columnname")
baz <- c("apple", "orange")

#### Matrices
matrix_name <- c(foo, nrows=2, ncol=2, dimnames=list(bar)) 
another_matrix <- c(1:20, nrows=5, ncol=4)

#### Arrays
array_name <- array(foo, c(2,2), dimnames=list(bar, baz))

#### Dataframes
patientID <- c(1, 2, 3, 4)
age <- c(25, 34, 28, 52)
diabetes <- c("Type1", "Type2", "Type1", "Type1")
status <- c("Poor", "Improved", "Excellent", "Poor")
patientdata <- data.frame(patientID, age, diabetes, status)

#### Lists - can contain many sublists
g <- "My First List"
h <- c(25, 26, 18, 39)
j <- matrix(1:10, nrow=5)
k <- c("one", "two", "three")
mylist <- list(title=g,ages=h, j, k)
