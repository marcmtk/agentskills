# Tests for data validation
# Validates that generated data meets schema requirements

test_that("activity volume data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/activity-volume/data/activity_volume.rds")),
              "Activity volume data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/activity-volume/data/activity_volume.rds"))

  # Should be a list with expected components

  expect_type(data, "list")
  expect_true("daily" %in% names(data))
  expect_true("weekly" %in% names(data))
  expect_true("by_category" %in% names(data))

  # Daily data structure
  daily <- data$daily
  expect_has_columns(daily, c("date", "section", "test_count"))
  expect_non_negative(daily$test_count)
  expect_true(all(daily$section %in% c("KBA", "KMA", "KPA")))

  # Weekly data structure
  weekly <- data$weekly
  expect_has_columns(weekly, c("week", "section", "test_count"))
  expect_non_negative(weekly$test_count)
})

test_that("quality indicators data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/quality-scorecard/data/quality_indicators.rds")),
              "Quality indicators data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/quality-scorecard/data/quality_indicators.rds"))

  expect_type(data, "list")
  expect_true("preanalytical" %in% names(data))
  expect_true("analytical" %in% names(data))
  expect_true("postanalytical" %in% names(data))

  # Preanalytical checks
  pre <- data$preanalytical
  expect_has_columns(pre, c("month", "section", "total_specimens", "rejected_specimens"))
  expect_non_negative(pre$total_specimens)
  expect_non_negative(pre$rejected_specimens)

  # Rejection rate should be < 100%
  expect_true(all(pre$rejection_rate < 100, na.rm = TRUE))
})

test_that("QC data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/qc-trending/data/qc_data.rds")),
              "QC data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/qc-trending/data/qc_data.rds"))

  expect_type(data, "list")
  expect_true("daily" %in% names(data))

  daily <- data$daily
  expect_has_columns(daily, c("date", "analyte", "level", "target", "result", "z_score"))

  # Z-scores should be reasonable (within 5 SD for most)
  expect_true(mean(abs(daily$z_score) < 5) > 0.99,
              info = "Expected >99% of z-scores within 5 SD")
})

test_that("critical values data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/critical-values/data/critical_values.rds")),
              "Critical values data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/critical-values/data/critical_values.rds"))

  expect_type(data, "list")
  expect_true("events" %in% names(data))
  expect_true("summary" %in% names(data))

  events <- data$events
  expect_has_columns(events, c("event_id", "datetime", "test", "notification_success"))

  # Notification success rate should be reasonable (>90%)
  success_rate <- mean(events$notification_success, na.rm = TRUE)
  expect_true(success_rate > 0.90,
              info = sprintf("Expected success rate > 90%%, got %.1f%%", success_rate * 100))
})

test_that("incidents data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/incidents/data/incidents.rds")),
              "Incidents data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/incidents/data/incidents.rds"))

  expect_type(data, "list")
  expect_true("events" %in% names(data))

  events <- data$events
  expect_has_columns(events, c("incident_id", "datetime", "category", "type", "severity"))

  # Categories should be valid
  valid_categories <- c("Pre-analytical", "Analytical", "Post-analytical")
  expect_true(all(events$category %in% valid_categories))

  # Severities should be valid
  valid_severities <- c("High", "Medium", "Low")
  expect_true(all(events$severity %in% valid_severities))
})

test_that("cost data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/cost-analysis/data/cost_data.rds")),
              "Cost data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/cost-analysis/data/cost_data.rds"))

  expect_type(data, "list")
  expect_true("test_costs" %in% names(data))
  expect_true("monthly" %in% names(data))

  # Costs should be positive
  test_costs <- data$test_costs
  expect_non_negative(test_costs$reagent_cost)
  expect_non_negative(test_costs$labor_cost)
  expect_non_negative(test_costs$total_cost)

  # Total should equal sum of components
  expected_total <- test_costs$reagent_cost + test_costs$labor_cost + test_costs$overhead_cost
  expect_equal(test_costs$total_cost, expected_total, tolerance = 0.01)
})

test_that("utilization data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/utilization/data/utilization_data.rds")),
              "Utilization data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/utilization/data/utilization_data.rds"))

  expect_type(data, "list")
  expect_true("orders" %in% names(data))
  expect_true("sendouts" %in% names(data))

  orders <- data$orders
  expect_has_columns(orders, c("month", "ordering_dept", "test", "order_count"))
  expect_non_negative(orders$order_count)
})

test_that("antibiogram data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/antibiogram/data/antibiogram.rds")),
              "Antibiogram data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/antibiogram/data/antibiogram.rds"))

  expect_type(data, "list")
  expect_true("data" %in% names(data))

  abx <- data$data
  expect_has_columns(abx, c("quarter", "organism", "antibiotic", "susceptibility_rate"))

  # Susceptibility rate should be 0-1
  expect_in_range(abx$susceptibility_rate, 0, 1)
})

test_that("executive scorecard data has correct structure", {
  skip_if_not(file.exists(file.path(PROJECT_ROOT, "reports/executive-scorecard/data/executive_scorecard.rds")),
              "Executive scorecard data not generated")

  data <- readRDS(file.path(PROJECT_ROOT, "reports/executive-scorecard/data/executive_scorecard.rds"))

  expect_type(data, "list")
  expect_true("monthly" %in% names(data))

  monthly <- data$monthly
  expect_has_columns(monthly, c("month", "quality_index", "tat_compliance", "overall_score"))

  # Scores should be reasonable percentages
  expect_in_range(monthly$quality_index, 0, 100)
  expect_in_range(monthly$tat_compliance, 0, 100)
})
