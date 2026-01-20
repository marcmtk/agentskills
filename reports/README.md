# Lab Intelligence Reports Suite

A comprehensive suite of laboratory analytics reports and dashboards built with R and Quarto.

## Quick Start

```bash
# Generate all synthetic data
cd reports
Rscript generate_all_data.R

# Render a specific report
quarto render activity-volume/activity-volume-report.qmd

# Render all reports
for dir in */; do
  if [ -f "${dir}"*-report.qmd ]; then
    quarto render "${dir}"*-report.qmd
  fi
done
```

## Reports Overview

| Report | Archetype | Primary Audience | Refresh |
|--------|-----------|------------------|---------|
| Activity Volume | Financial/Strategic | Technical Director, Section Heads | Weekly |
| Quality Scorecard | Quality/Compliance | Medical Director, Specialty MDs | Monthly |
| QC Trending | Quality/Compliance | Clinical Chemists, Lab Techs | Daily |
| Critical Values | Clinical Decision Support | Medical Director, Quality Manager | Daily |
| Incidents | Quality/Compliance | Quality Manager, Section Heads | Daily |
| Cost Analysis | Financial | Financial Director | Monthly |
| Utilization | Financial/Strategic | Medical Director, Dept Heads | Monthly |
| Antibiogram | Clinical Decision Support | Microbiologists, Infection Prevention | Quarterly |
| Executive Scorecard | Strategic | Hospital Executives, Lab Director | Monthly |

## Directory Structure

```
reports/
├── generate_all_data.R          # Development/demo data generator
├── generate_synthetic_data.R    # Production synthpop-based generator
├── DATA_SPECIFICATION.md        # Schema documentation for all datasets
├── LAYER2_BRIDGE.md             # Workflow guide for Layer 2 → Layer 3
├── README.md                    # This file
│
├── activity-volume/             # Test volume analysis
│   ├── data/
│   └── activity-volume-report.qmd
│
├── quality-scorecard/            # Quality metrics scorecard
│   ├── data/
│   └── quality-scorecard-report.qmd
│
├── qc-trending/                  # QC Levey-Jennings charts
│   ├── data/
│   └── qc-trending-report.qmd
│
├── critical-values/              # Critical value notifications
│   ├── data/
│   └── critical-values-report.qmd
│
├── incidents/                    # Error and incident tracking
│   ├── data/
│   └── incidents-report.qmd
│
├── cost-analysis/                # Cost per test analysis
│   ├── data/
│   └── cost-analysis-report.qmd
│
├── utilization/                  # Test utilization patterns
│   ├── data/
│   └── utilization-report.qmd
│
├── antibiogram/                  # Antimicrobial susceptibility
│   ├── data/
│   └── antibiogram-report.qmd
│
└── executive-scorecard/          # Executive KPI dashboard
    ├── data/
    └── executive-scorecard-report.qmd
```

## Data Generation

Two data generation approaches are available:

### Development Mode (Default)

The `generate_all_data.R` script creates parametric synthetic data for demos and development:

```bash
Rscript generate_all_data.R
```

### Production Mode (Synthpop)

For production use with real Layer 2 data, use `generate_synthetic_data.R` with the synthpop package:

```bash
# Configure environment
export SYNTH_MODE=production
export L2_ACTIVITY_VOLUME=/path/to/layer2/activity.rds
export L2_QUALITY=/path/to/layer2/quality.rds
# ... see LAYER2_BRIDGE.md for all variables ...

# Generate synthetic data
Rscript generate_synthetic_data.R
```

### Documentation

| Document | Purpose |
|----------|---------|
| `DATA_SPECIFICATION.md` | Schema definitions for all datasets |
| `LAYER2_BRIDGE.md` | Workflow guide for Layer 2 → Layer 3 pipeline |
| `generate_all_data.R` | Development/demo data generator |
| `generate_synthetic_data.R` | Production synthpop-based generator |

### Data Characteristics

Both generators produce:
- **15 months** of historical data for year-over-year comparisons
- **3 lab sections**: KBA (Biochemistry), KMA (Microbiology), KPA (Pathology)
- **66+ test types** across multiple categories
- Realistic patterns including:
  - Day-of-week effects (lower weekend volumes)
  - Seasonal variation (respiratory season for microbiology)
  - Year-over-year growth trends
  - Random variation within realistic bounds

All data is synthetic per the data-sensitivity-framework.md (Layer 3).

## Report Details

### Activity Volume Dashboard
- Weekly test volumes with YoY comparison
- Anomaly detection (>2 SD from mean)
- Drill-down: Department → Section → Category → Test
- Trend analysis with LOESS smoothing

### Quality Indicator Scorecard
- Pre-analytical metrics (rejection, hemolysis, labeling errors)
- Analytical metrics (QC pass rate, auto-validation, reruns)
- Post-analytical metrics (TAT, critical values, amendments)
- Weighted quality index with traffic light status
- Accreditation compliance summary

### QC Trending Dashboard
- Levey-Jennings control charts
- Westgard rule evaluation (1:2s, 1:3s)
- CV trend analysis
- Instrument and lot performance
- Corrective action identification

### Critical Value Notification Report
- Notification time distribution
- 30-minute compliance tracking
- Performance by test type and ordering unit
- Time-of-day analysis
- Failed notification tracking

### Error and Incident Tracker
- Incidents by phase (pre/analytical/post-analytical)
- Root cause analysis
- Resolution time tracking
- Severity distribution
- Recurrence pattern identification

### Cost Per Test Analysis
- Cost breakdown (reagent, labor, overhead)
- Section and test-level analysis
- Margin analysis
- Month-over-month variance
- Cost reduction opportunities

### Test Utilization Report
- Orders by department
- Duplicate/repeat order analysis
- Guideline appropriateness scoring
- Send-out test tracking
- Low-value test identification

### Antibiogram Dashboard
- Classic antibiogram matrix
- Gram-positive/negative views
- Resistance trends over time
- Concerning trend alerts
- Empiric therapy recommendations

### Executive Scorecard
- KPI summary with status indicators
- Quality, operational, financial metrics
- Strategic initiative tracking
- Automated insights generation
- Leadership recommendations

## Dependencies

### Core R packages (required):
- dplyr, tidyr, purrr (data manipulation)
- ggplot2, scales (visualization)
- lubridate (date handling)
- gt (tables)

### Additional packages for production mode:
- synthpop (synthetic data generation from real data)
- DBI, odbc (database connections, optional)
- arrow (Parquet file support, optional)

Install core packages:
```r
install.packages(c("dplyr", "tidyr", "purrr", "ggplot2",
                   "scales", "lubridate", "gt"))
```

Install production mode packages:
```r
install.packages(c("synthpop", "arrow"))
```

## Customization

### Adding New Metrics
1. Update `generate_all_data.R` to include new data
2. Add visualization/table in relevant report
3. Follow existing patterns for consistency

### Changing Targets
Targets are defined in each report's setup chunk. Modify as needed for your institution.

### Branding
Use the `/brand-yml` skill to create a `_brand.yml` file for consistent styling across all reports.

## Governance

Per the lab-intelligence-planning framework:
- **Product Owner**: Responsible for requirements and priorities
- **Data Steward**: Ensures data quality and definitions
- **Technical Owner**: Maintains code and infrastructure
- **Review Cycle**: Quarterly usage and accuracy review
