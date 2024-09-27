# Use the rocker/tidyverse base image
FROM rocker/tidyverse:latest

# Install ggrepel package in R
RUN R -e "install.packages('ggrepel', 'vroom', repos='https://cloud.r-project.org/')"
