
library(tidyverse)
library(janitor)
library(cluster)
library(stats)
library(ggplot2)
library(reshape2)

coffee <- read.csv("coffee_health.csv", header = TRUE) %>%
  clean_names()


sleep_map <- c("Poor" = 1, "Fair" = 2, "Good" = 3, "Excellent" = 4)
coffee <- coffee %>%
  mutate(sleep_quality_encoded = recode(sleep_quality, !!!sleep_map))

# Stress_Level (Low=1 to High=3)
stress_map <- c("Low" = 1, "Medium" = 2, "High" = 3)
coffee <- coffee %>%
  mutate(stress_level_encoded = recode(stress_level, !!!stress_map))

# Health_Issues (None=0 to Severe=2)
health_map <- c("None" = 0, "Mild" = 1, "Moderate" = 2,"Severe" = 3)
coffee <- coffee %>%
  mutate(health_issues_encoded = recode(health_issues, !!!health_map))

# Select variables for correlation matrix (excluding ID, Country, Gender, Occupation, and original categories)
cols_to_correlate <- c(
  'age', 'coffee_intake', 'caffeine_mg', 'sleep_hours',
  'sleep_quality_encoded', 'bmi', 'heart_rate', 'stress_level_encoded',
  'physical_activity_hours', 'smoking', 'alcohol_consumption', 'health_issues_encoded'
)

# Calculate correlation matrix
correlation_matrix <- cor(coffee[, cols_to_correlate])

# Melt the correlation matrix for ggplot2
melted_cor <- melt(correlation_matrix)

# Plot the heatmap
plot_cor <- ggplot(data = melted_cor, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white",
                       midpoint = 0, limit = c(-1, 1), space = "Lab",
                       name = "Pearson\nCorrelation") +
  theme_minimal() +
  coord_fixed() +
  geom_text(aes(label = format(value, digits = 2)), size = 2.5) +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(
    title = "Correlation Matrix of Health and Consumption Variables",
    x = "",
    y = ""
  )

# save plot
ggsave("correlation_heatmap_R.png", plot_cor, width = 10, height = 8)