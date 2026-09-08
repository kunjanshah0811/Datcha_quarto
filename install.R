# install.R
# Installs all packages required to render the Datcha tutorial (tool_templates.qmd)

packages <- c(
  "dplyr",              # Data manipulation
  "tm",                 # Text mining
  "topicmodels",        # Topic modeling
  "sentimentr",         # Sentiment analysis
  "highcharter",        # Interactive charts
  "tidytext",           # Text processing
  "reshape2",           # Data reshaping
  "ggplot2",            # Visualization
  "DT",                 # Interactive tables
  "stringdist",         # String distance calculation
  "quanteda",           # Quantitative text analysis
  "quanteda.textstats", # Text statistics
  "SnowballC",          # Stemming
  "textstem",           # Lemmatization
  "LDAvis",             # LDA visualization
  "servr",              # Required by LDAvis::serVis
  "diffobj",            # Visual text diffs
  "htmltools",          # HTML output helpers
  "readr",              # CSV import
  "stringi",            # String operations
  "shinyBS"
)

# Install only what is missing
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}

# KeynessMeasures is not on CRAN - install from GitHub
if (!requireNamespace("KeynessMeasures", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
  remotes::install_github("mikegruz/KeynessMeasures")
}
