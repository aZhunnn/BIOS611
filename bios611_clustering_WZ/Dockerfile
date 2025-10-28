FROM rocker/tidyverse:latest

WORKDIR /app
COPY . /app

# Install all R packages
RUN Rscript -e "install.packages(c('rmarkdown', 'knitr', 'ggplot2', 'tibble', 'tidyr', 'cluster', 'plotly', 'tidyverse'), repos='http://cran.rstudio.com/')"
    
RUN apt-get update -qq && apt-get install -y \
    pandoc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxtst6 \
    && rm -rf /var/lib/apt/lists/*

CMD ["Rscript", "analysis.R"]