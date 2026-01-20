# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a clinical laboratory intelligence and analytics framework ("agentskills") containing:
- **lab-intelligence-planning/** - A skill framework for designing, building, and governing BI products for clinical laboratories
- **reports/** - Complete suite of 9 lab intelligence dashboards (see Reports Suite below)
- **tat-report/** - Original TAT analysis example
- **skills/** - Local Claude Code skills for R development
- **data-sensitivity-framework.md** - Operating model for AI-assisted development while protecting patient data

## Reports Suite

The `reports/` directory contains a comprehensive suite of lab intelligence dashboards:

| Report | Description | Audience | Refresh |
|--------|-------------|----------|---------|
| **activity-volume** | Test volume with YoY comparison, anomaly detection | Technical Director, Section Heads | Weekly |
| **quality-scorecard** | Pre/analytical/post-analytical quality metrics | Medical Director, Specialty MDs | Monthly |
| **qc-trending** | Levey-Jennings charts, Westgard rules, CV trends | Clinical Chemists, Lab Techs | Daily |
| **critical-values** | Notification compliance, time tracking | Medical Director, Quality Manager | Daily |
| **incidents** | Error tracking, root cause analysis | Quality Manager, Section Heads | Daily |
| **cost-analysis** | Cost per test, margin analysis | Financial Director | Monthly |
| **utilization** | Ordering patterns, duplicate detection | Medical Director, Dept Heads | Monthly |
| **antibiogram** | Antimicrobial susceptibility matrix | Microbiologists, Infection Prevention | Quarterly |
| **executive-scorecard** | KPI summary for leadership | Hospital Executives, Lab Director | Monthly |

## Commands

### Using Make (Recommended)
```bash
make help          # Show all available targets
make all           # Generate data and render all reports
make data          # Generate synthetic data only
make reports       # Render all Quarto reports
make test          # Run test suite
make lint          # Check code style
make clean         # Remove generated files
make docker-build  # Build Docker image
make docker-run    # Run interactive container
```

### Manual Commands
```bash
# Generate all report data
cd reports && Rscript generate_all_data.R

# Render a specific report
quarto render reports/activity-volume/activity-volume-report.qmd

# Render TAT report (original example)
quarto render tat-report/tat-report.qmd

# Run tests
Rscript tests/testthat.R
```

### Environment Setup
```bash
# Option 1: Automated setup (installs dependencies)
Rscript setup.R

# Option 2: Manual install
Rscript -e "install.packages(c('dplyr','tidyr','purrr','ggplot2','scales','lubridate','gt','testthat'))"
```

### Docker Environment
The Dockerfile uses `rocker/tidyverse` as base image with Node.js and Claude Code CLI.

## Architecture

### Data Sensitivity Layers (Critical for AI Development)

The project enforces strict data separation for patient privacy:

1. **Layer 1-2**: Production/Analytics databases - **No AI access** (patient data)
2. **Layer 3**: Synthetic data - **AI readable** (procedurally generated, no patient info)
3. **Layer 4**: Development environment - Humans + AI work with synthetic data only
4. **Layer 5-6**: Staging/Production - Human-reviewed code only

**Important**: When working in this repository, only use synthetic data from Layer 3. Never attempt to access or process real patient data.

### Lab Intelligence Planning Framework

The skill framework in `lab-intelligence-planning/` provides three workflows:

1. **Discovery Workflow** - Assess existing BI landscape, identify gaps
2. **Design Workflow** - Specify new dashboards/reports using personas and archetypes
3. **Governance Workflow** - Manage portfolio lifecycle (proposal → production → deprecation)

Key reference materials:
- `references/personas.md` - 12 stakeholder personas (pathologists, lab directors, technicians, executives)
- `references/portfolio-types.md` - 15+ dashboard archetypes by category
- `references/quality-indicators.md` - Standard KPIs by lab phase, TAT targets, specialty metrics
- `references/governance.md` - Ownership models, lifecycle stages, review cadences

### TAT Report Implementation

The `tat-report/` directory demonstrates the framework with a Turnaround Time analysis:
- `generate_data.R` - Creates synthetic mock data with realistic distributions
- `tat-report.qmd` - Quarto markdown report with R analysis
- Uses: dplyr, tidyr, ggplot2, lubridate, scales, gt, purrr

## Key Domain Concepts

- **TAT (Turnaround Time)** - Time from sample collection to result reporting
- **Pre-analytical/Analytical/Post-analytical phases** - Lab workflow stages with distinct metrics
- **Quality indicators** - Standardized KPIs documented in `quality-indicators.md`

## Claude Code Skills

The following skills are available:

### `/brand-yml` (via shiny plugin)
Create and use `_brand.yml` files for consistent branding across Shiny apps and Quarto documents. Use when:
- Creating new brand.yml files from brand guidelines
- Applying brand styling to Shiny for R apps (with bslib)
- Applying brand styling to Shiny for Python apps (with ui.Theme)
- Using brand.yml in Quarto documents, presentations, or dashboards
- Troubleshooting brand integration issues

### Writing Tidyverse R (local skill)
Located in `skills/writing-tidyverse-r/`. Modern tidyverse patterns, style guide, and migration guidance for R development. Reference this skill when:
- Writing R code with dplyr, tidyr, purrr, stringr
- Reviewing tidyverse code for best practices
- Updating legacy R code to modern patterns (R 4.3+, dplyr 1.1+)
- Enforcing consistent style (snake_case, native pipe `|>`, `.by` grouping)

Key patterns covered:
- Native pipe `|>` instead of `%>%`
- `join_by()` syntax for joins
- `.by` argument for per-operation grouping
- `pick()`/`across()`/`reframe()` operations
- stringr over base R string functions
- Migration from base R and older tidyverse APIs
