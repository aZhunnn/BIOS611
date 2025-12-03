
library(tidyverse)
library(janitor)
library(cluster)
library(stats)
library(ggplot2)

# --- 1. Data Loading and Scaling ---
coffee <- read.csv("coffee_health.csv", header = TRUE) %>%
  clean_names()

# Select features for clustering
clustering_features <- c(
  'coffee_intake', 'bmi', 'sleep_hours', 'heart_rate', 
  'physical_activity_hours', 'age', 'caffeine_mg'
)

# Create the clustering dataset (X_cluster)
X_cluster <- coffee %>% 
  select(all_of(clustering_features))

# Standardize features (mean=0, sd=1)
X_cluster_scaled <- scale(X_cluster)

# --- 2. Determine Optimal Number of Clusters (k) ---

k_range <- 2:10

inertias <- suppressWarnings(
  map_dbl(k_range, function(k) {
    kmeans(X_cluster_scaled, centers = k, nstart = 25, iter.max = 30)$tot.withinss
  })
)

silhouette_scores <- suppressWarnings(
  map_dbl(k_range, function(k) {
    km_model <- kmeans(X_cluster_scaled, centers = k, nstart = 25, iter.max = 30)
    # Calculate average silhouette width
    if (k > 1) {
      return(silhouette(km_model$cluster, dist(X_cluster_scaled))[, "sil_width"] %>% mean)
    } else {
      return(NA)
    }
  })
)

# Set the optimal k 
optimal_k <- 4

# Save critical objects for the next script
save(
  coffee, 
  X_cluster_scaled, 
  clustering_features, 
  optimal_k, 
  inertias, 
  silhouette_scores,
  file = "clustering_prep.RData"
)