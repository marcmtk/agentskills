# Test runner for Lab Intelligence Framework
# Run with: Rscript tests/testthat.R
# Or: make test

library(testthat)

# Set working directory to project root
if (file.exists("tests/testthat.R")) {
  # Already in project root
} else if (file.exists("testthat.R")) {
  setwd("..")
}

# Run all tests
test_dir("tests/testthat", reporter = "summary")
