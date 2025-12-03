# clustering_analysis.R

library(tidyverse)
library(janitor)
library(cluster)
library(ggplot2)
library(stats)
# library(factoextra)

# --- 1. Load Data ---
load("clustering_prep.RData")

# --- 2. Final K-Means Model ---
set.seed(537) 

kmeans_final <- suppressWarnings(
  kmeans(X_cluster_scaled, centers = optimal_k, nstart = 25, iter.max = 30)
)
coffee$Cluster <- kmeans_final$cluster
final_sil_score <- silhouette(kmeans_final$cluster, dist(X_cluster_scaled))[, "sil_width"] %>% mean

# --- 3. Analyze Clusters ---

cluster_analysis <- coffee %>%
  group_by(Cluster) %>%
  summarise(
    n = n(),
    percentage = n()/nrow(coffee) * 100,
    across(all_of(clustering_features), mean, .names = "mean_{.col}"),
    across(all_of(clustering_features), sd, .names = "std_{.col}"), 
    most_common_country = names(which.max(table(country)))[1],
    most_common_occupation = names(which.max(table(occupation)))[1],
    most_common_sleep_quality = names(which.max(table(sleep_quality)))[1],
    .groups = 'drop'
  )

# --- 4. Advanced Clustering Visualization
## 4.1. PCA Visualization 
# Perform PCA on the scaled data
pca_result <- prcomp(X_cluster_scaled, center = FALSE, scale. = FALSE) 
pca_data <- as.data.frame(pca_result$x) %>%
  select(PC1, PC2) %>%
  mutate(Cluster = factor(kmeans_final$cluster))

variance_explained <- (pca_result$sdev^2) / sum(pca_result$sdev^2)
pc1_var <- round(variance_explained[1] * 100, 1)
pc2_var <- round(variance_explained[2] * 100, 1)

plot_pca <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters in PCA Space (PC1 vs PC2)",
    x = paste0("PC1 (", pc1_var, "%)"),
    y = paste0("PC2 (", pc2_var, "%)"),
    color = "Cluster"
  ) +
  theme_minimal()

## 4.2. Elbow Curve Plot 
elbow_data <- data.frame(k = 1:length(inertias), wss = inertias)

plot_elbow <- ggplot(elbow_data, aes(x = k, y = wss)) +
  geom_line(color = "blue") +
  geom_point(color = "blue", size = 2) +
  labs(
    title = "Elbow Method for Optimal k",
    x = "Number of Clusters (k)",
    y = "Total Within Sum of Squares (WSS)"
  ) +
  geom_vline(xintercept = optimal_k, linetype = 2, color = "red") +
  scale_x_continuous(breaks = elbow_data$k) + # Ensure k is treated as discrete steps
  theme_minimal()

## 4.3. Silhouette Scores Plot 
silhouette_data <- data.frame(k = 2:(length(silhouette_scores) + 1), avg_sil_width = silhouette_scores)

plot_silhouette <- ggplot(silhouette_data, aes(x = k, y = avg_sil_width)) +
  geom_line(color = "red") +
  geom_point(color = "red", size = 2) +
  labs(
    title = "Silhouette Score by Number of Clusters",
    x = "Number of Clusters (k)",
    y = "Average Silhouette Width"
  ) +
  geom_vline(xintercept = optimal_k, linetype = 2, color = "blue") +
  scale_x_continuous(breaks = silhouette_data$k) +
  theme_minimal()

## 4.4. Cluster profiles heatmap 
cluster_profile_data <- cluster_analysis %>% 
  select(Cluster, starts_with("mean_")) %>%
  pivot_longer(cols = starts_with("mean_"), names_to = "Feature", values_to = "Mean_Value") %>%
  group_by(Feature) %>%
  mutate(Normalized_Value = Mean_Value / max(Mean_Value)) %>% 
  ungroup() %>%
  mutate(Feature = gsub("mean_", "", Feature))

plot_heatmap <- ggplot(cluster_profile_data, aes(x = factor(Cluster), y = Feature, fill = Normalized_Value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "#F44336", high = "#2196F3", mid = "#FFFFFF", 
                       midpoint = 0.5, limit = c(0, 1), name = "Normalized Mean") +
  geom_text(aes(label = round(Normalized_Value, 2)), color = "black", size = 3) +
  labs(title = "Cluster Profiles (Normalized)", x = "Cluster") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0))

## 4.5. Scatter Plot (Coffee vs BMI) 
plot_scatter <- ggplot(coffee, aes(x = coffee_intake, y = bmi, color = factor(Cluster))) +
  geom_point(alpha = 0.6, size = 3) +
  labs(title = "Coffee vs BMI by Cluster", 
       x = "Coffee Intake (cups/day)", 
       y = "BMI",
       color = "Cluster") +
  theme_minimal()

# --- 5. Save plots ---
ggsave("pca_cluster_visualization.png", plot_pca, width = 8, height = 6)
ggsave("elbow_method_plot.png", plot_elbow, width = 6, height = 5)
ggsave("silhouette_plot.png", plot_silhouette, width = 6, height = 5)
ggsave("cluster_profile_heatmap.png", plot_heatmap, width = 8, height = 6)
ggsave("coffee_bmi_scatter.png", plot_scatter, width = 7, height = 6)