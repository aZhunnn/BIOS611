# BIOS611 Final Project: Global Coffee & Health Analysis

## Project Description

This project analyzes the **Global Coffee Health Dataset** (10,000 synthetic 
records across 20 countries) from kaggle.com to explore the correlations between 
coffee consumption and various health outcomes. Through descriptive statistics, 
correlation modeling, and lifestyle-based clustering, the study identifies 
moderate negative associations between coffee intake and sleep duration and 
quality, and strong links between stress, sleep disruption, and self-reported 
health issues. While clustering highlights distinct lifestyle archetypes — 
including a high-coffee/low-sleep subgroup — the weak silhouette scores indicate 
overlapping patterns across individuals. Overall, the study characterizes 
realistic behavioral relationships among coffee consumption, sleep, and health, 
and provides a foundation for future longitudinal investigations. 



## Building/Running the Container

This entire project is designed to run within a Docker container.

1.  Clone the Repository:
    ```bash
    git clone https://github.com/aZhunnn/BIOS611.git
    cd BIOS611/bios611_final
    ```

2.  Build the Docker Image:
    Navigate into the project directory that contains the Dockerfile and build the container. 
    ```bash
    docker build . -t bios611_final
    ```

3.  Run the Container:
    Run the container, exposing the RStudio port (8787) and mounting the project directory for access:
    ```bash
    docker run -e PASSWORD=password -p 8787:8787 -v $(pwd):/home/rstudio/project bios611_final
    ```
    * *Note: Access RStudio in your browser at `http://localhost:8787` using `rstudio` as the username and `password` as the password.*

## Generating the Report

The final report (`report.html`) is generated using the `Makefile`.

1.  Open the Terminal
2.  Generate the Report:
    ```bash
    make report.html
    ```
    The final report file will appear in the root directory.

## Instructions for Developers

The entire project is organized as a **Makefile** to manage the workflow:
* To run the full analysis and generate the report: `report.html`
* To clean all generated files and artifacts: `make clean`
* Intermediate tasks are handled by dependent targets in the `Makefile`

## Data Acquisition

The **Global Coffee Health Dataset** must be downloaded manually from its 
source and placed in the project structure for the container to access it.

1.  **Source:** [Kaggle: Global Coffee Health Dataset]
(https://www.kaggle.com/datasets/uom190346a/global-coffee-health-dataset/data)
2.  **Required File:** `coffee_health.csv`
3.  **Location:** Create a directory named `data` in the project root and 
place the CSV file inside it: `./data/coffee_health.csv`
