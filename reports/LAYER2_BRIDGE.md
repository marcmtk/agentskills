# Layer 2 → Layer 3 Bridge Workflow

This document guides human data scientists in building the production pipeline to generate synthetic data (Layer 3) from analytics data (Layer 2).

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA SENSITIVITY FRAMEWORK                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Layer 1: Production DB      Layer 2: Analytics DB      Layer 3: Synthetic │
│   ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐ │
│   │ Patient Data    │───ETL──│ Aggregated/     │──synth─│ No Patient Info │ │
│   │ (PHI)           │        │ Anonymized      │  pop   │ Statistical     │ │
│   │ NO AI ACCESS    │        │ HUMAN ONLY      │        │ AI ACCESSIBLE   │ │
│   └─────────────────┘        └─────────────────┘        └─────────────────┘ │
│                                                                             │
│   This document covers:  ────────────────────────────►                      │
│   The Layer 2 → Layer 3 bridge                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required R Packages

```r
install.packages(c(
  "synthpop",    # Synthetic data generation
  "dplyr",       # Data manipulation
  "tidyr",       # Data reshaping
  "lubridate",   # Date handling
  "DBI",         # Database connection (optional)
  "odbc",        # ODBC driver (optional)
  "arrow"        # Parquet support (optional)
))
```

### Required Access

- Read access to Layer 2 Analytics database or exported files
- Write access to Layer 3 synthetic data storage
- Understanding of your institution's data dictionary

## Workflow Steps

### Step 1: Extract Layer 2 Data

Export data from your analytics database. The synthetic generator expects one of these formats:

```r
# Option A: Export to RDS files (recommended)
layer2_data <- DBI::dbGetQuery(conn, "SELECT * FROM analytics.activity_volume")
saveRDS(layer2_data, "layer2_exports/activity_volume.rds")

# Option B: Export to CSV
write.csv(layer2_data, "layer2_exports/activity_volume.csv", row.names = FALSE)

# Option C: Export to Parquet (for large datasets)
arrow::write_parquet(layer2_data, "layer2_exports/activity_volume.parquet")
```

### Step 2: Validate Layer 2 Schema

Compare your data against `DATA_SPECIFICATION.md`. For each dataset:

```r
library(dplyr)

# Load your Layer 2 data
l2_data <- readRDS("layer2_exports/activity_volume.rds")

# Check column names
names(l2_data)
# Expected: date, section, test_count (for daily_volume)

# Check data types
str(l2_data)
# Expected: date=Date, section=character/factor, test_count=integer

# Check value ranges
summary(l2_data)
# Expected: date in reasonable range, sections in {KBA, KMA, KPA}, counts >= 0
```

### Step 3: Create Field Mapping (if needed)

If your column names differ from the specification:

```r
# field_mapping.R - Create this file for your institution

# Activity Volume mapping
activity_volume_mapping <- c(
  # specification_name = "your_column_name"
  date = "sample_date",           # Your date column
  section = "lab_section_code",   # Your section column
  test_count = "num_tests"        # Your count column
)

# Quality Indicators mapping
quality_indicators_mapping <- c(
  month = "report_month",
  section = "department",
  total_specimens = "specimen_count",
  rejected_specimens = "rejected_count"
  # ... add all fields
)

# Save all mappings
saveRDS(list(
  activity_volume = activity_volume_mapping,
  quality_indicators = quality_indicators_mapping
  # ... other datasets
), "layer2_exports/field_mappings.rds")
```

### Step 4: Create Value Mapping (if needed)

If your factor levels differ from the specification:

```r
# value_mapping.R - Create this file for your institution

# Section codes mapping
section_mapping <- c(
  "BIOCHEM" = "KBA",
  "BIOCHEMISTRY" = "KBA",
  "MICRO" = "KMA",
  "MICROBIOLOGY" = "KMA",
  "PATH" = "KPA",
  "PATHOLOGY" = "KPA"
)

# Severity mapping (for incidents)
severity_mapping <- c(
  "CRITICAL" = "High",
  "MAJOR" = "High",
  "MODERATE" = "Medium",
  "MINOR" = "Low"
)

# Save all mappings
saveRDS(list(
  section = section_mapping,
  severity = severity_mapping
), "layer2_exports/value_mappings.rds")
```

### Step 5: Transform Layer 2 Data

Create a transform script for your institution:

```r
# transform_layer2.R

library(dplyr)

# Load mappings
field_maps <- readRDS("layer2_exports/field_mappings.rds")
value_maps <- readRDS("layer2_exports/value_mappings.rds")

#' Transform Layer 2 data to match specification schema
#'
#' @param data Data frame from Layer 2
#' @param dataset_name Name of the dataset
#' @return Transformed data frame matching specification
transform_to_spec <- function(data, dataset_name) {

  # Apply field mapping
  field_map <- field_maps[[dataset_name]]
  if (!is.null(field_map)) {
    # Create reverse mapping for rename (new_name = old_name)
    rename_pairs <- setNames(field_map, names(field_map))
    data <- data |>
      rename(any_of(rename_pairs))
  }

  # Apply value mappings
  if ("section" %in% names(data)) {
    data <- data |>
      mutate(section = recode(section, !!!value_maps$section))
  }

  if ("severity" %in% names(data)) {
    data <- data |>
      mutate(severity = recode(severity, !!!value_maps$severity))
  }

  return(data)
}

# Example usage
activity_raw <- readRDS("layer2_exports/activity_volume.rds")
activity_spec <- transform_to_spec(activity_raw, "activity_volume")
saveRDS(activity_spec, "layer2_transformed/activity_volume.rds")
```

### Step 6: Run Synthetic Generation

Set environment variables and run the generator:

```bash
# Set production mode
export SYNTH_MODE=production

# Set Layer 2 data paths (use transformed data)
export L2_ACTIVITY_VOLUME=/path/to/layer2_transformed/activity_volume.rds
export L2_QUALITY=/path/to/layer2_transformed/quality_indicators.rds
export L2_QC=/path/to/layer2_transformed/qc_data.rds
export L2_CRITICAL=/path/to/layer2_transformed/critical_values.rds
export L2_INCIDENTS=/path/to/layer2_transformed/incidents.rds
export L2_COSTS=/path/to/layer2_transformed/cost_data.rds
export L2_UTILIZATION=/path/to/layer2_transformed/utilization.rds
export L2_ANTIBIOGRAM=/path/to/layer2_transformed/antibiogram.rds

# Set output directory
export SYNTH_OUTPUT=/path/to/reports

# Set date range (optional)
export SYNTH_END_DATE=2024-12-31

# Set seed for reproducibility
export SYNTH_SEED=42

# Run generation
Rscript generate_synthetic_data.R
```

### Step 7: Validate Synthetic Data

Compare statistical properties of synthetic vs original data:

```r
library(synthpop)

# Load original and synthetic
original <- readRDS("layer2_transformed/activity_volume.rds")
synthetic <- readRDS("reports/activity-volume/data/activity_volume.rds")

# For list-structured data, compare each component
if (is.list(synthetic) && !is.data.frame(synthetic)) {
  synthetic <- synthetic$daily  # Compare daily component
  original <- original$daily
}

# Compare distributions
compare(
  synthetic,
  original,
  vars = c("test_count", "section"),
  utility.stats = c("pMSE", "S_pMSE")
)

# Visual comparison
compare(synthetic, original, stat = "counts")
```

## Handling Common Scenarios

### Scenario 1: Missing Required Fields

If your Layer 2 data lacks a field required by the specification:

```r
# Option A: Use a constant value
data <- data |>
  mutate(missing_field = "Unknown")

# Option B: Derive from other fields
data <- data |>
  mutate(rejection_rate = rejected_specimens / total_specimens * 100)

# Option C: Use institution-specific default
data <- data |>
  mutate(section = case_when(
    is.na(section) ~ "KBA",  # Default to most common section
    TRUE ~ section
  ))
```

### Scenario 2: Different Granularity

If your data has different time granularity:

```r
# Hourly to Daily aggregation
daily_data <- hourly_data |>
  mutate(date = as.Date(datetime)) |>
  group_by(date, section) |>
  summarise(
    test_count = sum(test_count),
    .groups = "drop"
  )

# Monthly to Weekly disaggregation
# Note: This requires assumptions about distribution within month
weekly_data <- monthly_data |>
  crossing(week_offset = 0:3) |>
  mutate(
    week = floor_date(month, "month") + weeks(week_offset),
    test_count = round(test_count / 4)  # Assume even distribution
  ) |>
  filter(week <= month + months(1) - days(1))
```

### Scenario 3: Extra Fields

If your Layer 2 data has additional fields:

```r
# Option A: Include in synthesis (if useful and non-sensitive)
# No action needed - synthpop will include them

# Option B: Exclude from synthesis
data <- data |>
  select(-sensitive_field_1, -sensitive_field_2)

# Option C: Protect specific fields
library(synthpop)
syn_result <- syn(
  data,
  method = "cart",
  # Don't synthesize these fields - use original values
  method.cat = c(non_sensitive_id = "sample")
)
```

### Scenario 4: Different Section Codes

If your institution uses different lab section identifiers:

```r
# Map to standard codes
section_mapping <- c(
  "CHEM" = "KBA",
  "HEMA" = "KBA",
  "COAG" = "KBA",
  "URIN" = "KBA",
  "MICR" = "KMA",
  "SERO" = "KMA",
  "SURG" = "KPA",
  "CYTO" = "KPA"
)

data <- data |>
  mutate(section = recode(section, !!!section_mapping))
```

## Synthpop Configuration Guide

### Method Selection

Choose synthesis method based on data characteristics:

| Data Type | Recommended Method | When to Use |
|-----------|-------------------|-------------|
| Mixed types | `cart` (default) | Most datasets |
| Numeric only | `norm` | Simple continuous data |
| Categorical | `polyreg` | Categorical with few levels |
| Counts | `poisson` | Count data |
| Proportions | `beta` | Rate data (0-1) |
| Time series | `cart` + lag vars | Data with temporal patterns |

### Preserving Correlations

For related fields:

```r
# Ensure derived fields aren't synthesized independently
# Instead, synthesize base fields and derive

syn_result <- syn(
  data |> select(-derived_rate),  # Remove derived field
  method = "cart"
)

# Re-derive after synthesis
synthetic <- syn_result$syn |>
  mutate(derived_rate = numerator / denominator * 100)
```

### Handling Dates

```r
# Convert dates to numeric for synthesis
data_for_synth <- data |>
  mutate(
    date_numeric = as.numeric(date),
    month_numeric = as.numeric(month)
  ) |>
  select(-date, -month)

syn_result <- syn(data_for_synth)

# Convert back after synthesis
synthetic <- syn_result$syn |>
  mutate(
    date = as.Date(date_numeric, origin = "1970-01-01"),
    month = as.Date(month_numeric, origin = "1970-01-01")
  )
```

## Quality Assurance Checklist

Before deploying synthetic data:

- [ ] All required columns present in synthetic data
- [ ] Column types match specification
- [ ] Value ranges are realistic
- [ ] No patient identifiers leaked (manual review)
- [ ] Distributions are similar (pMSE < 0.1 for key fields)
- [ ] Correlations are preserved (check key relationships)
- [ ] Reports render without errors
- [ ] Business logic produces expected results

## Troubleshooting

### "synthpop package not found"

```r
install.packages("synthpop")
# If issues, try:
install.packages("synthpop", repos = "https://cloud.r-project.org")
```

### "Synthesis failed for column X"

Check for:
- Missing values (synthpop handles NA but may need method adjustment)
- Constant columns (no variation to synthesize)
- Very sparse categories (consider collapsing)

```r
# For problematic columns, try different method
syn_result <- syn(
  data,
  method = c(
    problem_col = "sample",  # Just sample from observed values
    other_col = "cart"
  )
)
```

### "Synthetic data has different row count"

By default, synthpop generates same number of rows. To change:

```r
syn_result <- syn(
  data,
  k = nrow(data) * 2  # Generate 2x the rows
)
```

### "Correlations not preserved"

For strong correlations:

```r
# Use cart method with visit sequence
syn_result <- syn(
  data,
  method = "cart",
  visit.sequence = c("corr_var_1", "corr_var_2", "corr_var_3")  # Order by causality
)
```

## Security Reminders

1. **Never commit Layer 2 data to version control**
2. **Store exported files in secure, access-controlled locations**
3. **Review synthetic output for any potential data leakage**
4. **Document all transformations for audit purposes**
5. **Regenerate synthetic data periodically as Layer 2 evolves**

## Contact

For questions about:
- This workflow: Contact Lab Intelligence team
- Data access: Contact IT Security / Data Governance
- Synthpop technical issues: See [synthpop documentation](https://www.synthpop.org.uk/)

---

*Document version: 1.0*
*Last updated: 2026-01-17*
