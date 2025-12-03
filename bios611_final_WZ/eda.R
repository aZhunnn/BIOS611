
library(tidyverse)
library(janitor)
library(ggplot2)
library(stats)

coffee <- read.csv("coffee_health.csv", header = TRUE) %>%
  clean_names()

plot1 <- coffee %>%
  ggplot(aes(x = coffee_intake)) +
  geom_histogram(binwidth = 0.5, fill = "skyblue", color = "black") +
  labs(
    title = "Distribution of Daily Coffee Intake (Cups)",
    x = "Coffee Intake (Cups)",
    y = "Frequency"
  ) +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, max(coffee$coffee_intake), by = 1))

# EDA 2: Caffeine vs. Sleep Hours
plot2 <- coffee %>%
  ggplot(aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.3, color = "darkgreen") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Caffeine Intake vs. Sleep Duration",
    x = "Caffeine Intake (mg)",
    y = "Sleep Duration (Hours)"
  ) +
  theme_minimal()


# EDA 3: Sleep Quality across Stress Levels
plot3 <- coffee %>%
  mutate(sleep_quality = factor(sleep_quality, levels = c("Poor", "Fair", "Good", "Excellent"))) %>%
  ggplot(aes(x = stress_level, fill = sleep_quality)) +
  geom_bar(position = "fill") +
  labs(
    title = "Proportion of Sleep Quality by Stress Level",
    x = "Stress Level",
    y = "Proportion",
    fill = "Sleep Quality"
  ) +
  theme_minimal()

# Save plots
ggsave("coffee_intake_distribution.png", plot1, width = 6, height = 4)
ggsave("caffeine_vs_sleep.png", plot2, width = 6, height = 4)
ggsave("sleep_quality_by_stress.png", plot3, width = 6, height = 4)
