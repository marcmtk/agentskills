# Lab Intelligence Framework

A comprehensive framework for designing, building, and governing Business Intelligence products for clinical laboratories. Built with R, Quarto, and AI-assisted development workflows.

## Overview

This repository contains:

- **9 Production-Ready Dashboards** - Complete lab analytics reports covering quality, operations, finance, and strategy
- **Strategic Planning Framework** - Structured workflows for BI portfolio design and governance
- **Data Sensitivity Architecture** - 6-layer model enabling AI-assisted development while protecting patient data
- **Modern R Development Skills** - Tidyverse style guides and patterns for R 4.3+

## Quick Start

```bash
# Clone the repository
git clone https://github.com/marcmtk/agentskills.git
cd agentskills

# Generate synthetic data
cd reports
Rscript generate_all_data.R

# Render a report
quarto render activity-volume/activity-volume-report.qmd

# Or use Make (recommended)
make all
```

## Project Structure

```
agentskills/
├── reports/                    # 9 complete lab analytics dashboards
│   ├── activity-volume/        # Test volume with YoY comparison
│   ├── quality-scorecard/      # Pre/analytical/post-analytical quality
│   ├── qc-trending/            # Levey-Jennings QC charts
│   ├── critical-values/        # Critical value notification tracking
│   ├── incidents/              # Error and incident management
│   ├── cost-analysis/          # Cost per test analysis
│   ├── utilization/            # Test ordering patterns
│   ├── antibiogram/            # Antimicrobial susceptibility
│   └── executive-scorecard/    # Executive KPI dashboard
│
├── lab-intelligence-planning/  # Strategic BI planning skill
│   ├── SKILL.md                # Skill definition
│   ├── examples/               # Product specifications
│   └── references/             # Personas, archetypes, KPIs
│
├── skills/                     # Development skills
│   └── writing-tidyverse-r/    # Modern R/tidyverse patterns
│
├── tat-report/                 # Original proof-of-concept
│
├── data-sensitivity-framework.md  # 6-layer data architecture
├── CLAUDE.md                      # AI assistant guidance
├── Makefile                       # Build automation
└── Dockerfile                     # Container environment
```

## Reports Suite

| Report | Domain | Primary Audience | Refresh |
|--------|--------|------------------|---------|
| Activity Volume | Financial | Technical Director, Section Heads | Weekly |
| Quality Scorecard | Quality | Medical Director, Specialty MDs | Monthly |
| QC Trending | Quality | Clinical Chemists, Lab Techs | Daily |
| Critical Values | Clinical | Medical Director, Quality Manager | Daily |
| Incidents | Quality | Quality Manager, Section Heads | Daily |
| Cost Analysis | Financial | Financial Director | Monthly |
| Utilization | Strategic | Medical Director, Dept Heads | Monthly |
| Antibiogram | Clinical | Microbiologists, Infection Prevention | Quarterly |
| Executive Scorecard | Strategic | Hospital Executives, Lab Director | Monthly |

## Data Sensitivity Framework

This project implements a 6-layer architecture for safe AI-assisted development:

| Layer | Purpose | AI Access |
|-------|---------|-----------|
| 1. Production DB | Raw patient data | None |
| 2. Analytics Store | Aggregated, de-identified | None |
| 3. Synthetic Data | Synthpop-generated | Full |
| 4. Development | Code + Layer 3 data | Full |
| 5. Staging | Code + Layer 2 data | None |
| 6. Production | Live dashboards | None |

See [data-sensitivity-framework.md](data-sensitivity-framework.md) for details.

## Requirements

### R Packages

```r
install.packages(c(
  "dplyr", "tidyr", "purrr",    # Data manipulation
  "ggplot2", "scales",          # Visualization
  "lubridate",                  # Date handling
  "gt"                          # Tables
))

# For production synthetic data generation
install.packages("synthpop")
```

### System Requirements

- R >= 4.3.0 (for native pipe `|>`)
- Quarto >= 1.4.0
- Docker (optional, for containerized execution)

## Development

### Using Make

```bash
make data      # Generate all synthetic data
make reports   # Render all Quarto reports
make test      # Run test suite
make lint      # Check code style
make clean     # Remove generated files
make all       # data + reports
```

### Using Docker

```bash
# Build the image
docker build -t lab-intelligence .

# Run data generation
docker run -v $(pwd):/workspace lab-intelligence \
  Rscript reports/generate_all_data.R

# Render reports
docker run -v $(pwd):/workspace lab-intelligence \
  quarto render reports/activity-volume/activity-volume-report.qmd
```

## Skills for AI Assistants

This repository includes skills for AI coding assistants:

### Lab Intelligence Planning (`/lab-intelligence`)
Guides design and governance of lab BI portfolios:
- **Discovery Workflow** - Assess current BI landscape
- **Design Workflow** - Specify new dashboards using personas
- **Governance Workflow** - Manage portfolio lifecycle

### Tidyverse R Writing (`/tidyverse`)
Modern R patterns for R 4.3+:
- Native pipe `|>` over magrittr `%>%`
- `join_by()` syntax for joins
- `.by` for per-operation grouping
- `pick()`, `across()`, `reframe()` operations

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

Key points:
- All data in this repo is synthetic (Layer 3)
- Never commit real patient data
- Follow tidyverse style guide
- Add tests for new functionality

## Documentation

| Document | Purpose |
|----------|---------|
| [reports/README.md](reports/README.md) | Dashboard suite documentation |
| [reports/DATA_SPECIFICATION.md](reports/DATA_SPECIFICATION.md) | Data schema definitions |
| [reports/LAYER2_BRIDGE.md](reports/LAYER2_BRIDGE.md) | Production data workflow |
| [data-sensitivity-framework.md](data-sensitivity-framework.md) | Data privacy architecture |
| [CLAUDE.md](CLAUDE.md) | AI assistant guidance |
| [IMPROVEMENT_PLAN.md](IMPROVEMENT_PLAN.md) | Technical roadmap |

## License

MIT License - see [LICENSE](LICENSE) for details.

Copyright (c) 2026 Marc Trunjer Kusk Nielsen

## Acknowledgments

- Built with [Quarto](https://quarto.org/)
- R packages from the [tidyverse](https://www.tidyverse.org/)
- Synthetic data via [synthpop](https://www.synthpop.org.uk/)
- AI-assisted development with [Claude Code](https://claude.ai/code)
