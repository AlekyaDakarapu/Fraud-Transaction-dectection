# Install required packages
install.packages(c("tidyverse", "caTools", "caret", "smotefamily", "randomForest"))

library(tidyverse)
library(caTools)
library(caret)
library(smotefamily)
library(randomForest)


set.seed(123)

n <- 1000
amount <- round(runif(n, 1, 10000), 2)
location <- sample(1:10, n, replace = TRUE)
time <- sample(0:23, n, replace = TRUE)
is_fraud <- ifelse(amount > 8000 & (time < 6 | time > 22), 1, 0)
is_fraud <- ifelse(runif(n) < 0.05, 1, is_fraud)

transactions <- data.frame(amount, location, time, is_fraud = as.factor(is_fraud))




set.seed(42)
split <- sample.split(transactions$is_fraud, SplitRatio = 0.7)
train_data <- subset(transactions, split == TRUE)
test_data <- subset(transactions, split == FALSE)





# smotefamily requires target to be numeric (0/1), not factor
train_data_smote <- train_data
train_data_smote$is_fraud <- as.numeric(as.character(train_data_smote$is_fraud))

# Apply SMOTE
smote_output <- SMOTE(X = train_data_smote[, c("amount", "location", "time")],
                      target = train_data_smote$is_fraud,
                      K = 5)

# Combine result into one dataframe
train_data_balanced <- smote_output$data
train_data_balanced$class <- as.factor(train_data_balanced$class)
colnames(train_data_balanced)[4] <- "is_fraud"




set.seed(42)
rf_model <- randomForest(is_fraud ~ ., data = train_data_balanced, ntree = 100)



rf_predictions <- predict(rf_model, newdata = test_data)
conf_matrix <- confusionMatrix(rf_predictions, test_data$is_fraud, positive = "1")
print(conf_matrix)




tuned_model <- train(
  is_fraud ~ ., data = train_data_balanced,
  method = "rf",
  trControl = trainControl(method = "cv", number = 5),
  tuneLength = 5
)



varImpPlot(rf_model)




library(pROC)
probs <- predict(rf_model, test_data, type = "prob")[, 2]
roc_obj <- roc(test_data$is_fraud, probs)
plot(roc_obj, main = "ROC Curve")
auc(roc_obj)






# Load caret and randomForest if not already
library(caret)
library(randomForest)

# Set up cross-validation
set.seed(101)
control <- trainControl(method = "cv", number = 5, search = "grid")

# Define tuning grid
tunegrid <- expand.grid(.mtry = c(1, 2, 3))

# Train model
rf_tuned <- train(
  is_fraud ~ ., 
  data = train_data_balanced,
  method = "rf",
  metric = "Accuracy",
  trControl = control,
  tuneGrid = tunegrid
)

# Print results
print(rf_tuned)
plot(rf_tuned)





# Show variable importance from best model
varImpPlot(rf_tuned$finalModel)





library(pROC)

# Predict probabilities on test set
rf_probs <- predict(rf_tuned, test_data, type = "prob")[,2]

# Plot ROC
roc_obj <- roc(test_data$is_fraud, rf_probs)
plot(roc_obj, main = "ROC Curve", col = "blue")
auc(roc_obj)  # Show AUC score





# Generate predictions (class + probability)
rf_preds <- predict(rf_tuned, test_data)
rf_probs <- predict(rf_tuned, test_data, type = "prob")[,2]

# Combine and export
output <- test_data
output$predicted_class <- rf_preds
output$fraud_probability <- rf_probs

# Export to CSV
write.csv(output, "fraud_predictions.csv", row.names = FALSE)





# Load your predictions CSV
data <- read.csv("fraud_predictions.csv")

# Preview
head(data)
str(data)



# Convert to factor if needed
data$is_fraud <- as.factor(data$is_fraud)
data$predicted_class <- as.factor(data$predicted_class)

# Confusion matrix
library(caret)
confusionMatrix(data$predicted_class, data$is_fraud, positive = "1")






library(ggplot2)

ggplot(data, aes(x = fraud_probability, fill = predicted_class)) +
  geom_histogram(binwidth = 0.05, position = "dodge", color = "black") +
  labs(title = "Fraud Probability Distribution",
       x = "Predicted Probability of Fraud", y = "Count") +
  scale_fill_manual(values = c("0" = "green", "1" = "red"),
                    name = "Predicted Class") +
  theme_minimal()





confusionMatrix(data$predicted_class, data$is_fraud, positive = "1")




ggplot(data, aes(x = fraud_probability, fill = predicted_class)) +
  geom_histogram(binwidth = 0.05, position = "dodge", color = "black") +
  labs(title = "Fraud Probability Distribution",
       x = "Predicted Probability of Fraud", y = "Count") +
  scale_fill_manual(values = c("0" = "green", "1" = "red"),
                    name = "Predicted Class") +
  theme_minimal()


head(data[order(-data$fraud_probability), ],10)


# Top 10 transactions with highest fraud probability
top_risks <- data %>%
  arrange(desc(fraud_probability)) %>%
  head(10)

print(top_risks)


write.csv(top_risks, "top_risky_transactions.csv", row.names = FALSE)

     
     