# Master Data Generator for Lab Intelligence Reports
# Generates synthetic data for all dashboard types
# Uses Layer 3 (Synthetic) data per data-sensitivity-framework.md
#
# ==============================================================================
# IMPORTANT: This file is the DEVELOPMENT/DEMO generator.
#
# For production use with real Layer 2 data and synthpop:
#   - Use generate_synthetic_data.R instead
#   - See LAYER2_BRIDGE.md for workflow documentation
#   - See DATA_SPECIFICATION.md for schema documentation
#
# This generator uses parametric methods to create realistic synthetic data
# without requiring any real data input. Suitable for:
#   - Demo environments
#   - Development and testing
#   - Report template development
#
# To use the synthpop-based production generator:
#   export SYNTH_MODE=production
#   export L2_ACTIVITY_VOLUME=/path/to/layer2/data.rds
#   # ... set other L2_* environment variables ...
#   Rscript generate_synthetic_data.R
# ==============================================================================

library(dplyr)
library(tidyr)
library(lubridate)
library(purrr)

set.seed(42)

# =============================================================================
# CONFIGURATION
# =============================================================================

# Date range: 15 months of historical data for year-over-year comparisons
end_date <- as.Date("2025-01-31")
start_date <- end_date - months(15)

# Lab sections (matches LIMS systems)
sections <- c("KBA", "KMA", "KPA")  # Biochemistry, Microbiology, Pathology

# Test categories by section
test_categories <- list(
  KBA = c("Chemistry", "Hematology", "Coagulation", "Urinalysis", "Blood Gas"),
  KMA = c("Culture", "PCR", "Serology", "POCT", "Gram Stain"),
  KPA = c("Surgical Path", "Cytology", "Molecular", "IHC", "Frozen Section")
)

# Individual tests by category
tests_by_category <- list(
  # KBA - Biochemistry
  Chemistry = c("BMP", "CMP", "Lipid Panel", "LFTs", "Thyroid Panel", "HbA1c", "Glucose", "Creatinine"),
  Hematology = c("CBC", "CBC with Diff", "Reticulocyte", "ESR", "Blood Film"),
  Coagulation = c("PT/INR", "PTT", "D-Dimer", "Fibrinogen", "Anti-Xa"),
  Urinalysis = c("UA", "UA with Micro", "Urine Culture Screen", "UCG"),
  `Blood Gas` = c("ABG", "VBG", "Lactate", "Electrolytes POC"),


  # KMA - Microbiology
  Culture = c("Blood Culture", "Urine Culture", "Wound Culture", "Stool Culture", "Sputum Culture"),
  PCR = c("Resp Viral Panel", "COVID-19", "Flu A/B", "GI Panel", "Meningitis Panel"),
  Serology = c("HIV", "Hepatitis Panel", "Syphilis", "CMV", "EBV"),
  POCT = c("Strep A Rapid", "Flu Rapid", "COVID Rapid", "RSV Rapid"),
  `Gram Stain` = c("CSF Gram", "Blood Gram", "Wound Gram", "Sputum Gram"),

  # KPA - Pathology
  `Surgical Path` = c("Biopsy", "Excision", "Resection", "Consultation"),
  Cytology = c("Pap Smear", "FNA", "Body Fluid", "Bronchial Wash"),
  Molecular = c("FISH", "PCR Tissue", "NGS Panel", "MSI Testing"),
  IHC = c("IHC Panel Small", "IHC Panel Large", "Special Stains"),
  `Frozen Section` = c("Frozen Section", "Intraop Consult")
)

# Instruments by section
instruments <- list(
  KBA = c("Cobas 8000", "Cobas 6000", "Sysmex XN", "ACL TOP", "ABL90"),
  KMA = c("VITEK 2", "BacT/ALERT", "FilmArray", "GeneXpert", "MALDI-TOF"),
  KPA = c("Leica ST5010", "Ventana BenchMark", "Illumina MiSeq", "Sakura VIP")
)

# Staff by section (for workload)
staff_per_section <- list(
  KBA = 25,
  KMA = 15,
  KPA = 20
)

cat("=== Lab Intelligence Data Generator ===\n")
cat("Generating data from", as.character(start_date), "to", as.character(end_date), "\n\n")

# =============================================================================
# 1. ACTIVITY VOLUME DATA
# =============================================================================

cat("1. Generating Activity Volume data...\n")

generate_activity_volume <- function() {
  # Generate daily test volumes with realistic patterns
  dates <- seq(start_date, end_date, by = "day")

  volume_data <- expand_grid(
    date = dates,
    section = sections
  ) |>
    rowwise() |>
    mutate(
      # Base volume varies by section
      base_volume = case_when(
        section == "KBA" ~ 800,
        section == "KMA" ~ 300,
        section == "KPA" ~ 150
      ),
      # Day of week effect (lower weekends)
      dow_factor = case_when(
        wday(date) %in% c(1, 7) ~ 0.4,  # Weekend
        wday(date) == 2 ~ 1.15,          # Monday surge
        TRUE ~ 1.0
      ),
      # Seasonal effect (higher in winter for respiratory)
      month_factor = case_when(
        section == "KMA" & month(date) %in% c(1, 2, 12) ~ 1.25,
        section == "KMA" & month(date) %in% c(6, 7, 8) ~ 0.85,
        TRUE ~ 1.0
      ),
      # Year-over-year growth (~3%)
      yoy_factor = 1 + (as.numeric(date - start_date) / 365) * 0.03,
      # Random variation
      random_factor = rnorm(1, 1, 0.08)
    ) |>
    ungroup() |>
    mutate(
      test_count = round(base_volume * dow_factor * month_factor * yoy_factor * pmax(0.7, random_factor)),
      week = floor_date(date, "week"),
      year = year(date),
      month = month(date)
    ) |>
    select(date, week, year, month, section, test_count)

  # Aggregate by week for dashboard
  weekly_volume <- volume_data |>
    group_by(week, year, section) |>
    summarise(
      test_count = sum(test_count),
      days_in_week = n(),
      .groups = "drop"
    )

  # Add category breakdown
  category_volume <- volume_data |>
    crossing(tibble(category_idx = 1:5)) |>
    rowwise() |>
    mutate(
      categories = list(test_categories[[section]]),
      category = categories[[min(category_idx, length(categories))]],
      # Distribute volume across categories
      category_pct = case_when(
        category_idx == 1 ~ 0.35,
        category_idx == 2 ~ 0.25,
        category_idx == 3 ~ 0.20,
        category_idx == 4 ~ 0.12,
        TRUE ~ 0.08
      ),
      category_count = round(test_count * category_pct * rnorm(1, 1, 0.05))
    ) |>
    ungroup() |>
    filter(category_idx <= map_int(section, ~length(test_categories[[.x]]))) |>
    select(date, week, section, category, category_count)

  list(
    daily = volume_data,
    weekly = weekly_volume,
    by_category = category_volume
  )
}

activity_volume <- generate_activity_volume()
saveRDS(activity_volume, "activity-volume/data/activity_volume.rds")
cat("  - Generated", nrow(activity_volume$daily), "daily volume records\n")

# =============================================================================
# 2. QUALITY INDICATOR DATA
# =============================================================================

cat("2. Generating Quality Indicator data...\n")

generate_quality_indicators <- function() {
  months_seq <- seq(floor_date(start_date, "month"),
                    floor_date(end_date, "month"),
                    by = "month")

  # Pre-analytical metrics
  preanalytical <- expand_grid(
    month = months_seq,
    section = sections
  ) |>
    mutate(
      total_specimens = round(runif(n(), 8000, 15000)),
      rejected_specimens = round(total_specimens * rnorm(n(), 0.008, 0.002)),
      hemolyzed_specimens = round(total_specimens * rnorm(n(), 0.015, 0.004)),
      labeling_errors = round(total_specimens * rnorm(n(), 0.0008, 0.0003)),
      missing_samples = round(total_specimens * rnorm(n(), 0.0005, 0.0002)),
      inadequate_volume = round(total_specimens * rnorm(n(), 0.012, 0.003)),
      # Rates
      rejection_rate = rejected_specimens / total_specimens * 100,
      hemolysis_rate = hemolyzed_specimens / total_specimens * 100,
      labeling_error_rate = labeling_errors / total_specimens * 100,
      missing_rate = missing_samples / total_specimens * 100,
      volume_inadequacy_rate = inadequate_volume / total_specimens * 100
    )

  # Analytical metrics
  analytical <- expand_grid(
    month = months_seq,
    section = sections
  ) |>
    mutate(
      total_qc_events = round(runif(n(), 500, 1500)),
      qc_passed = round(total_qc_events * rnorm(n(), 0.97, 0.01)),
      total_results = round(runif(n(), 15000, 40000)),
      auto_validated = round(total_results * rnorm(n(), 0.82, 0.05)),
      reruns = round(total_results * rnorm(n(), 0.02, 0.005)),
      # Rates
      qc_pass_rate = qc_passed / total_qc_events * 100,
      auto_validation_rate = auto_validated / total_results * 100,
      rerun_rate = reruns / total_results * 100
    )

  # Post-analytical metrics
  postanalytical <- expand_grid(
    month = months_seq,
    section = sections
  ) |>
    mutate(
      total_results = round(runif(n(), 15000, 40000)),
      within_tat = round(total_results * rnorm(n(), 0.92, 0.03)),
      total_criticals = round(runif(n(), 50, 200)),
      criticals_notified_in_time = round(total_criticals * rnorm(n(), 0.96, 0.02)),
      amendments = round(total_results * rnorm(n(), 0.003, 0.001)),
      corrections = round(total_results * rnorm(n(), 0.0008, 0.0003)),
      # Rates
      tat_compliance_rate = within_tat / total_results * 100,
      critical_notification_rate = criticals_notified_in_time / total_criticals * 100,
      amendment_rate = amendments / total_results * 100,
      correction_rate = corrections / total_results * 100
    )

  # Combined quality index
  quality_index <- preanalytical |>
    left_join(analytical, by = c("month", "section")) |>
    left_join(postanalytical, by = c("month", "section"), suffix = c("", ".post")) |>
    mutate(
      # Weighted quality index (higher = better)
      quality_index = (
        (1 - rejection_rate/100) * 0.20 +
        (pmin(critical_notification_rate, 100)/100) * 0.25 +
        (pmin(tat_compliance_rate, 100)/100) * 0.25 +
        (1 - amendment_rate/100) * 0.15 +
        (qc_pass_rate/100) * 0.15
      ) * 100
    )

  list(
    preanalytical = preanalytical,
    analytical = analytical,
    postanalytical = postanalytical,
    quality_index = quality_index
  )
}

quality_indicators <- generate_quality_indicators()
saveRDS(quality_indicators, "quality-scorecard/data/quality_indicators.rds")
cat("  - Generated", nrow(quality_indicators$quality_index), "monthly quality records\n")

# =============================================================================
# 3. QC TRENDING DATA
# =============================================================================

cat("3. Generating QC Trending data...\n")

generate_qc_data <- function() {
  # QC runs for key analytes
  analytes <- c(
    "Glucose", "Creatinine", "Sodium", "Potassium", "Hemoglobin",
    "WBC", "Platelets", "PT", "Troponin", "TSH"
  )

  qc_levels <- c("Level 1", "Level 2", "Level 3")

  # Generate daily QC data
  dates <- seq(start_date, end_date, by = "day")

  qc_data <- expand_grid(
    date = dates,
    analyte = analytes,
    level = qc_levels
  ) |>
    mutate(
      # Assign instruments
      instrument = case_when(
        analyte %in% c("Glucose", "Creatinine", "Sodium", "Potassium", "Troponin", "TSH") ~
          sample(c("Cobas 8000", "Cobas 6000"), n(), replace = TRUE),
        analyte %in% c("Hemoglobin", "WBC", "Platelets") ~ "Sysmex XN",
        analyte == "PT" ~ "ACL TOP",
        TRUE ~ "Unknown"
      ),
      # Target values by level
      target = case_when(
        level == "Level 1" ~ 50,
        level == "Level 2" ~ 100,
        level == "Level 3" ~ 200
      ),
      # SD (typically 2-5% of target)
      sd_expected = target * runif(n(), 0.02, 0.05),
      # Generate results with occasional outliers
      result = target + rnorm(n(), 0, sd_expected) *
        ifelse(runif(n()) > 0.97, 2.5, 1),  # 3% chance of larger deviation
      # Calculate z-score
      z_score = (result - target) / sd_expected,
      # Westgard rule violations
      westgard_1_2s = abs(z_score) > 2,
      westgard_1_3s = abs(z_score) > 3,
      # Lot information
      lot_number = paste0("LOT", sprintf("%04d", ((as.numeric(date) - as.numeric(start_date)) %/% 90) + 1)),
      # Pass/fail
      qc_passed = abs(z_score) <= 2
    )

  # Calculate running statistics using slider or simple approach
  # Simple 30-day rolling stats without zoo
  qc_summary <- qc_data |>
    group_by(analyte, level, instrument) |>
    arrange(date) |>
    mutate(
      row_num = row_number(),
      # Use cumulative for simplicity (approximate rolling)
      cumsum_result = cumsum(result),
      cumsum_sq = cumsum(result^2),
      n_obs = row_num,
      mean_cumulative = cumsum_result / n_obs,
      var_cumulative = (cumsum_sq / n_obs) - (mean_cumulative^2),
      sd_cumulative = sqrt(pmax(0, var_cumulative)),
      cv_cumulative = sd_cumulative / mean_cumulative * 100
    ) |>
    ungroup() |>
    select(-row_num, -cumsum_result, -cumsum_sq, -n_obs, -var_cumulative)

  list(
    daily = qc_data,
    summary = qc_summary
  )
}

qc_data <- generate_qc_data()
saveRDS(qc_data, "qc-trending/data/qc_data.rds")
cat("  - Generated", nrow(qc_data$daily), "QC data points\n")

# =============================================================================
# 4. CRITICAL VALUE DATA
# =============================================================================

cat("4. Generating Critical Value data...\n")

generate_critical_values <- function() {
  # Critical value definitions
  critical_tests <- tibble(
    test = c("Potassium", "Glucose", "Hemoglobin", "Platelets", "PT/INR",
             "Troponin", "Lactate", "WBC", "Creatinine", "Blood Culture"),
    low_critical = c(2.5, 40, 6, 20, NA, NA, NA, 1, NA, NA),
    high_critical = c(6.5, 500, 20, 1000, 5, 0.5, 4, 50, 10, NA),
    is_micro = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
  )

  # Generate critical value events
  n_criticals <- 2500  # ~5 per day

  # Convert to POSIXct for proper datetime arithmetic
  start_datetime <- as.POSIXct(start_date)
  end_datetime <- as.POSIXct(end_date)
  date_range_seconds <- as.numeric(difftime(end_datetime, start_datetime, units = "secs"))

  critical_events <- tibble(
    event_id = 1:n_criticals,
    datetime = start_datetime + runif(n_criticals, 0, date_range_seconds),
    test = sample(critical_tests$test, n_criticals, replace = TRUE,
                  prob = c(0.15, 0.1, 0.1, 0.08, 0.08, 0.15, 0.1, 0.08, 0.08, 0.08))
  ) |>
    left_join(critical_tests, by = "test") |>
    mutate(
      # Generate critical result
      is_low = runif(n()) < 0.4 & !is.na(low_critical),
      result = case_when(
        is_micro ~ NA_real_,
        is_low ~ low_critical * runif(n(), 0.7, 0.95),
        TRUE ~ high_critical * runif(n(), 1.05, 1.5)
      ),
      # Notification timing
      result_time = datetime,
      notification_start = result_time + runif(n(), 1, 10) * 60,  # 1-10 min to start calling
      # Most notifications succeed within 30 min
      notification_success = runif(n()) < 0.96,
      notification_time = if_else(
        notification_success,
        notification_start + rexp(n(), 1/8) * 60,  # Mean 8 minutes
        as.POSIXct(NA)
      ),
      time_to_notify = as.numeric(difftime(notification_time, result_time, units = "mins")),
      within_30_min = !is.na(time_to_notify) & time_to_notify <= 30,
      # Provider info
      ordering_provider = paste0("Dr. ", sample(LETTERS, n_criticals, replace = TRUE),
                                  sample(LETTERS, n_criticals, replace = TRUE)),
      ordering_unit = sample(c("ICU", "ED", "Med/Surg", "Oncology", "Cardiology", "OR"),
                            n_criticals, replace = TRUE,
                            prob = c(0.25, 0.25, 0.2, 0.1, 0.1, 0.1)),
      acknowledged_by = if_else(notification_success, ordering_provider, NA_character_),
      # Attempts needed
      attempts_needed = if_else(notification_success,
                                sample(1:4, n_criticals, replace = TRUE, prob = c(0.7, 0.2, 0.08, 0.02)),
                                NA_integer_)
    ) |>
    arrange(datetime)

  # Monthly summary
  critical_summary <- critical_events |>
    mutate(month = floor_date(as.Date(datetime), "month")) |>
    group_by(month) |>
    summarise(
      total_criticals = n(),
      notified_within_30 = sum(within_30_min, na.rm = TRUE),
      failed_notifications = sum(!notification_success),
      mean_notification_time = mean(time_to_notify, na.rm = TRUE),
      p90_notification_time = quantile(time_to_notify, 0.9, na.rm = TRUE),
      compliance_rate = notified_within_30 / total_criticals * 100,
      .groups = "drop"
    )

  list(
    events = critical_events,
    summary = critical_summary
  )
}

critical_values <- generate_critical_values()
saveRDS(critical_values, "critical-values/data/critical_values.rds")
cat("  - Generated", nrow(critical_values$events), "critical value events\n")

# =============================================================================
# 5. INCIDENT/ERROR DATA
# =============================================================================

cat("5. Generating Incident/Error data...\n")

generate_incidents <- function() {
  incident_types <- tibble(
    category = c(rep("Pre-analytical", 5), rep("Analytical", 4), rep("Post-analytical", 4)),
    type = c(
      # Pre-analytical
      "Specimen mislabeled", "Specimen hemolyzed", "Specimen clotted",
      "Wrong tube type", "Insufficient volume",
      # Analytical
      "QC failure", "Instrument malfunction", "Reagent issue", "Result error",
      # Post-analytical
      "Report delay", "Wrong result reported", "Critical value not called", "Report sent to wrong provider"
    ),
    severity = c(
      "High", "Medium", "Medium", "Medium", "Low",
      "Medium", "Medium", "Low", "High",
      "Low", "High", "High", "Medium"
    ),
    frequency_weight = c(
      0.15, 0.20, 0.10, 0.08, 0.12,
      0.08, 0.06, 0.04, 0.03,
      0.06, 0.02, 0.02, 0.04
    )
  )

  n_incidents <- 800  # ~1.5 per day

  # Convert to POSIXct for proper datetime arithmetic
  start_datetime <- as.POSIXct(start_date)
  end_datetime <- as.POSIXct(end_date)
  date_range_seconds <- as.numeric(difftime(end_datetime, start_datetime, units = "secs"))

  incidents <- tibble(
    incident_id = sprintf("INC-%06d", 1:n_incidents),
    datetime = start_datetime + runif(n_incidents, 0, date_range_seconds),
    type_idx = sample(1:nrow(incident_types), n_incidents, replace = TRUE,
                      prob = incident_types$frequency_weight)
  ) |>
    left_join(
      incident_types |> mutate(type_idx = row_number()),
      by = "type_idx"
    ) |>
    mutate(
      section = sample(sections, n_incidents, replace = TRUE, prob = c(0.5, 0.3, 0.2)),
      # Resolution
      resolution_hours = case_when(
        severity == "High" ~ rexp(n(), 1/4) + 1,   # Mean 5 hours
        severity == "Medium" ~ rexp(n(), 1/12) + 2, # Mean 14 hours
        TRUE ~ rexp(n(), 1/24) + 4                  # Mean 28 hours
      ),
      resolved_datetime = datetime + resolution_hours * 3600,
      status = if_else(resolved_datetime <= end_date, "Resolved", "Open"),
      # Root cause
      root_cause = sample(
        c("Human error", "Process gap", "Equipment failure", "Training needed",
          "Communication failure", "System issue"),
        n_incidents, replace = TRUE,
        prob = c(0.35, 0.25, 0.15, 0.10, 0.10, 0.05)
      ),
      # Corrective action
      corrective_action = sample(
        c("Staff counseling", "Process revision", "Equipment repair", "Training provided",
          "Policy update", "System fix", "Under review"),
        n_incidents, replace = TRUE
      ),
      reported_by = paste0("Tech ", sample(LETTERS, n_incidents, replace = TRUE),
                           sprintf("%02d", sample(1:50, n_incidents, replace = TRUE)))
    ) |>
    arrange(datetime) |>
    select(-type_idx)

  # Monthly summary
  incident_summary <- incidents |>
    mutate(month = floor_date(as.Date(datetime), "month")) |>
    group_by(month, category) |>
    summarise(
      incident_count = n(),
      high_severity = sum(severity == "High"),
      mean_resolution_hours = mean(resolution_hours),
      .groups = "drop"
    )

  list(
    events = incidents,
    summary = incident_summary,
    types = incident_types
  )
}

incidents <- generate_incidents()
saveRDS(incidents, "incidents/data/incidents.rds")
cat("  - Generated", nrow(incidents$events), "incident records\n")

# =============================================================================
# 6. COST DATA
# =============================================================================

cat("6. Generating Cost data...\n")

generate_cost_data <- function() {
  # Test-level cost information
  all_tests <- unlist(tests_by_category, use.names = FALSE)

  test_costs <- tibble(
    test = all_tests
  ) |>
    mutate(
      # Assign section
      section = case_when(
        test %in% unlist(tests_by_category[c("Chemistry", "Hematology", "Coagulation",
                                               "Urinalysis", "Blood Gas")]) ~ "KBA",
        test %in% unlist(tests_by_category[c("Culture", "PCR", "Serology",
                                               "POCT", "Gram Stain")]) ~ "KMA",
        TRUE ~ "KPA"
      ),
      # Cost components
      reagent_cost = runif(n(), 2, 50),
      labor_cost = runif(n(), 5, 25),
      overhead_cost = runif(n(), 1, 8),
      total_cost = reagent_cost + labor_cost + overhead_cost,
      # Reimbursement
      reimbursement = total_cost * runif(n(), 1.1, 1.8)
    )

  # Monthly cost by test
  months_seq <- seq(floor_date(start_date, "month"),
                    floor_date(end_date, "month"),
                    by = "month")

  monthly_costs <- expand_grid(
    month = months_seq,
    test = all_tests
  ) |>
    left_join(test_costs, by = "test") |>
    mutate(
      # Volume with variation
      volume = round(runif(n(), 50, 500) *
                      (1 + (as.numeric(month - min(month)) / 365) * 0.03)),  # 3% YoY growth
      # Costs with slight inflation
      inflation_factor = 1 + (as.numeric(month - min(month)) / 365) * 0.02,
      reagent_total = reagent_cost * inflation_factor * volume,
      labor_total = labor_cost * inflation_factor * volume,
      overhead_total = overhead_cost * volume,
      total_expense = reagent_total + labor_total + overhead_total,
      revenue = reimbursement * volume,
      margin = revenue - total_expense,
      cost_per_test = total_expense / volume
    )

  # Section summary
  section_costs <- monthly_costs |>
    group_by(month, section) |>
    summarise(
      total_volume = sum(volume),
      total_expense = sum(total_expense),
      total_revenue = sum(revenue),
      total_margin = sum(margin),
      avg_cost_per_test = total_expense / total_volume,
      .groups = "drop"
    )

  list(
    test_costs = test_costs,
    monthly = monthly_costs,
    section_summary = section_costs
  )
}

cost_data <- generate_cost_data()
saveRDS(cost_data, "cost-analysis/data/cost_data.rds")
cat("  - Generated cost data for", length(unique(cost_data$monthly$test)), "tests\n")

# =============================================================================
# 7. UTILIZATION DATA
# =============================================================================

cat("7. Generating Utilization data...\n")

generate_utilization_data <- function() {
  # Test ordering patterns
  ordering_depts <- c("Internal Medicine", "Emergency", "Surgery", "Oncology",
                      "Cardiology", "Pediatrics", "OB/GYN", "Neurology")

  all_tests <- unlist(tests_by_category, use.names = FALSE)

  months_seq <- seq(floor_date(start_date, "month"),
                    floor_date(end_date, "month"),
                    by = "month")

  # Orders by department
  utilization <- expand_grid(
    month = months_seq,
    ordering_dept = ordering_depts,
    test = sample(all_tests, 20)  # Each dept orders ~20 different tests
  ) |>
    mutate(
      order_count = round(runif(n(), 10, 300)),
      # Duplicate/repeat orders
      duplicate_rate = runif(n(), 0.02, 0.15),
      duplicate_count = round(order_count * duplicate_rate),
      # Appropriateness (simplified)
      guideline_appropriate = runif(n()) > 0.15,  # 85% appropriate
      # Utilization tier
      utilization_tier = case_when(
        order_count > 200 ~ "High",
        order_count > 50 ~ "Medium",
        TRUE ~ "Low"
      )
    )

  # Sendout tracking
  sendout_tests <- c("Specialized Genetics", "Rare Disease Panel", "Reference Cytology",
                     "Esoteric Chemistry", "Specialized Micro")

  sendouts <- expand_grid(
    month = months_seq,
    test = sendout_tests
  ) |>
    mutate(
      volume = round(runif(n(), 5, 50)),
      cost_per_test = runif(n(), 100, 800),
      total_cost = volume * cost_per_test,
      tat_days = round(runif(n(), 3, 14)),
      reference_lab = sample(c("Mayo", "Quest", "ARUP", "LabCorp"), n(), replace = TRUE)
    )

  list(
    orders = utilization,
    sendouts = sendouts
  )
}

utilization_data <- generate_utilization_data()
saveRDS(utilization_data, "utilization/data/utilization_data.rds")
cat("  - Generated", nrow(utilization_data$orders), "utilization records\n")

# =============================================================================
# 8. ANTIBIOGRAM DATA
# =============================================================================

cat("8. Generating Antibiogram data...\n")

generate_antibiogram <- function() {
  organisms <- c(
    "E. coli", "K. pneumoniae", "P. aeruginosa", "S. aureus", "MRSA",
    "E. faecalis", "E. faecium", "Enterobacter spp.", "Proteus spp.",
    "Acinetobacter spp."
  )

  antibiotics <- c(
    "Ampicillin", "Amoxicillin/Clav", "Ceftriaxone", "Ceftazidime", "Cefepime",
    "Meropenem", "Ciprofloxacin", "Levofloxacin", "Gentamicin", "Amikacin",
    "TMP/SMX", "Nitrofurantoin", "Vancomycin", "Linezolid", "Daptomycin"
  )

  # Base susceptibility patterns (realistic patterns)
  base_susceptibility <- expand_grid(
    organism = organisms,
    antibiotic = antibiotics
  ) |>
    mutate(
      # Create realistic susceptibility patterns
      base_rate = case_when(
        # E. coli patterns
        organism == "E. coli" & antibiotic == "Ampicillin" ~ 0.55,
        organism == "E. coli" & antibiotic == "Ceftriaxone" ~ 0.92,
        organism == "E. coli" & antibiotic == "Ciprofloxacin" ~ 0.78,
        organism == "E. coli" & antibiotic == "Meropenem" ~ 0.99,
        organism == "E. coli" & antibiotic == "Nitrofurantoin" ~ 0.95,

        # MRSA patterns
        organism == "MRSA" & antibiotic %in% c("Vancomycin", "Linezolid", "Daptomycin") ~ 0.99,
        organism == "MRSA" & antibiotic %in% c("Ampicillin", "Ceftriaxone", "Cefepime") ~ 0,
        organism == "MRSA" & antibiotic == "TMP/SMX" ~ 0.95,

        # P. aeruginosa patterns
        organism == "P. aeruginosa" & antibiotic %in% c("Ampicillin", "Ceftriaxone") ~ 0,
        organism == "P. aeruginosa" & antibiotic == "Ceftazidime" ~ 0.85,
        organism == "P. aeruginosa" & antibiotic == "Meropenem" ~ 0.88,
        organism == "P. aeruginosa" & antibiotic == "Ciprofloxacin" ~ 0.75,

        # Default patterns
        grepl("Vancomycin|Linezolid|Daptomycin", antibiotic) &
          grepl("coli|pneumoniae|aeruginosa|Enterobacter|Proteus|Acinetobacter", organism) ~ 0,  # Gram neg
        TRUE ~ runif(n(), 0.6, 0.95)
      ),
      # Some combinations are not tested
      not_tested = base_rate == 0 |
        (grepl("S. aureus|MRSA|faecalis|faecium", organism) &
         antibiotic %in% c("Nitrofurantoin", "Ceftazidime"))
    )

  # Generate quarterly data with trends
  quarters <- seq(floor_date(start_date, "quarter"),
                  floor_date(end_date, "quarter"),
                  by = "quarter")

  antibiogram_data <- expand_grid(
    quarter = quarters,
    organism = organisms,
    antibiotic = antibiotics
  ) |>
    left_join(base_susceptibility, by = c("organism", "antibiotic")) |>
    filter(!not_tested) |>
    mutate(
      # Add slight resistance trends (1-2% increase per year for some)
      time_factor = as.numeric(quarter - min(quarter)) / 365,
      resistance_trend = if_else(
        antibiotic %in% c("Ciprofloxacin", "Ceftriaxone", "Ampicillin"),
        -0.02 * time_factor,  # Increasing resistance
        0
      ),
      susceptibility_rate = pmax(0, pmin(1, base_rate + resistance_trend + rnorm(n(), 0, 0.03))),
      # Isolate counts
      isolate_count = round(runif(n(), 10, 150)),
      susceptible_count = round(isolate_count * susceptibility_rate),
      intermediate_count = round(isolate_count * runif(n(), 0, 0.05)),
      resistant_count = isolate_count - susceptible_count - intermediate_count
    ) |>
    select(-base_rate, -not_tested, -time_factor, -resistance_trend)

  list(
    data = antibiogram_data,
    organisms = organisms,
    antibiotics = antibiotics
  )
}

antibiogram <- generate_antibiogram()
saveRDS(antibiogram, "antibiogram/data/antibiogram.rds")
cat("  - Generated antibiogram data for", length(antibiogram$organisms), "organisms\n")

# =============================================================================
# 9. EXECUTIVE SCORECARD DATA
# =============================================================================

cat("9. Generating Executive Scorecard data...\n")

generate_executive_scorecard <- function() {
  months_seq <- seq(floor_date(start_date, "month"),
                    floor_date(end_date, "month"),
                    by = "month")

  scorecard <- tibble(month = months_seq) |>
    mutate(
      # Quality metrics
      quality_index = 85 + cumsum(rnorm(n(), 0.1, 1)),
      quality_index = pmin(100, pmax(70, quality_index)),
      quality_target = 90,
      quality_status = case_when(
        quality_index >= quality_target ~ "Green",
        quality_index >= quality_target - 5 ~ "Yellow",
        TRUE ~ "Red"
      ),

      # TAT compliance
      tat_compliance = 88 + cumsum(rnorm(n(), 0.05, 1.5)),
      tat_compliance = pmin(100, pmax(75, tat_compliance)),
      tat_target = 90,
      tat_status = case_when(
        tat_compliance >= tat_target ~ "Green",
        tat_compliance >= tat_target - 5 ~ "Yellow",
        TRUE ~ "Red"
      ),

      # Critical value notification
      critical_compliance = 94 + cumsum(rnorm(n(), 0.02, 0.8)),
      critical_compliance = pmin(100, pmax(85, critical_compliance)),
      critical_target = 95,
      critical_status = case_when(
        critical_compliance >= critical_target ~ "Green",
        critical_compliance >= critical_target - 3 ~ "Yellow",
        TRUE ~ "Red"
      ),

      # Volume
      test_volume = 25000 + cumsum(rnorm(n(), 50, 500)),
      test_volume = pmax(20000, test_volume),
      volume_yoy_change = c(NA, diff(test_volume) / head(test_volume, -1) * 100),

      # Financial
      cost_per_test = 15 + cumsum(rnorm(n(), 0.02, 0.3)),
      cost_per_test = pmax(12, cost_per_test),
      cost_target = 14,
      cost_status = case_when(
        cost_per_test <= cost_target ~ "Green",
        cost_per_test <= cost_target * 1.1 ~ "Yellow",
        TRUE ~ "Red"
      ),

      # Staff productivity
      tests_per_fte = 180 + cumsum(rnorm(n(), 0.5, 5)),
      tests_per_fte = pmax(150, tests_per_fte),
      productivity_target = 175,
      productivity_status = case_when(
        tests_per_fte >= productivity_target ~ "Green",
        tests_per_fte >= productivity_target * 0.95 ~ "Yellow",
        TRUE ~ "Red"
      ),

      # Overall score
      overall_score = (quality_index * 0.3 + tat_compliance * 0.25 +
                        critical_compliance * 0.2 +
                        (1 - pmin(cost_per_test/20, 1)) * 100 * 0.15 +
                        pmin(tests_per_fte/200, 1) * 100 * 0.10)
    )

  list(
    monthly = scorecard
  )
}

executive_scorecard <- generate_executive_scorecard()
saveRDS(executive_scorecard, "executive-scorecard/data/executive_scorecard.rds")
cat("  - Generated", nrow(executive_scorecard$monthly), "months of executive scorecard data\n")

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n=== Data Generation Complete ===\n")
cat("All data files saved to respective report directories.\n")
cat("\nGenerated datasets:\n")
cat("  1. Activity Volume: daily, weekly, by category\n")
cat("  2. Quality Indicators: pre/analytical/post-analytical metrics\n")
cat("  3. QC Trending: daily QC with Westgard rules\n")
cat("  4. Critical Values: events and notifications\n")
cat("  5. Incidents: errors by category with resolution\n")
cat("  6. Cost Analysis: test-level and section costs\n")
cat("  7. Utilization: orders by department, sendouts\n")
cat("  8. Antibiogram: susceptibility by organism/antibiotic\n")
cat("  9. Executive Scorecard: monthly KPI summary\n")
