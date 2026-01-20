# ==============================================================================
# SYNTHETIC DATA GENERATION FOR LAB INTELLIGENCE
# Layer 2 → Layer 3 Bridge Implementation
# ==============================================================================
#
# PURPOSE:
# This script generates synthetic data (Layer 3) from analytics data (Layer 2).
# It uses synthpop for statistical preservation when real data is available,
# or parametric generation for development/demo purposes.
#
# USAGE MODES:
# 1. DEVELOPMENT MODE: Uses parametric generation (no real data needed)
# 2. PRODUCTION MODE: Uses synthpop on Layer 2 extracts
#
# For human data scientists: This script serves as a reference for building
# the actual Layer 2 → Layer 3 pipeline. See DATA_SPECIFICATION.md for schemas.
#
# ==============================================================================

library(dplyr)
library(tidyr)
library(lubridate)
library(purrr)

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Set mode: "development" (parametric) or "production" (synthpop)
GENERATION_MODE <- Sys.getenv("SYNTH_MODE", unset = "development")

# Layer 2 data paths (only used in production mode)
LAYER2_PATHS <- list(
  activity_volume = Sys.getenv("L2_ACTIVITY_VOLUME", unset = NA),
  quality_indicators = Sys.getenv("L2_QUALITY", unset = NA),
  qc_data = Sys.getenv("L2_QC", unset = NA),
  critical_values = Sys.getenv("L2_CRITICAL", unset = NA),
  incidents = Sys.getenv("L2_INCIDENTS", unset = NA),
  cost_data = Sys.getenv("L2_COSTS", unset = NA),
  utilization = Sys.getenv("L2_UTILIZATION", unset = NA),
  antibiogram = Sys.getenv("L2_ANTIBIOGRAM", unset = NA)
)

# Output directory
OUTPUT_DIR <- Sys.getenv("SYNTH_OUTPUT", unset = ".")

# Date range for synthetic data
END_DATE <- as.Date(Sys.getenv("SYNTH_END_DATE", unset = as.character(Sys.Date())))
START_DATE <- END_DATE - months(15)  # 15 months for YoY comparisons

# Random seed for reproducibility
set.seed(as.integer(Sys.getenv("SYNTH_SEED", unset = "42")))

cat("========================================\n")
cat("Synthetic Data Generator\n")
cat("========================================\n")
cat("Mode:", GENERATION_MODE, "\n")
cat("Date range:", as.character(START_DATE), "to", as.character(END_DATE), "\n")
cat("Output directory:", OUTPUT_DIR, "\n\n")

# ==============================================================================
# REFERENCE DATA
# Defined per DATA_SPECIFICATION.md
# Human data scientists: Update these if your institution uses different values
# ==============================================================================

# Lab sections
SECTIONS <- c("KBA", "KMA", "KPA")

# Test categories by section
CATEGORIES <- list(
  KBA = c("Chemistry", "Hematology", "Coagulation", "Urinalysis", "Blood Gas"),
  KMA = c("Culture", "PCR", "Serology", "POCT", "Gram Stain"),
  KPA = c("Surgical Path", "Cytology", "Molecular", "IHC", "Frozen Section")
)

# Tests by category (subset - expand as needed)
TESTS <- list(
  Chemistry = c("BMP", "CMP", "Lipid Panel", "LFTs", "Thyroid Panel", "HbA1c", "Glucose", "Creatinine"),
  Hematology = c("CBC", "CBC with Diff", "Reticulocyte", "ESR", "Blood Film"),
  Coagulation = c("PT/INR", "PTT", "D-Dimer", "Fibrinogen", "Anti-Xa"),
  Urinalysis = c("UA", "UA with Micro", "Urine Culture Screen", "UCG"),
  `Blood Gas` = c("ABG", "VBG", "Lactate", "Electrolytes POC"),
  Culture = c("Blood Culture", "Urine Culture", "Wound Culture", "Stool Culture", "Sputum Culture"),
  PCR = c("Resp Viral Panel", "COVID-19", "Flu A/B", "GI Panel", "Meningitis Panel"),
  Serology = c("HIV", "Hepatitis Panel", "Syphilis", "CMV", "EBV"),
  POCT = c("Strep A Rapid", "Flu Rapid", "COVID Rapid", "RSV Rapid"),
  `Gram Stain` = c("CSF Gram", "Blood Gram", "Wound Gram", "Sputum Gram"),
  `Surgical Path` = c("Biopsy", "Excision", "Resection", "Consultation"),
  Cytology = c("Pap Smear", "FNA", "Body Fluid", "Bronchial Wash"),
  Molecular = c("FISH", "PCR Tissue", "NGS Panel", "MSI Testing"),
  IHC = c("IHC Panel Small", "IHC Panel Large", "Special Stains"),
  `Frozen Section` = c("Frozen Section", "Intraop Consult")
)

# QC analytes and instruments
QC_ANALYTES <- c("Glucose", "Creatinine", "Sodium", "Potassium", "Hemoglobin",
                  "WBC", "Platelets", "PT", "Troponin", "TSH")

INSTRUMENTS <- list(
  KBA = c("Cobas 8000", "Cobas 6000", "Sysmex XN", "ACL TOP", "ABL90"),
  KMA = c("VITEK 2", "BacT/ALERT", "FilmArray", "GeneXpert", "MALDI-TOF"),
  KPA = c("Leica ST5010", "Ventana BenchMark", "Illumina MiSeq", "Sakura VIP")
)

# Critical value definitions
CRITICAL_TESTS <- tibble(
  test = c("Potassium", "Glucose", "Hemoglobin", "Platelets", "PT/INR",
           "Troponin", "Lactate", "WBC", "Creatinine", "Blood Culture"),
  low_critical = c(2.5, 40, 6, 20, NA, NA, NA, 1, NA, NA),
  high_critical = c(6.5, 500, 20, 1000, 5, 0.5, 4, 50, 10, NA),
  frequency_weight = c(0.15, 0.1, 0.1, 0.08, 0.08, 0.15, 0.1, 0.08, 0.08, 0.08)
)

# Incident types
INCIDENT_TYPES <- tibble(
  category = c(rep("Pre-analytical", 5), rep("Analytical", 4), rep("Post-analytical", 4)),
  type = c(
    "Specimen mislabeled", "Specimen hemolyzed", "Specimen clotted",
    "Wrong tube type", "Insufficient volume",
    "QC failure", "Instrument malfunction", "Reagent issue", "Result error",
    "Report delay", "Wrong result reported", "Critical value not called",
    "Report sent to wrong provider"
  ),
  severity = c("High", "Medium", "Medium", "Medium", "Low",
               "Medium", "Medium", "Low", "High",
               "Low", "High", "High", "Medium"),
  frequency_weight = c(0.15, 0.20, 0.10, 0.08, 0.12,
                        0.08, 0.06, 0.04, 0.03,
                        0.06, 0.02, 0.02, 0.04)
)

# Organisms and antibiotics for antibiogram
ORGANISMS <- c("E. coli", "K. pneumoniae", "P. aeruginosa", "S. aureus", "MRSA",
               "E. faecalis", "E. faecium", "Enterobacter spp.", "Proteus spp.",
               "Acinetobacter spp.")

ANTIBIOTICS <- c("Ampicillin", "Amoxicillin/Clav", "Ceftriaxone", "Ceftazidime",
                 "Cefepime", "Meropenem", "Ciprofloxacin", "Levofloxacin",
                 "Gentamicin", "Amikacin", "TMP/SMX", "Nitrofurantoin",
                 "Vancomycin", "Linezolid", "Daptomycin")

# ==============================================================================
# SYNTHPOP WRAPPER FUNCTIONS
# These wrap synthpop for production mode
# ==============================================================================

#' Generate synthetic data using synthpop
#'
#' @param real_data Data frame from Layer 2
#' @param method Synthesis method (default: "cart")
#' @param seed Random seed
#' @return Synthetic data frame
#'
#' @details
#' This function wraps synthpop::syn() to generate synthetic data.
#' For human data scientists: Adjust method and parameters based on data characteristics.
#'
#' Methods available:
#' - "cart": Classification and regression trees (default, handles mixed types well)
#' - "parametric": Uses parametric models (faster, less flexible)
#' - "sample": Samples from observed values (preserves marginals only)
#'
#' @examples
#' # In production mode:
#' # layer2_data <- read_layer2("activity_volume")
#' # synthetic <- generate_with_synthpop(layer2_data)
generate_with_synthpop <- function(real_data, method = "cart", seed = 42) {
  if (!requireNamespace("synthpop", quietly = TRUE)) {
    stop("synthpop package required for production mode. Install with: install.packages('synthpop')")
  }

  cat("  Generating synthetic data using synthpop (method:", method, ")...\n")

  # Configure synthesis
  synth_result <- synthpop::syn(
    data = real_data,
    method = method,
    seed = seed,
    print.flag = FALSE
  )

  # Extract synthetic data
  synthetic_data <- synth_result$syn

  # Validate
  cat("  Original rows:", nrow(real_data), "\n")
  cat("  Synthetic rows:", nrow(synthetic_data), "\n")

  return(synthetic_data)
}

#' Read Layer 2 data
#'
#' @param dataset_name Name of dataset (must match LAYER2_PATHS key)
#' @return Data frame
#'
#' @details
#' Human data scientists: Implement actual Layer 2 connection here.
#' This could be:
#' - Database query (DBI, odbc)
#' - File read (CSV, Parquet, RDS)
#' - API call
read_layer2 <- function(dataset_name) {
  path <- LAYER2_PATHS[[dataset_name]]

  if (is.na(path)) {
    stop("Layer 2 path not configured for: ", dataset_name,
         "\nSet environment variable: L2_", toupper(dataset_name))
  }

  cat("  Reading Layer 2 data from:", path, "\n")

  # Determine file type and read
  ext <- tools::file_ext(path)
  data <- switch(ext,
    "rds" = readRDS(path),
    "csv" = readr::read_csv(path, show_col_types = FALSE),
    "parquet" = arrow::read_parquet(path),
    stop("Unsupported file type: ", ext)
  )

  cat("  Read", nrow(data), "rows,", ncol(data), "columns\n")
  return(data)
}

#' Apply field mapping to align with specification
#'
#' @param data Data frame
#' @param mapping Named vector: c(spec_name = "actual_name", ...)
#' @return Data frame with renamed columns
apply_field_mapping <- function(data, mapping) {
  if (length(mapping) == 0) return(data)

  # Reverse mapping for rename (rename uses new = old)
  rename_map <- setNames(mapping, names(mapping))

  data |>
    rename(any_of(rename_map))
}

# ==============================================================================
# PARAMETRIC GENERATORS (Development Mode)
# These create realistic synthetic data without real data
# Human data scientists: Review these to understand expected distributions
# ==============================================================================

#' Generate activity volume data (parametric)
generate_activity_volume_parametric <- function() {
  dates <- seq(START_DATE, END_DATE, by = "day")

  daily <- expand_grid(
    date = dates,
    section = SECTIONS
  ) |>
    mutate(
      base_volume = case_when(
        section == "KBA" ~ 800,
        section == "KMA" ~ 300,
        section == "KPA" ~ 150
      ),
      # Day-of-week effect
      dow_factor = case_when(
        wday(date) %in% c(1, 7) ~ 0.4,
        wday(date) == 2 ~ 1.15,
        TRUE ~ 1.0
      ),
      # Seasonal effect
      season_factor = case_when(
        section == "KMA" & month(date) %in% c(1, 2, 12) ~ 1.25,
        section == "KMA" & month(date) %in% c(6, 7, 8) ~ 0.85,
        TRUE ~ 1.0
      ),
      # Growth trend
      growth_factor = 1 + (as.numeric(date - START_DATE) / 365) * 0.03,
      # Random variation
      random_factor = rnorm(n(), 1, 0.08),
      test_count = round(base_volume * dow_factor * season_factor *
                          growth_factor * pmax(0.7, random_factor)),
      week = floor_date(date, "week"),
      year = year(date),
      month = month(date)
    ) |>
    select(date, week, year, month, section, test_count)

  weekly <- daily |>
    group_by(week, year, section) |>
    summarise(
      test_count = sum(test_count),
      days_in_week = n(),
      .groups = "drop"
    )

  by_category <- daily |>
    crossing(category_idx = 1:5) |>
    rowwise() |>
    mutate(
      categories = list(CATEGORIES[[section]]),
      category = categories[[min(category_idx, length(categories))]],
      category_pct = c(0.35, 0.25, 0.20, 0.12, 0.08)[category_idx],
      category_count = round(test_count * category_pct * rnorm(1, 1, 0.05))
    ) |>
    ungroup() |>
    filter(category_idx <= map_int(section, ~length(CATEGORIES[[.x]]))) |>
    select(date, week, section, category, category_count)

  list(daily = daily, weekly = weekly, by_category = by_category)
}

#' Generate quality indicators data (parametric)
generate_quality_indicators_parametric <- function() {
  months_seq <- seq(floor_date(START_DATE, "month"),
                    floor_date(END_DATE, "month"),
                    by = "month")

  preanalytical <- expand_grid(month = months_seq, section = SECTIONS) |>
    mutate(
      total_specimens = round(runif(n(), 8000, 15000)),
      rejected_specimens = round(total_specimens * rnorm(n(), 0.008, 0.002)),
      hemolyzed_specimens = round(total_specimens * rnorm(n(), 0.015, 0.004)),
      labeling_errors = round(total_specimens * rnorm(n(), 0.0008, 0.0003)),
      missing_samples = round(total_specimens * rnorm(n(), 0.0005, 0.0002)),
      inadequate_volume = round(total_specimens * rnorm(n(), 0.012, 0.003)),
      rejection_rate = rejected_specimens / total_specimens * 100,
      hemolysis_rate = hemolyzed_specimens / total_specimens * 100,
      labeling_error_rate = labeling_errors / total_specimens * 100,
      missing_rate = missing_samples / total_specimens * 100,
      volume_inadequacy_rate = inadequate_volume / total_specimens * 100
    )

  analytical <- expand_grid(month = months_seq, section = SECTIONS) |>
    mutate(
      total_qc_events = round(runif(n(), 500, 1500)),
      qc_passed = round(total_qc_events * rnorm(n(), 0.97, 0.01)),
      total_results = round(runif(n(), 15000, 40000)),
      auto_validated = round(total_results * rnorm(n(), 0.82, 0.05)),
      reruns = round(total_results * rnorm(n(), 0.02, 0.005)),
      qc_pass_rate = qc_passed / total_qc_events * 100,
      auto_validation_rate = auto_validated / total_results * 100,
      rerun_rate = reruns / total_results * 100
    )

  postanalytical <- expand_grid(month = months_seq, section = SECTIONS) |>
    mutate(
      total_results = round(runif(n(), 15000, 40000)),
      within_tat = round(total_results * rnorm(n(), 0.92, 0.03)),
      total_criticals = round(runif(n(), 50, 200)),
      criticals_notified_in_time = round(total_criticals * rnorm(n(), 0.96, 0.02)),
      amendments = round(total_results * rnorm(n(), 0.003, 0.001)),
      corrections = round(total_results * rnorm(n(), 0.0008, 0.0003)),
      tat_compliance_rate = within_tat / total_results * 100,
      critical_notification_rate = criticals_notified_in_time / total_criticals * 100,
      amendment_rate = amendments / total_results * 100,
      correction_rate = corrections / total_results * 100
    )

  quality_index <- preanalytical |>
    left_join(analytical, by = c("month", "section")) |>
    left_join(postanalytical, by = c("month", "section"), suffix = c("", ".post")) |>
    mutate(
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

#' Generate QC data (parametric)
generate_qc_data_parametric <- function() {
  dates <- seq(START_DATE, END_DATE, by = "day")

  qc_daily <- expand_grid(
    date = dates,
    analyte = QC_ANALYTES,
    level = c("Level 1", "Level 2", "Level 3")
  ) |>
    mutate(
      instrument = case_when(
        analyte %in% c("Glucose", "Creatinine", "Sodium", "Potassium", "Troponin", "TSH") ~
          sample(c("Cobas 8000", "Cobas 6000"), n(), replace = TRUE),
        analyte %in% c("Hemoglobin", "WBC", "Platelets") ~ "Sysmex XN",
        analyte == "PT" ~ "ACL TOP",
        TRUE ~ "Unknown"
      ),
      target = case_when(
        level == "Level 1" ~ 50,
        level == "Level 2" ~ 100,
        level == "Level 3" ~ 200
      ),
      sd_expected = target * runif(n(), 0.02, 0.05),
      # 3% chance of larger deviation
      result = target + rnorm(n(), 0, sd_expected) *
        if_else(runif(n()) > 0.97, 2.5, 1),
      z_score = (result - target) / sd_expected,
      westgard_1_2s = abs(z_score) > 2,
      westgard_1_3s = abs(z_score) > 3,
      lot_number = paste0("LOT", sprintf("%04d",
        ((as.numeric(date) - as.numeric(START_DATE)) %/% 90) + 1)),
      qc_passed = abs(z_score) <= 2
    )

  qc_summary <- qc_daily |>
    group_by(analyte, level, instrument) |>
    arrange(date) |>
    mutate(
      row_num = row_number(),
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

  list(daily = qc_daily, summary = qc_summary)
}

#' Generate critical values data (parametric)
generate_critical_values_parametric <- function() {
  n_criticals <- 2500

  start_datetime <- as.POSIXct(START_DATE)
  end_datetime <- as.POSIXct(END_DATE)
  date_range_seconds <- as.numeric(difftime(end_datetime, start_datetime, units = "secs"))

  events <- tibble(
    event_id = 1:n_criticals,
    datetime = start_datetime + runif(n_criticals, 0, date_range_seconds),
    test = sample(CRITICAL_TESTS$test, n_criticals, replace = TRUE,
                  prob = CRITICAL_TESTS$frequency_weight)
  ) |>
    left_join(CRITICAL_TESTS |> select(-frequency_weight), by = "test") |>
    mutate(
      is_low = runif(n()) < 0.4 & !is.na(low_critical),
      result = case_when(
        test == "Blood Culture" ~ NA_real_,
        is_low ~ low_critical * runif(n(), 0.7, 0.95),
        TRUE ~ high_critical * runif(n(), 1.05, 1.5)
      ),
      result_time = datetime,
      notification_start = result_time + runif(n(), 1, 10) * 60,
      notification_success = runif(n()) < 0.96,
      notification_time = if_else(
        notification_success,
        notification_start + rexp(n(), 1/8) * 60,
        as.POSIXct(NA)
      ),
      time_to_notify = as.numeric(difftime(notification_time, result_time, units = "mins")),
      within_30_min = !is.na(time_to_notify) & time_to_notify <= 30,
      ordering_provider = paste0("Dr. ", sample(LETTERS, n_criticals, replace = TRUE),
                                  sample(LETTERS, n_criticals, replace = TRUE)),
      ordering_unit = sample(c("ICU", "ED", "Med/Surg", "Oncology", "Cardiology", "OR"),
                            n_criticals, replace = TRUE,
                            prob = c(0.25, 0.25, 0.2, 0.1, 0.1, 0.1)),
      acknowledged_by = if_else(notification_success, ordering_provider, NA_character_),
      attempts_needed = if_else(notification_success,
                                sample(1:4, n_criticals, replace = TRUE,
                                       prob = c(0.7, 0.2, 0.08, 0.02)),
                                NA_integer_)
    ) |>
    arrange(datetime) |>
    select(-low_critical, -high_critical)

  summary <- events |>
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

  list(events = events, summary = summary)
}

#' Generate incidents data (parametric)
generate_incidents_parametric <- function() {
  n_incidents <- 800

  start_datetime <- as.POSIXct(START_DATE)
  end_datetime <- as.POSIXct(END_DATE)
  date_range_seconds <- as.numeric(difftime(end_datetime, start_datetime, units = "secs"))

  events <- tibble(
    incident_id = sprintf("INC-%06d", 1:n_incidents),
    datetime = start_datetime + runif(n_incidents, 0, date_range_seconds),
    type_idx = sample(1:nrow(INCIDENT_TYPES), n_incidents, replace = TRUE,
                      prob = INCIDENT_TYPES$frequency_weight)
  ) |>
    left_join(INCIDENT_TYPES |> mutate(type_idx = row_number()), by = "type_idx") |>
    mutate(
      section = sample(SECTIONS, n_incidents, replace = TRUE, prob = c(0.5, 0.3, 0.2)),
      resolution_hours = case_when(
        severity == "High" ~ rexp(n(), 1/4) + 1,
        severity == "Medium" ~ rexp(n(), 1/12) + 2,
        TRUE ~ rexp(n(), 1/24) + 4
      ),
      resolved_datetime = datetime + resolution_hours * 3600,
      status = if_else(resolved_datetime <= END_DATE, "Resolved", "Open"),
      root_cause = sample(
        c("Human error", "Process gap", "Equipment failure", "Training needed",
          "Communication failure", "System issue"),
        n_incidents, replace = TRUE,
        prob = c(0.35, 0.25, 0.15, 0.10, 0.10, 0.05)
      ),
      corrective_action = sample(
        c("Staff counseling", "Process revision", "Equipment repair", "Training provided",
          "Policy update", "System fix", "Under review"),
        n_incidents, replace = TRUE
      ),
      reported_by = paste0("Tech ", sample(LETTERS, n_incidents, replace = TRUE),
                           sprintf("%02d", sample(1:50, n_incidents, replace = TRUE)))
    ) |>
    arrange(datetime) |>
    select(-type_idx, -frequency_weight)

  summary <- events |>
    mutate(month = floor_date(as.Date(datetime), "month")) |>
    group_by(month, category) |>
    summarise(
      incident_count = n(),
      high_severity = sum(severity == "High"),
      mean_resolution_hours = mean(resolution_hours),
      .groups = "drop"
    )

  list(events = events, summary = summary, types = INCIDENT_TYPES)
}

#' Generate cost data (parametric)
generate_cost_data_parametric <- function() {
  all_tests <- unlist(TESTS, use.names = FALSE)

  test_costs <- tibble(test = all_tests) |>
    mutate(
      section = case_when(
        test %in% unlist(TESTS[c("Chemistry", "Hematology", "Coagulation",
                                  "Urinalysis", "Blood Gas")]) ~ "KBA",
        test %in% unlist(TESTS[c("Culture", "PCR", "Serology",
                                  "POCT", "Gram Stain")]) ~ "KMA",
        TRUE ~ "KPA"
      ),
      reagent_cost = runif(n(), 2, 50),
      labor_cost = runif(n(), 5, 25),
      overhead_cost = runif(n(), 1, 8),
      total_cost = reagent_cost + labor_cost + overhead_cost,
      reimbursement = total_cost * runif(n(), 1.1, 1.8)
    )

  months_seq <- seq(floor_date(START_DATE, "month"),
                    floor_date(END_DATE, "month"),
                    by = "month")

  monthly <- expand_grid(month = months_seq, test = all_tests) |>
    left_join(test_costs, by = "test") |>
    mutate(
      volume = round(runif(n(), 50, 500) *
                      (1 + (as.numeric(month - min(month)) / 365) * 0.03)),
      inflation_factor = 1 + (as.numeric(month - min(month)) / 365) * 0.02,
      reagent_total = reagent_cost * inflation_factor * volume,
      labor_total = labor_cost * inflation_factor * volume,
      overhead_total = overhead_cost * volume,
      total_expense = reagent_total + labor_total + overhead_total,
      revenue = reimbursement * volume,
      margin = revenue - total_expense,
      cost_per_test = total_expense / volume
    )

  section_summary <- monthly |>
    group_by(month, section) |>
    summarise(
      total_volume = sum(volume),
      total_expense = sum(total_expense),
      total_revenue = sum(revenue),
      total_margin = sum(margin),
      avg_cost_per_test = total_expense / total_volume,
      .groups = "drop"
    )

  list(test_costs = test_costs, monthly = monthly, section_summary = section_summary)
}

#' Generate utilization data (parametric)
generate_utilization_data_parametric <- function() {
  ordering_depts <- c("Internal Medicine", "Emergency", "Surgery", "Oncology",
                      "Cardiology", "Pediatrics", "OB/GYN", "Neurology")

  all_tests <- unlist(TESTS, use.names = FALSE)

  months_seq <- seq(floor_date(START_DATE, "month"),
                    floor_date(END_DATE, "month"),
                    by = "month")

  orders <- expand_grid(
    month = months_seq,
    ordering_dept = ordering_depts,
    test = sample(all_tests, 20)
  ) |>
    mutate(
      order_count = round(runif(n(), 10, 300)),
      duplicate_rate = runif(n(), 0.02, 0.15),
      duplicate_count = round(order_count * duplicate_rate),
      guideline_appropriate = runif(n()) > 0.15,
      utilization_tier = case_when(
        order_count > 200 ~ "High",
        order_count > 50 ~ "Medium",
        TRUE ~ "Low"
      )
    )

  sendout_tests <- c("Specialized Genetics", "Rare Disease Panel", "Reference Cytology",
                     "Esoteric Chemistry", "Specialized Micro")

  sendouts <- expand_grid(month = months_seq, test = sendout_tests) |>
    mutate(
      volume = round(runif(n(), 5, 50)),
      cost_per_test = runif(n(), 100, 800),
      total_cost = volume * cost_per_test,
      tat_days = round(runif(n(), 3, 14)),
      reference_lab = sample(c("Mayo", "Quest", "ARUP", "LabCorp"), n(), replace = TRUE)
    )

  list(orders = orders, sendouts = sendouts)
}

#' Generate antibiogram data (parametric)
generate_antibiogram_parametric <- function() {
  # Base susceptibility patterns
  base_susceptibility <- expand_grid(
    organism = ORGANISMS,
    antibiotic = ANTIBIOTICS
  ) |>
    mutate(
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
        # Gram neg vs glycopeptides
        grepl("Vancomycin|Linezolid|Daptomycin", antibiotic) &
          grepl("coli|pneumoniae|aeruginosa|Enterobacter|Proteus|Acinetobacter", organism) ~ 0,
        TRUE ~ runif(n(), 0.6, 0.95)
      ),
      not_tested = base_rate == 0 |
        (grepl("S. aureus|MRSA|faecalis|faecium", organism) &
         antibiotic %in% c("Nitrofurantoin", "Ceftazidime"))
    )

  quarters <- seq(floor_date(START_DATE, "quarter"),
                  floor_date(END_DATE, "quarter"),
                  by = "quarter")

  data <- expand_grid(quarter = quarters, organism = ORGANISMS, antibiotic = ANTIBIOTICS) |>
    left_join(base_susceptibility, by = c("organism", "antibiotic")) |>
    filter(!not_tested) |>
    mutate(
      time_factor = as.numeric(quarter - min(quarter)) / 365,
      resistance_trend = if_else(
        antibiotic %in% c("Ciprofloxacin", "Ceftriaxone", "Ampicillin"),
        -0.02 * time_factor,
        0
      ),
      susceptibility_rate = pmax(0, pmin(1, base_rate + resistance_trend + rnorm(n(), 0, 0.03))),
      isolate_count = round(runif(n(), 10, 150)),
      susceptible_count = round(isolate_count * susceptibility_rate),
      intermediate_count = round(isolate_count * runif(n(), 0, 0.05)),
      resistant_count = isolate_count - susceptible_count - intermediate_count
    ) |>
    select(-base_rate, -not_tested, -time_factor, -resistance_trend)

  list(data = data, organisms = ORGANISMS, antibiotics = ANTIBIOTICS)
}

#' Generate executive scorecard data (parametric)
generate_executive_scorecard_parametric <- function() {
  months_seq <- seq(floor_date(START_DATE, "month"),
                    floor_date(END_DATE, "month"),
                    by = "month")

  tibble(month = months_seq) |>
    mutate(
      quality_index = 85 + cumsum(rnorm(n(), 0.1, 1)),
      quality_index = pmin(100, pmax(70, quality_index)),
      quality_target = 90,
      quality_status = case_when(
        quality_index >= quality_target ~ "Green",
        quality_index >= quality_target - 5 ~ "Yellow",
        TRUE ~ "Red"
      ),
      tat_compliance = 88 + cumsum(rnorm(n(), 0.05, 1.5)),
      tat_compliance = pmin(100, pmax(75, tat_compliance)),
      tat_target = 90,
      tat_status = case_when(
        tat_compliance >= tat_target ~ "Green",
        tat_compliance >= tat_target - 5 ~ "Yellow",
        TRUE ~ "Red"
      ),
      critical_compliance = 94 + cumsum(rnorm(n(), 0.02, 0.8)),
      critical_compliance = pmin(100, pmax(85, critical_compliance)),
      critical_target = 95,
      critical_status = case_when(
        critical_compliance >= critical_target ~ "Green",
        critical_compliance >= critical_target - 3 ~ "Yellow",
        TRUE ~ "Red"
      ),
      test_volume = 25000 + cumsum(rnorm(n(), 50, 500)),
      test_volume = pmax(20000, test_volume),
      volume_yoy_change = c(NA, diff(test_volume) / head(test_volume, -1) * 100),
      cost_per_test = 15 + cumsum(rnorm(n(), 0.02, 0.3)),
      cost_per_test = pmax(12, cost_per_test),
      cost_target = 14,
      cost_status = case_when(
        cost_per_test <= cost_target ~ "Green",
        cost_per_test <= cost_target * 1.1 ~ "Yellow",
        TRUE ~ "Red"
      ),
      tests_per_fte = 180 + cumsum(rnorm(n(), 0.5, 5)),
      tests_per_fte = pmax(150, tests_per_fte),
      productivity_target = 175,
      productivity_status = case_when(
        tests_per_fte >= productivity_target ~ "Green",
        tests_per_fte >= productivity_target * 0.95 ~ "Yellow",
        TRUE ~ "Red"
      ),
      overall_score = (quality_index * 0.3 + tat_compliance * 0.25 +
                        critical_compliance * 0.2 +
                        (1 - pmin(cost_per_test/20, 1)) * 100 * 0.15 +
                        pmin(tests_per_fte/200, 1) * 100 * 0.10)
    ) |>
    list(monthly = _)
}

# ==============================================================================
# MAIN GENERATION FUNCTIONS
# ==============================================================================

#' Generate a single dataset
#'
#' @param dataset_name Name of dataset
#' @param mode "development" or "production"
generate_dataset <- function(dataset_name, mode = GENERATION_MODE) {
  cat("\nGenerating:", dataset_name, "\n")

  if (mode == "production") {
    # Production mode: Use synthpop on Layer 2 data
    layer2_data <- read_layer2(dataset_name)
    synthetic_data <- generate_with_synthpop(layer2_data)
  } else {
    # Development mode: Use parametric generation
    synthetic_data <- switch(dataset_name,
      "activity_volume" = generate_activity_volume_parametric(),
      "quality_indicators" = generate_quality_indicators_parametric(),
      "qc_data" = generate_qc_data_parametric(),
      "critical_values" = generate_critical_values_parametric(),
      "incidents" = generate_incidents_parametric(),
      "cost_data" = generate_cost_data_parametric(),
      "utilization" = generate_utilization_data_parametric(),
      "antibiogram" = generate_antibiogram_parametric(),
      "executive_scorecard" = generate_executive_scorecard_parametric(),
      stop("Unknown dataset: ", dataset_name)
    )
  }

  return(synthetic_data)
}

#' Save dataset to output directory
save_dataset <- function(data, name, subdir = NULL) {
  if (!is.null(subdir)) {
    output_path <- file.path(OUTPUT_DIR, subdir, "data")
  } else {
    output_path <- file.path(OUTPUT_DIR, name, "data")
  }

  dir.create(output_path, recursive = TRUE, showWarnings = FALSE)
  file_path <- file.path(output_path, paste0(name, ".rds"))

  saveRDS(data, file_path)
  cat("  Saved to:", file_path, "\n")
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

cat("\n========================================\n")
cat("Generating All Datasets\n")
cat("========================================\n")

# Generate all datasets
datasets <- list(
  activity_volume = generate_dataset("activity_volume"),
  quality_indicators = generate_dataset("quality_indicators"),
  qc_data = generate_dataset("qc_data"),
  critical_values = generate_dataset("critical_values"),
  incidents = generate_dataset("incidents"),
  cost_data = generate_dataset("cost_data"),
  utilization = generate_dataset("utilization"),
  antibiogram = generate_dataset("antibiogram"),
  executive_scorecard = generate_dataset("executive_scorecard")
)

# Save all datasets
save_dataset(datasets$activity_volume, "activity_volume", "activity-volume")
save_dataset(datasets$quality_indicators, "quality_indicators", "quality-scorecard")
save_dataset(datasets$qc_data, "qc_data", "qc-trending")
save_dataset(datasets$critical_values, "critical_values", "critical-values")
save_dataset(datasets$incidents, "incidents", "incidents")
save_dataset(datasets$cost_data, "cost_data", "cost-analysis")
save_dataset(datasets$utilization, "utilization_data", "utilization")
save_dataset(datasets$antibiogram, "antibiogram", "antibiogram")
save_dataset(datasets$executive_scorecard, "executive_scorecard", "executive-scorecard")

cat("\n========================================\n")
cat("Generation Complete\n")
cat("========================================\n")
cat("Mode:", GENERATION_MODE, "\n")
cat("Datasets generated:", length(datasets), "\n")
cat("\nTo use production mode with synthpop:\n")
cat("  export SYNTH_MODE=production\n")
cat("  export L2_ACTIVITY_VOLUME=/path/to/layer2/activity.rds\n")
cat("  # ... set other L2_* paths ...\n")
cat("  Rscript generate_synthetic_data.R\n")
