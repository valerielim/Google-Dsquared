setwd("D:/NC/PA1")

# import data
OmniPower <- read.csv("Omnipower.csv")
attach(OmniPower)

# Print correlation table
cor(OmniPower)

# Stacked linear regression model
# Y = Sales, X1 = Price, X2 = Promotion
OmniPowerFit <- lm(Sales ~ Price + Promotion)

# Model fit and significance
summary(OmniPowerFit)

# Observed sales value
Sales

# Predicted sales value 
fitted(OmniPowerFit)

# Residuals
residuals(OmniPowerFit)

# Residual analysis
par(mfrow=c(2,2))  # 4 Charts in a Plot.
plot(OmniPowerFit)


### What are the predicted sales for a store charging 
### 79c during a mont in which promotional expenditures 
### are $400? (Use mutiple regression equation to 
### predict values of the dependent variable)

# Store new values into a dataframe
newdata <- data.frame(Price = 79, Promotion = 400)

# make prediction 
predict(OmniPowerFit, newdata)

# Include confidence intervals
predict.lm(OmniPowerFit, newdata, interval="predict")

# Package for CAR
install.packages("car")
library(car)

# VIF = variance inflation factor
# VIF measures multicollinearity 
# VIF < 10 = acceptable
# VIF more than 10 = 90% multi = cutoff point.
vif(OmniPowerFit)