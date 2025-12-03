FROM rocker/tidyverse:latest

WORKDIR /app
COPY . /app

RUN apt-get update -qq && apt-get install -y \
  pandoc \
  libcurl4-gnutls-dev \
  libcairo2-dev \
  libxtst6 \
  libxml2-dev \
  libssl-dev \
  libhdf5-dev \
  && rm -rf /var/lib/apt/lists/*

# Install all R packages
RUN Rscript -e "install.packages(c('rmarkdown', 'knitr', 'ggplot2', 'tibble', 'tidyr', 'tidytext', 'cluster', 'janitor', 'factoextra', 'stats', 'reshape2', 'table1'), repos='http://cran.rstudio.com/')"

CMD ["make", "report.html"]