# install.R
# Installs all packages required to render the Datcha tutorial (index.qmd)

# CRAN packages
install.packages(c(
  "dplyr", "tm", "topicmodels", "sentimentr", "highcharter",
  "tidytext", "reshape2", "ggplot2", "DT", "stringdist",
  "shinyBS", "quanteda", "quanteda.textstats", "SnowballC",
  "textstem", "LDAvis", "diffobj", "htmltools", "bslib",
  "readr", "stringi", "remotes"
), repos = "https://cloud.r-project.org")

# GitHub-only package (not on CRAN)
remotes::install_github("amacanovic/KeynessMeasures")
