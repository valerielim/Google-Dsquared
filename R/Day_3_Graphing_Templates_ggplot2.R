# Made by: Valerie
# Date: 19 July 2017 (Wed)
# Title: Template formulas for ploting graphs using ggplot2 and native on R

# ----------------------------------------------------------------------------- #
# Dataset: Iris (native) 

###### GGPLOT2

# Scatterplot with Colour, Legend
plotthis <- ggplot2::ggplot(iris, aes(Sepal.Length, Sepal.Width)) + 
  geom_point(aes(shape = Species, 
                 color = Petal.Width, 
                 alpha = 0.6)) +             # translucency
  labs(shape="Species", colour="Petal Width")
ggplotly(plotthis)

# Histogram with Colour, Legend
plotthis = ggplot(iris, aes(Petal.Length, fill = Species)) + 
  geom_bar() 
ggplotly(plotthis)

# Pie Chart
plotthis = ggplot(iris, aes(x='Frequency count', fill=Species))+
  geom_bar(width = 1)+
  coord_polar("y")

# Colours for pie chart
plotthis = plotthis 
+ scale_fill_brewer(palette="Blues")
+ theme_minimal()

# Boxplot with colour 
# Alpha means translucency
boxplot = ggplot(iris, aes(Species, Sepal.Width, fill = Species)) +
  geom_boxplot(alpha = 0.6)



# ----------------------------------------------------------------------------- #
###### R NATIVE PLOTS

# Scatterplot, NO colours
plot(iris$Petal.Length, main="Petal Length Data", 
        xlab="", ylab="Length (cm)", 
        pch=6) # change pch to change shape of dot

# Best fit line for Scatterplot
lines(lowess(iris$Petal.Length), col="blue") 


# Scatterplot, WITH colours, WITH legend
plot(iris$Sepal.Length, main="Sepal Length",
     xlab="Species Cluster", ylab="Length", 
     pch=3,             # shape of dots; e..g, 2=triangle
     col=c("red","blue","green")[iris$Species])
legend(x="bottomright", legend = levels(iris$Species), 
       col=c("red","blue","green"), pch=1)


# Boxplot & Whiskers, WITH colours
boxplot(iris, main="Iris Flowers Dataset",
        col=(c("gold","blue", "pink")),
        xlab="Categories", ylab="Lengths")


# Simple Vertical Barplot with Colors and Legend
data_set <- table(iris$Species)
barplot(data_set, 
        main="Iris Distribution by Frequency",  
        xlab="Species", 
        col=c("pink","green", "yellow"),
        legend = rownames(data_set))


# Stacked Variables VERTICAL Barplot with Colors and Legend
data_set <- table(iris$Species, iris$Sepal.Length)      # all variables here
barplot(data_set,
        main="Sepal Length Distribution",
        xlab="Frequency", ylab = "Length of Sepal",
        col=c("pink","green", "yellow"),
        legend = rownames(data_set))


# Stacked Variables HORIZONTAL Barplot with Colors and Legend
data_set <- table(iris$Species, iris$Sepal.Length)      # all variables here
barplot(data_set, horiz=TRUE, 
        main="Sepal Length Distribution",
        xlab="Frequency", ylab = "Length of Sepal",
        col=c("pink","green", "yellow"),
        legend = rownames(data_set))


# ----------------------------------------------------------------------------- #
###### BONUS / EXTRA

# Count number of species in Table
table(iris$Species)

# Simple Density Plot (ignores categories)
plot(density(iris$Petal.Length), main="Petal Length by Density Plot Distribution")

