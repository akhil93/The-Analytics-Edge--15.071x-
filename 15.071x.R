#So, lets load the datasets into the R console.

train = read.csv("train.csv")
test = read.csv("test.csv")

#Now have a look at the data using the summary() function.
#Let's remove the UserID variable, because it's not so significant for creating regression models.

train$UserID = NULL

#The YOB variable has missing or NA values. Inorder to perform imputation we need to combine both training and testing dataets.
tr_1= train
tr_1$type = "train"
tr_1$Happy = NULL
te_1 = test
te_1$type="test"
te_1$UserID = NULL
imputed = rbind(tr_1,te_1)

#Using mice package we will perform imputation and fill those mising values.

library(mice)
imputed = complete(mice(imputed))

#Now the data is imputed lets split it back to train and test data sets.

imp_train= subset(imputed, type=="train")
imp_train$Happy = train$Happy
imp_train$type=NULL
imp_test = subset(imputed, type=="test")
imp_test$type=NULL

#Lets create a random forest model and perform predictions on it.
library(randomForest)
rf_model = randomForest(Happy ~., data = imp_train)
rf_pred = predict(rf_model, newdata = imp_test, type = "prob")

# Now that we got our predictions lets input them to a submission file.
submission <- data.frame(UserID = test$UserID, Probability1 = rf_pred[,2])
write.csv(submission, "RF.csv", row.names = FALSE)
