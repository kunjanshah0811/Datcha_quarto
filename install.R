# install.R
# Installs every R package required to render the Datcha tutorial (index.qmd).
#
# Run once with:  Rscript install.R
#
# The script is idempotent (already-installed packages are skipped) and it
# FAILS LOUDLY: if any package is still unavailable at the end it calls stop(),
# so a broken environment is reported here, at build time, instead of halfway
# through the render with "there is no package called '...'".

# Respect a repository that the build image has already pinned (repo2docker sets
# a dated snapshot from runtime.txt). Only fall back to CRAN if nothing is set,
# otherwise we would silently discard that pin and pull mismatched versions.
repos <- getOption("repos")
if (is.null(repos[["CRAN"]]) || repos[["CRAN"]] %in% c("", "@CRAN@")) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
}
message("Using CRAN repository: ", getOption("repos")[["CRAN"]])

packages <- c(
  # Rendering engine: Quarto needs these to execute R chunks in a .qmd
  "knitr",              # Chunk execution
  "rmarkdown",          # Markdown rendering

  # Analysis and output packages used by index.qmd
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
  "tibble",             # Imported by KeynessMeasures
  "LDAvis",             # LDA visualization
  "servr",              # Required by LDAvis::serVis
  "diffobj",            # Visual text diffs
  "htmltools",          # HTML output helpers
  "bslib",              # Bootstrap library for Shiny
  "readr",              # CSV import
  "stringi",            # String operations
  "shinyBS",            # Tooltips
  "remotes"             # Needed to install KeynessMeasures from GitHub
)

# Install only what is missing.
for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing ", pkg, " ...")
    install.packages(pkg)
  }
}

# ---------------------------------------------------------------------------
# KeynessMeasures: GitHub only, not on CRAN.
# Provides frequency_table_creator() and keyness_measure_calculator(), used in
# the keyness analysis section of index.qmd.
#
# Pinned to a specific commit so the tutorial keeps rendering even if the
# upstream repository changes.
# ---------------------------------------------------------------------------
keyness_sha <- "8392488f0ad54851a9508082178525cdc779decf"

if (!requireNamespace("KeynessMeasures", quietly = TRUE)) {
  message("Installing KeynessMeasures from GitHub ...")

  # Attempt 1: remotes. This goes through api.github.com, which is rate limited
  # for unauthenticated callers and is the usual reason automated builds fail.
  try(
    remotes::install_github(
      paste0("amacanovic/KeynessMeasures@", keyness_sha),
      upgrade = "never",
      dependencies = TRUE
    ),
    silent = FALSE
  )

  # Attempt 2: plain source tarball from codeload, which does not touch the
  # GitHub API and so is unaffected by that rate limit. Dependencies are already
  # installed above, so repos = NULL is safe here.
  if (!requireNamespace("KeynessMeasures", quietly = TRUE)) {
    message("GitHub API install failed; retrying via source tarball ...")
    tarball <- sprintf(
      "https://github.com/amacanovic/KeynessMeasures/archive/%s.tar.gz",
      keyness_sha
    )
    dest <- file.path(tempdir(), "KeynessMeasures.tar.gz")
    try({
      utils::download.file(tarball, destfile = dest, mode = "wb", quiet = FALSE)
      install.packages(dest, repos = NULL, type = "source")
    }, silent = FALSE)
  }
}

# ---------------------------------------------------------------------------
# Verification. Everything index.qmd calls library() on must load here.
# ---------------------------------------------------------------------------
required <- c(setdiff(packages, c("remotes", "knitr", "rmarkdown")), "KeynessMeasures")
missing <- required[!vapply(
  required, requireNamespace, logical(1), quietly = TRUE
)]

if (length(missing) > 0) {
  stop(
    "install.R could not install: ", paste(missing, collapse = ", "),
    "\nindex.qmd will not render until these are available.",
    call. = FALSE
  )
}

message("OK: all ", length(required), " required packages are installed.")
message("Library paths in use:")
message(paste(" -", .libPaths(), collapse = "\n"))
