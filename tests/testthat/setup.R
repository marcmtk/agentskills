# Test setup for Lab Intelligence Framework
# This file is automatically sourced before tests run

library(testthat)
library(dplyr)
library(tidyr)
library(lubridate)
library(purrr)

# Set seed for reproducibility in tests
set.seed(42)

# Helper to get project root
get_project_root <- function() {
  # Try multiple possible locations
  candidates <- c(
    ".",
    "..",
    "../..",
    Sys.getenv("PROJECT_ROOT", unset = NA)
  )

for (path in candidates) {
    if (!is.na(path) && file.exists(file.path(path, "reports", "generate_all_data.R"))) {
      return(normalizePath(path))
    }
  }

  stop("Could not find project root. Set PROJECT_ROOT environment variable.")
}

PROJECT_ROOT <- get_project_root()

# Helper to source generator functions without executing main code
source_generators <- function() {
  # We'll source just the function definitions, not the execution
  # This is a simplified approach - in production you'd refactor to a package

  generator_path <- file.path(PROJECT_ROOT, "reports", "generate_all_data.R")

  if (!file.exists(generator_path)) {
    skip("Generator file not found")
  }

  # Read the file and extract just the function definitions
  # For now, we'll just set up the configuration that generators need

  # Configuration from generate_all_data.R
  end_date <<- as.Date("2025-01-31")
  start_date <<- end_date - months(15)
  sections <<- c("KBA", "KMA", "KPA")

  test_categories <<- list(
    KBA = c("Chemistry", "Hematology", "Coagulation", "Urinalysis", "Blood Gas"),
    KMA = c("Culture", "PCR", "Serology", "POCT", "Gram Stain"),
    KPA = c("Surgical Path", "Cytology", "Molecular", "IHC", "Frozen Section")
  )
}

# Run setup
source_generators()

# Utility functions for tests
expect_valid_date <- function(x) {
  expect_true(inherits(x, "Date") || inherits(x, "POSIXct"),
              info = "Expected Date or POSIXct")
}

expect_non_negative <- function(x) {
  expect_true(all(x >= 0, na.rm = TRUE),
              info = "Expected all values >= 0")
}

expect_in_range <- function(x, min_val, max_val) {
  expect_true(all(x >= min_val & x <= max_val, na.rm = TRUE),
              info = sprintf("Expected values in range [%s, %s]", min_val, max_val))
}

expect_no_na <- function(x) {
  expect_true(!any(is.na(x)),
              info = "Expected no NA values")
}

expect_has_columns <- function(df, cols) {
  missing <- setdiff(cols, names(df))
  expect_true(length(missing) == 0,
              info = paste("Missing columns:", paste(missing, collapse = ", ")))
}
