# analysis.R

# Load the necessary library

library(rmarkdown)
library(ggplot2)
library(dplyr)
library(tibble)
library(tidyr)
library(tidyverse)
library(cluster)
library(plotly)


# Render the R Markdown file
rmarkdown::render("bios611_cluster_WZ.Rmd", output_file = "bios611_cluster_WZ.html")
