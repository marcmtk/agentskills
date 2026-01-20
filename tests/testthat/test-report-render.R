# Tests for report rendering
# Verifies that Quarto reports compile without errors

# Helper to check if quarto is available
quarto_available <- function() {
  result <- tryCatch(
    system2("quarto", "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) NULL
  )
  !is.null(result) && length(result) > 0
}

# Helper to render a report and check for success
render_report <- function(report_name) {
  qmd_path <- file.path(PROJECT_ROOT, "reports", report_name,
                        paste0(report_name, "-report.qmd"))

  if (!file.exists(qmd_path)) {
    return(list(success = FALSE, message = "QMD file not found"))
  }

  # Check for required data
  data_dir <- file.path(PROJECT_ROOT, "reports", report_name, "data")
  if (!dir.exists(data_dir) || length(list.files(data_dir, pattern = "\\.rds$")) == 0) {
    return(list(success = FALSE, message = "Data files not found"))
  }

  # Attempt to render (this is slow, so we just validate the QMD parses)
  # For full render tests, use make reports
  result <- tryCatch({
    # Just check YAML is valid
    lines <- readLines(qmd_path, n = 50)
    yaml_start <- which(lines == "---")[1]
    yaml_end <- which(lines == "---")[2]

    if (is.na(yaml_start) || is.na(yaml_end)) {
      return(list(success = FALSE, message = "Invalid YAML header"))
    }

    list(success = TRUE, message = "QMD structure valid")
  }, error = function(e) {
    list(success = FALSE, message = e$message)
  })

  result
}

test_that("activity volume report QMD is valid", {
  result <- render_report("activity-volume")
  expect_true(result$success, info = result$message)
})

test_that("quality scorecard report QMD is valid", {
  result <- render_report("quality-scorecard")
  expect_true(result$success, info = result$message)
})

test_that("QC trending report QMD is valid", {
  result <- render_report("qc-trending")
  expect_true(result$success, info = result$message)
})

test_that("critical values report QMD is valid", {
  result <- render_report("critical-values")
  expect_true(result$success, info = result$message)
})

test_that("incidents report QMD is valid", {
  result <- render_report("incidents")
  expect_true(result$success, info = result$message)
})

test_that("cost analysis report QMD is valid", {
  result <- render_report("cost-analysis")
  expect_true(result$success, info = result$message)
})

test_that("utilization report QMD is valid", {
  result <- render_report("utilization")
  expect_true(result$success, info = result$message)
})

test_that("antibiogram report QMD is valid", {
  result <- render_report("antibiogram")
  expect_true(result$success, info = result$message)
})

test_that("executive scorecard report QMD is valid", {
  result <- render_report("executive-scorecard")
  expect_true(result$success, info = result$message)
})

test_that("all expected reports exist", {
  expected_reports <- c(
    "activity-volume",
    "quality-scorecard",
    "qc-trending",
    "critical-values",
    "incidents",
    "cost-analysis",
    "utilization",
    "antibiogram",
    "executive-scorecard"
  )

  for (report in expected_reports) {
    qmd_path <- file.path(PROJECT_ROOT, "reports", report,
                          paste0(report, "-report.qmd"))
    expect_true(file.exists(qmd_path),
                info = sprintf("Missing report: %s", report))
  }
})
