# Made by: Valerie Lim
# Date: 17 July 2017
# Title: Introductory exercises to understand data types in R

# ---------------------------------- Start ---------------------------------- #

### Dataframes manipulation
data <- iris

# Get dimensions
ncol(iris)
nrow(iris)
names(iris) # column names
str(iris) # see structure
summary(iris) # see average, max, min stats for each column

# Preview first few rows - check if got header
head(iris)

# Preview last few rows - check if got tail/sum columns
tail(iris)

# Refer to a specific column
iris$Sepal.Length <- example_data

# Check stats for any set of data
mean(example_data)
min(example_data)
max(example_data)
sum(example_data)
sd(example_data)

# Add more data rows to the BOTTOM of the dataset 
extra <- c(151, 6.0, 3.0, 4.2, 3.1, "virginica")
iris_extra <- rbind(iris, extra)

# Add more data COLUMNS
iris_new_column <- cbind(iris, iris$Sepal.Width) # Adds duplicate column, width

# ---------------------------------- Prac ---------------------------------- #

y1 = 1
y2 = 10

z = y1 < y2
class(z)

# Matrix exercise
data1 <- c(1,26,24,68)
test1 <- matrix(data1, nrow=2,ncol=2)

# Populate by rows instead of columns
test1 <- matrix(data1, nrow=2,ncol=2, byrow=TRUE)

# Add names
rnames <- c("R1", "R2")
cnames <- c("C1", "C2")
test1 <- matrix(data1, nrow=2,ncol=2, byrow=TRUE, 
                dimnames=list(rnames, cnames))
test2 <- matrix(1:20, nrow=2)
test2

# Array
dim1 <- c("row1", "row2")
dim2 <- c("Col1", "Col2", "Col3")
dim3 <- c("slice1", "slice2", "slice3", "slice4")
applejuice <- array(1:24, dim = c(2, 3, 4), dimnames = list(dim1,dim2, dim3))
applejuice

# Dataframe
patientID <- c(1,2,3,4)
age <- c(11, 23, 45, 51)
diabetes <- c("Type1", "Type1", "Type2", "Type1")
status <- c("Poor", "Improved", "Excellent", "Poor")
patientdata <- data.frame(patientID, age, diabetes, status)
patientdata         

# Lists
g <- "My first list!"
h <- c(1,2,3,4)
j <- matrix (1:10, nrow=5)
k <- c("one", "two", "three")
i <- ("hello world!")
mylist <- list(title=g, ages=h, "this is a table"=j, strings=k, stuff=i)
as.data.frame(mylist)
 
names(iris)
names(data) <- c("lol1", "lol2")
names(data)

iris_new <- iris
iris_new <- cbind(iris_new, newcol=0)
newcol <- c()
iris_new

# ---------------------------------- Loops ---------------------------------- #

# IF loops
i <- 5
if(i>6){
    print("This will not be printed")
} else {
    print("This will be printed")
}

# Basic function
addsfour <- function(x){
    answer <- x + 4
    return(answer)
}

# WHILE loops

i<-1
while(i<5){
  print (i)
  i <- i+1
}

# fibonnacci seq

fibonnaci=function(n) {
  x = numeric(n)
  x[1] = numeric(1)
  x[2] = numeric(2)
  for(i in 3:n) x[i] = x[i-1] + x[i-2]
  return(x)
}
vast(4)
vast(5)
vast(2)
vast(3)
