
# install.packages(c("tidyverse", "cluster", "factoextra", "reshape2", "stats"))
library(tidyverse)
library(janitor)
library(cluster)     # For silhouette
library(factoextra)  # For fviz_nbclust and fviz_cluster
library(stats)


coffee <- read.csv("coffee_health.csv",header = T)

# Select features for clustering
clustering_features <- c(
  'coffee_intake', 'bmi', 'sleep_hours', 'heart_rate', 
  'physical_activity_hours', 'age', 'caffeine_mg'
)

# Create the clustering dataset (X_cluster)
X_cluster <- coffee %>% 
  select(all_of(clustering_features))

X_cluster_scaled <- scale(X_cluster)

k_range <- 2:10

# Manual Calculation of Inertia and Silhouette Scores
inertias <- map_dbl(k_range, function(k) {
  kmeans(X_cluster_scaled, centers = k, nstart = 25, iter.max = 30)$tot.withinss
})

silhouette_scores <- map_dbl(k_range, function(k) {
  km_model <- kmeans(X_cluster_scaled, centers = k, nstart = 25, iter.max = 30)
  # Ensure k > 1 for silhouette score calculation
  if (k > 1) {
    # Calculate average silhouette width
    return(silhouette(km_model$cluster, dist(X_cluster_scaled))[, "sil_width"] %>% mean)
  } else {
    return(NA)
  }
})

optimal_k <- 4

# --- 4. Final K-Means Model ---
set.seed(537) # Set seed for reproducibility
kmeans_final <- kmeans(X_cluster_scaled, centers = optimal_k, nstart = 25, iter.max = 30)
coffee$Cluster <- kmeans_final$cluster
final_sil_score <- silhouette(kmeans_final$cluster, dist(X_cluster_scaled))[, "sil_width"] %>% mean


# --- 5. Analyze Clusters ---

cluster_analysis <- coffee %>%
  group_by(Cluster) %>%
  summarise(
    n = n(),
    percentage = n()/nrow(coffee) * 100,
    across(all_of(clustering_features), mean, .names = "mean_{.col}"),
    across(all_of(clustering_features), sd, .names = "std_{.col}"), # Calculate standard deviations
    # Most common characteristics using mode (via table/which.max)
    most_common_country = names(which.max(table(country)))[1],
    most_common_occupation = names(which.max(table(occupation)))[1],
    most_common_sleep_quality = names(which.max(table(sleep_quality)))[1],
    .groups = 'drop'
  )



# --- 6. Advanced Clustering Visualization ---

# PCA  
plot_pca <- fviz_cluster(kmeans_final, data = X_cluster_scaled, 
                         geom = "point", ggtheme = theme_minimal(), 
                         main = "Clusters in PCA Space")

# Elbow Curve Plot 
plot_elbow <- fviz_nbclust(X_cluster_scaled, kmeans, method = "wss", k.max = 10, 
                           nstart = 25, linecolor = "blue") +
  labs(title = "Elbow Method for Optimal k", x = "Number of Clusters", y = "Total Within Sum of Squares") +
  geom_vline(xintercept = optimal_k, linetype = 2, color = "red")

# Silhouette Scores Plot
plot_silhouette <- fviz_nbclust(X_cluster_scaled, kmeans, method = "silhouette", k.max = 10, 
                                nstart = 25, linecolor = "red") +
  labs(title = "Silhouette Score by Number of Clusters") +
  geom_vline(xintercept = optimal_k, linetype = 2, color = "blue")

# Cluster profiles heatmap 
cluster_profile_data <- cluster_analysis %>% 
  select(Cluster, starts_with("mean_")) %>%
  pivot_longer(cols = starts_with("mean_"), names_to = "Feature", values_to = "Mean_Value") %>%
  group_by(Feature) %>%
  mutate(Normalized_Value = Mean_Value / max(Mean_Value)) %>% # Normalize by feature max across all clusters
  ungroup() %>%
  mutate(Feature = gsub("mean_", "", Feature))

plot_heatmap <- ggplot(cluster_profile_data, aes(x = factor(Cluster), y = Feature, fill = Normalized_Value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "#F44336", high = "#2196F3", mid = "#FFFFFF", # Red to Blue heatmap
                       midpoint = 0.5, limit = c(0, 1), 
                       name = "Normalized Mean") +
  geom_text(aes(label = round(Normalized_Value, 2)), color = "black", size = 3) +
  labs(title = "Cluster Profiles (Normalized)", x = "Cluster") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0))

# Scatter Plot (Coffee vs BMI)
plot_scatter <- ggplot(coffee, aes(x = coffee_intake, y = bmi, color = factor(Cluster))) +
  geom_point(alpha = 0.6, size = 3) +
  labs(title = "Coffee vs BMI by Cluster", 
       x = "Coffee Intake (cups/day)", 
       y = "BMI",
       color = "Cluster") +
  theme_minimal()

# Save plots
ggsave("pca_cluster_visualization.png", plot_pca, width = 8, height = 6)
ggsave("elbow_method_plot.png", plot_elbow, width = 6, height = 5)
ggsave("silhouette_plot.png", plot_silhouette, width = 6, height = 5)
ggsave("cluster_profile_heatmap.png", plot_heatmap, width = 8, height = 6)
ggsave("coffee_bmi_scatter.png", plot_scatter, width = 7, height = 6)