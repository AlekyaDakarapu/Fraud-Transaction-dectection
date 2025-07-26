# Fraud Detection Project Summary

This project showcases an end-to-end fraud detection pipeline using a Random Forest classifier and SMOTE to handle class imbalance. A synthetic dataset of 1,000 transactions is created, incorporating realistic fraud patterns based on transaction amount and time. The data is split into training and testing sets, with SMOTE applied to oversample the minority (fraud) class. 

A Random Forest model is trained and optimized using cross-validation, and performance is evaluated using confusion matrix metrics and ROC-AUC. Feature importance is analyzed, and top-risk transactions are exported for targeted business investigation. The solution is designed for deployment with integration into live systems, automated retraining, and continuous monitoring.

## **Algorithms and Techniques Used**

1. **SMOTE (Synthetic Minority Oversampling Technique)**

   * Balances the imbalanced fraud dataset.
   * Generates synthetic examples for the minority class.

2. **Random Forest Classifier**

   * Ensemble method combining multiple decision trees.
   * Reduces variance and improves prediction accuracy.
   * Provides feature importance for business interpretability.

3. **Grid Search Cross-Validation**

   * Hyperparameter tuning to optimise `mtry` for Random Forest.
   * Uses 5-fold cross-validation for robust performance estimation.

4. **Evaluation Metrics**

   * Confusion Matrix: Precision, Recall, F1-score.
   * ROC Curve and AUC for model discrimination capability.

5. **Probability Threshold Analysis**

   * Extracts transactions with the highest fraud probability.
   * Generates business-ready risk ranking reports.

---

