# Lab Intelligence Data Specification

This document specifies the expected data structures for the Lab Intelligence reporting suite. It serves as the contract between Layer 2 (Analytics Data Store) and Layer 3 (Synthetic Data).

## Purpose

1. **For Human Data Scientists**: Reference when building ETL from Layer 1 → Layer 2
2. **For Synthpop Configuration**: Define what fields need synthesis
3. **For Code Adaptation**: Guide for when real data structure differs from specification

---

## Data Architecture Overview

```
Layer 2 (Analytics)          Layer 3 (Synthetic)           Layer 4 (Development)
┌────────────────────┐      ┌────────────────────┐        ┌────────────────────┐
│ activity_volume    │──────│ activity_volume    │────────│ Reports use        │
│ quality_indicators │ syn- │ quality_indicators │ AI +   │ synthetic data     │
│ qc_data            │ thpop│ qc_data            │ human  │ for development    │
│ critical_values    │──────│ critical_values    │────────│                    │
│ incidents          │      │ incidents          │        │                    │
│ cost_data          │      │ cost_data          │        │                    │
│ utilization_data   │      │ utilization_data   │        │                    │
│ antibiogram        │      │ antibiogram        │        │                    │
│ executive_kpis     │      │ executive_kpis     │        │                    │
└────────────────────┘      └────────────────────┘        └────────────────────┘
```

---

## Dataset Specifications

### 1. Activity Volume (`activity_volume`)

**Purpose**: Track test volumes across sections/categories for financial and strategic analysis.

**Source Systems**: KBA, KMA, KPA LIMS

#### Schema: `daily_volume`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `date` | Date | Date of activity | 2024-06-15 | Required, no future dates |
| `section` | Factor | Lab section code | "KBA" | One of: KBA, KMA, KPA |
| `test_count` | Integer | Number of tests performed | 847 | >= 0 |

#### Schema: `weekly_volume`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `week` | Date | Week start (Monday) | 2024-06-10 | Required |
| `year` | Integer | Calendar year | 2024 | 4-digit year |
| `section` | Factor | Lab section code | "KBA" | One of: KBA, KMA, KPA |
| `test_count` | Integer | Weekly test count | 5890 | >= 0 |
| `days_in_week` | Integer | Days with data | 7 | 1-7 |

#### Schema: `category_volume`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `date` | Date | Date of activity | 2024-06-15 | Required |
| `week` | Date | Week start | 2024-06-10 | Required |
| `section` | Factor | Lab section code | "KBA" | One of: KBA, KMA, KPA |
| `category` | Factor | Test category | "Chemistry" | Section-specific (see below) |
| `category_count` | Integer | Tests in category | 312 | >= 0 |

**Category values by section**:
- KBA: Chemistry, Hematology, Coagulation, Urinalysis, Blood Gas
- KMA: Culture, PCR, Serology, POCT, Gram Stain
- KPA: Surgical Path, Cytology, Molecular, IHC, Frozen Section

#### Synthpop Notes
- `test_count` should preserve day-of-week patterns (lower weekends)
- Preserve seasonal correlations (respiratory season for KMA)
- Maintain year-over-year growth trends (~3%)

---

### 2. Quality Indicators (`quality_indicators`)

**Purpose**: Track pre-analytical, analytical, and post-analytical quality metrics.

**Source Systems**: LIS quality modules, QC systems

#### Schema: `preanalytical`

| Field | Type | Description | Example | Target |
|-------|------|-------------|---------|--------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `total_specimens` | Integer | Specimens received | 12500 | > 0 |
| `rejected_specimens` | Integer | Rejected count | 95 | >= 0 |
| `hemolyzed_specimens` | Integer | Hemolyzed count | 180 | >= 0 |
| `labeling_errors` | Integer | Labeling errors | 8 | >= 0 |
| `missing_samples` | Integer | Missing/lost | 5 | >= 0 |
| `inadequate_volume` | Integer | Insufficient volume | 140 | >= 0 |
| `rejection_rate` | Numeric | % rejected | 0.76 | Target: <1% |
| `hemolysis_rate` | Numeric | % hemolyzed | 1.44 | Target: <2% |
| `labeling_error_rate` | Numeric | % mislabeled | 0.064 | Target: <0.1% |
| `missing_rate` | Numeric | % missing | 0.04 | Target: <0.1% |
| `volume_inadequacy_rate` | Numeric | % inadequate | 1.12 | Target: <2% |

#### Schema: `analytical`

| Field | Type | Description | Example | Target |
|-------|------|-------------|---------|--------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `total_qc_events` | Integer | QC runs | 1200 | > 0 |
| `qc_passed` | Integer | QC within limits | 1164 | >= 0 |
| `total_results` | Integer | Patient results | 28500 | > 0 |
| `auto_validated` | Integer | Auto-released | 23370 | >= 0 |
| `reruns` | Integer | Repeated tests | 570 | >= 0 |
| `qc_pass_rate` | Numeric | % QC passed | 97.0 | Target: >95% |
| `auto_validation_rate` | Numeric | % auto-validated | 82.0 | Target: 70-95% |
| `rerun_rate` | Numeric | % reruns | 2.0 | Target: <3% |

#### Schema: `postanalytical`

| Field | Type | Description | Example | Target |
|-------|------|-------------|---------|--------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `total_results` | Integer | Results released | 28500 | > 0 |
| `within_tat` | Integer | Within TAT target | 26220 | >= 0 |
| `total_criticals` | Integer | Critical values | 145 | >= 0 |
| `criticals_notified_in_time` | Integer | Notified <30min | 139 | >= 0 |
| `amendments` | Integer | Amended reports | 85 | >= 0 |
| `corrections` | Integer | Corrected results | 23 | >= 0 |
| `tat_compliance_rate` | Numeric | % within TAT | 92.0 | Target: >90% |
| `critical_notification_rate` | Numeric | % notified in time | 95.9 | Target: >95% |
| `amendment_rate` | Numeric | % amended | 0.30 | Target: <0.5% |
| `correction_rate` | Numeric | % corrected | 0.08 | Target: <0.1% |

#### Synthpop Notes
- Rates should be derived from counts (not synthesized independently)
- Preserve correlation between rejection reasons
- Quality metrics should show realistic variation, not too uniform

---

### 3. QC Data (`qc_data`)

**Purpose**: Daily QC tracking for Levey-Jennings charts and Westgard rules.

**Source Systems**: Instrument middleware, QC management system

#### Schema: `qc_daily`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `date` | Date | QC run date | 2024-06-15 | Required |
| `analyte` | Factor | Test analyte | "Glucose" | See list below |
| `level` | Factor | QC level | "Level 2" | Level 1/2/3 |
| `instrument` | Factor | Analyzer ID | "Cobas 8000" | See list below |
| `target` | Numeric | Expected value | 100.0 | > 0 |
| `sd_expected` | Numeric | Expected SD | 3.5 | > 0 |
| `result` | Numeric | Measured value | 102.3 | > 0 |
| `z_score` | Numeric | (result-target)/sd | 0.66 | Calculated |
| `westgard_1_2s` | Logical | Exceeds 2SD | FALSE | Calculated |
| `westgard_1_3s` | Logical | Exceeds 3SD | FALSE | Calculated |
| `lot_number` | Character | Reagent lot | "LOT0023" | Required |
| `qc_passed` | Logical | Within limits | TRUE | Calculated |

**Analyte list**: Glucose, Creatinine, Sodium, Potassium, Hemoglobin, WBC, Platelets, PT, Troponin, TSH

**Instrument list**:
- KBA: Cobas 8000, Cobas 6000, Sysmex XN, ACL TOP, ABL90
- KMA: VITEK 2, BacT/ALERT, FilmArray, GeneXpert, MALDI-TOF
- KPA: Leica ST5010, Ventana BenchMark, Illumina MiSeq, Sakura VIP

#### Synthpop Notes
- Results should follow normal distribution around target
- ~3% should exceed 2SD (1:2s violations)
- ~0.3% should exceed 3SD (1:3s violations)
- Preserve autocorrelation (consecutive outliers indicate systematic shift)

---

### 4. Critical Values (`critical_values`)

**Purpose**: Track critical value notification timeliness.

**Source Systems**: LIS critical value module, notification system

#### Schema: `critical_events`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `event_id` | Integer | Unique identifier | 12345 | Unique |
| `datetime` | POSIXct | Result timestamp | 2024-06-15 14:32:00 | Required |
| `test` | Factor | Test name | "Potassium" | See list below |
| `result` | Numeric | Critical result | 6.8 | Outside normal range |
| `is_low` | Logical | Low critical | FALSE | TRUE if low critical |
| `ordering_unit` | Factor | Clinical unit | "ICU" | See list below |
| `ordering_provider` | Character | Provider name | "Dr. Smith" | Required |
| `notification_success` | Logical | Successfully notified | TRUE | Required |
| `notification_time` | POSIXct | Time notified | 2024-06-15 14:44:00 | NA if failed |
| `time_to_notify` | Numeric | Minutes to notify | 12.0 | Calculated |
| `within_30_min` | Logical | Met 30-min target | TRUE | Calculated |
| `attempts_needed` | Integer | Contact attempts | 2 | 1-4 typical |

**Test list**: Potassium, Glucose, Hemoglobin, Platelets, PT/INR, Troponin, Lactate, WBC, Creatinine, Blood Culture

**Unit list**: ICU, ED, Med/Surg, Oncology, Cardiology, OR

**Critical thresholds** (for reference):
| Test | Low Critical | High Critical |
|------|-------------|---------------|
| Potassium | <2.5 mEq/L | >6.5 mEq/L |
| Glucose | <40 mg/dL | >500 mg/dL |
| Hemoglobin | <6 g/dL | >20 g/dL |
| Platelets | <20 K/uL | >1000 K/uL |
| PT/INR | - | >5.0 |
| Troponin | - | >0.5 ng/mL |

#### Synthpop Notes
- ~96% notification success rate
- Mean notification time ~12 minutes
- ICU and ED have higher critical volumes
- Preserve time-of-day patterns (more criticals during day shift)

---

### 5. Incidents (`incidents`)

**Purpose**: Track laboratory errors and corrective actions.

**Source Systems**: Quality management system, incident reporting

#### Schema: `incident_events`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `incident_id` | Character | Unique ID | "INC-000123" | Unique |
| `datetime` | POSIXct | Incident timestamp | 2024-06-15 09:15:00 | Required |
| `category` | Factor | Lab phase | "Pre-analytical" | See list below |
| `type` | Factor | Incident type | "Specimen mislabeled" | See list below |
| `severity` | Factor | Severity level | "High" | High/Medium/Low |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `root_cause` | Factor | Root cause | "Human error" | See list below |
| `corrective_action` | Factor | Action taken | "Staff counseling" | See list below |
| `resolution_hours` | Numeric | Hours to resolve | 4.5 | > 0 |
| `status` | Factor | Current status | "Resolved" | Resolved/Open |
| `reported_by` | Character | Reporter ID | "Tech A23" | Required |

**Category and type mapping**:
- Pre-analytical: Specimen mislabeled, Specimen hemolyzed, Specimen clotted, Wrong tube type, Insufficient volume
- Analytical: QC failure, Instrument malfunction, Reagent issue, Result error
- Post-analytical: Report delay, Wrong result reported, Critical value not called, Report sent to wrong provider

**Root causes**: Human error, Process gap, Equipment failure, Training needed, Communication failure, System issue

**Corrective actions**: Staff counseling, Process revision, Equipment repair, Training provided, Policy update, System fix, Under review

#### Synthpop Notes
- Pre-analytical incidents are most common (~60%)
- High severity incidents should resolve faster
- Preserve correlation between type and root cause

---

### 6. Cost Data (`cost_data`)

**Purpose**: Track laboratory costs for financial analysis.

**Source Systems**: Financial system, inventory management

#### Schema: `test_costs` (reference table)

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `test` | Character | Test name | "CBC" | Unique |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `reagent_cost` | Numeric | Reagent cost | 5.50 | >= 0 |
| `labor_cost` | Numeric | Labor cost | 12.00 | >= 0 |
| `overhead_cost` | Numeric | Overhead | 3.25 | >= 0 |
| `total_cost` | Numeric | Total cost | 20.75 | Calculated |
| `reimbursement` | Numeric | Revenue per test | 28.50 | >= 0 |

#### Schema: `monthly_costs`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `test` | Character | Test name | "CBC" | Foreign key |
| `section` | Factor | Lab section | "KBA" | KBA/KMA/KPA |
| `volume` | Integer | Monthly volume | 2500 | >= 0 |
| `reagent_total` | Numeric | Reagent expense | 13750 | Calculated |
| `labor_total` | Numeric | Labor expense | 30000 | Calculated |
| `overhead_total` | Numeric | Overhead expense | 8125 | Calculated |
| `total_expense` | Numeric | Total expense | 51875 | Calculated |
| `revenue` | Numeric | Total revenue | 71250 | Calculated |
| `margin` | Numeric | Revenue - expense | 19375 | Calculated |
| `cost_per_test` | Numeric | Expense / volume | 20.75 | Calculated |

#### Synthpop Notes
- Preserve cost structure relationships (reagent > labor > overhead typically)
- Apply ~2% annual cost inflation
- Volume should correlate with activity_volume data

---

### 7. Utilization Data (`utilization_data`)

**Purpose**: Track test ordering patterns and appropriateness.

**Source Systems**: Order entry system, clinical decision support

#### Schema: `orders`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `ordering_dept` | Factor | Clinical dept | "Internal Medicine" | See list below |
| `test` | Character | Test ordered | "BMP" | Foreign key |
| `order_count` | Integer | Orders placed | 450 | >= 0 |
| `duplicate_count` | Integer | Duplicate orders | 45 | >= 0 |
| `duplicate_rate` | Numeric | % duplicates | 10.0 | Calculated |
| `guideline_appropriate` | Logical | Meets guidelines | TRUE | ~85% true |
| `utilization_tier` | Factor | Volume tier | "High" | High/Medium/Low |

**Ordering departments**: Internal Medicine, Emergency, Surgery, Oncology, Cardiology, Pediatrics, OB/GYN, Neurology

#### Schema: `sendouts`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `test` | Character | Send-out test | "Specialized Genetics" | Required |
| `volume` | Integer | Tests sent | 25 | >= 0 |
| `cost_per_test` | Numeric | Reference lab cost | 350.00 | > 0 |
| `total_cost` | Numeric | Monthly cost | 8750 | Calculated |
| `tat_days` | Integer | Turnaround days | 7 | > 0 |
| `reference_lab` | Factor | Reference lab | "Mayo" | Mayo/Quest/ARUP/LabCorp |

#### Synthpop Notes
- ED and Internal Medicine have highest volumes
- Duplicate rates vary by test type (panels higher than singles)
- Send-out costs are typically $100-800 per test

---

### 8. Antibiogram (`antibiogram`)

**Purpose**: Antimicrobial susceptibility patterns for clinical guidance.

**Source Systems**: Microbiology LIS, susceptibility testing

#### Schema: `susceptibility_data`

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `quarter` | Date | Quarter start | 2024-04-01 | Required |
| `organism` | Factor | Organism name | "E. coli" | See list below |
| `antibiotic` | Factor | Antibiotic tested | "Ciprofloxacin" | See list below |
| `isolate_count` | Integer | Isolates tested | 85 | > 0 |
| `susceptible_count` | Integer | Susceptible | 68 | >= 0 |
| `intermediate_count` | Integer | Intermediate | 4 | >= 0 |
| `resistant_count` | Integer | Resistant | 13 | >= 0 |
| `susceptibility_rate` | Numeric | % susceptible | 0.80 | 0-1 |

**Organisms**: E. coli, K. pneumoniae, P. aeruginosa, S. aureus, MRSA, E. faecalis, E. faecium, Enterobacter spp., Proteus spp., Acinetobacter spp.

**Antibiotics**: Ampicillin, Amoxicillin/Clav, Ceftriaxone, Ceftazidime, Cefepime, Meropenem, Ciprofloxacin, Levofloxacin, Gentamicin, Amikacin, TMP/SMX, Nitrofurantoin, Vancomycin, Linezolid, Daptomycin

#### Synthpop Notes
- Preserve organism-antibiotic susceptibility patterns (e.g., MRSA resistant to beta-lactams)
- Apply slight resistance trends (~1-2% increase per year for certain combinations)
- Some combinations are intrinsically resistant (synthesize as 0%)

---

### 9. Executive Scorecard (`executive_scorecard`)

**Purpose**: High-level KPIs for leadership reporting.

**Source Systems**: Aggregated from other datasets

#### Schema: `monthly_kpis`

| Field | Type | Description | Example | Target |
|-------|------|-------------|---------|--------|
| `month` | Date | First of month | 2024-06-01 | Required |
| `quality_index` | Numeric | Composite quality | 88.5 | >90 |
| `quality_target` | Numeric | Target value | 90.0 | Fixed |
| `quality_status` | Factor | RAG status | "Yellow" | Green/Yellow/Red |
| `tat_compliance` | Numeric | % within TAT | 91.2 | >90% |
| `tat_target` | Numeric | Target value | 90.0 | Fixed |
| `tat_status` | Factor | RAG status | "Green" | Green/Yellow/Red |
| `critical_compliance` | Numeric | % notified <30min | 95.8 | >95% |
| `critical_target` | Numeric | Target value | 95.0 | Fixed |
| `critical_status` | Factor | RAG status | "Green" | Green/Yellow/Red |
| `test_volume` | Integer | Monthly tests | 75000 | - |
| `volume_yoy_change` | Numeric | % vs last year | 3.2 | - |
| `cost_per_test` | Numeric | Average cost | 14.50 | <$14 |
| `cost_target` | Numeric | Target value | 14.0 | Fixed |
| `cost_status` | Factor | RAG status | "Yellow" | Green/Yellow/Red |
| `tests_per_fte` | Numeric | Productivity | 182 | >175 |
| `productivity_target` | Numeric | Target value | 175 | Fixed |
| `productivity_status` | Factor | RAG status | "Green" | Green/Yellow/Red |
| `overall_score` | Numeric | Weighted composite | 87.3 | - |

#### Synthpop Notes
- Should be derived from other datasets, not synthesized independently
- Status fields are deterministic based on value vs target
- Preserve month-over-month continuity (no large jumps)

---

## Adapting to Different Data Structures

When Layer 2 data structure differs from this specification:

### 1. Missing Fields

If a field doesn't exist in Layer 2:

```r
# Option A: Use constant/default value
synth_data <- synth_data |>
  mutate(missing_field = "Unknown")

# Option B: Derive from other fields
synth_data <- synth_data |>
  mutate(derived_field = existing_field1 / existing_field2)

# Option C: Generate independently (last resort)
synth_data <- synth_data |>
  mutate(generated_field = rnorm(n(), mean = 100, sd = 10))
```

### 2. Different Field Names

Create a mapping file:

```r
# field_mapping.R
field_map <- list(
  # specification_name = actual_name
  date = "sample_date",
  section = "lab_section_code",
  test_count = "num_tests"
)

# Apply mapping
real_data <- real_data |>
  rename(!!!field_map)
```

### 3. Different Factor Levels

```r
# Map actual levels to specification levels
section_map <- c(
  "BIOCHEM" = "KBA",
  "MICRO" = "KMA",
  "PATH" = "KPA"
)

real_data <- real_data |>
  mutate(section = recode(section, !!!section_map))
```

### 4. Additional Fields

Additional fields in Layer 2 can be:
- Included in synthesis (if useful)
- Excluded from synthesis (if sensitive or unused)
- Added to specification (update this document)

### 5. Different Aggregation Levels

If Layer 2 is more granular (e.g., hourly instead of daily):

```r
# Aggregate before synthesis
layer2_daily <- layer2_hourly |>
  group_by(date, section) |>
  summarise(test_count = sum(test_count), .groups = "drop")
```

If Layer 2 is less granular (e.g., monthly instead of daily):

```r
# Synthpop will generate at the input granularity
# Reports must adapt to use monthly data
# OR: Use parametric generation to create daily from monthly
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-17 | Initial specification |
