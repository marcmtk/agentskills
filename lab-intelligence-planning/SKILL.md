---
name: lab-intelligence-planning
description: Plan, design, and govern a portfolio of reports, dashboards, and data products for clinical laboratories (biochemistry, pathology, clinical microbiology, molecular diagnostics). Use when lab managers and data science teams need to (1) assess current BI landscape and identify gaps, (2) design new dashboards or reports for specific stakeholders, (3) prioritize what to build next, (4) establish ownership and review cycles, or (5) rationalize/prune an existing portfolio. Technology-agnostic guidance focused on information architecture and stakeholder needs.
---

# Lab Intelligence Planning

Guide lab managers and data science teams through designing, building, and governing a portfolio of BI products for clinical laboratories.

## Workflows

This skill supports three primary workflows. Determine which applies based on user intent:

| User Intent | Workflow | Key References |
|-------------|----------|----------------|
| "What should we build?" / "Where are our gaps?" | Discovery | personas.md, portfolio-types.md |
| "Design a dashboard for X" / "What should this report contain?" | Design | personas.md, quality-indicators.md |
| "How do we manage our reports?" / "Should we retire this?" | Governance | governance.md |

---

## Discovery Workflow

Use when assessing current state or identifying what to build.

### Step 1: Inventory Current State

Gather information about existing BI products:
- What reports/dashboards exist today?
- Who uses each one? How frequently?
- What systems source the data (LIS, LIMS, EHR, instruments)?
- What pain points exist (manual processes, data gaps, stale reports)?

### Step 2: Map Stakeholder Needs

Load `references/personas.md` and work through each relevant persona:
- Which personas are served by current products?
- Which personas have unmet needs?
- What decisions does each persona need to make?

### Step 3: Identify Portfolio Gaps

Load `references/portfolio-types.md` and assess coverage:
- Which archetype categories are well-covered?
- Which are missing or weak?
- Are there redundant products serving the same need?

### Step 4: Prioritize Opportunities

For each gap identified, assess:
- **Impact**: How many personas benefit? How critical are their decisions?
- **Feasibility**: Is data available? What integration effort?
- **Urgency**: Regulatory deadline? Safety concern? Strategic initiative?

Output a prioritized backlog of BI products to build or improve.

---

## Design Workflow

Use when specifying a new dashboard, report, or data product.

### Step 1: Define the Product

Establish scope:
- **Name**: Clear, descriptive title
- **Primary persona(s)**: Who is this for? (Load `references/personas.md` if needed)
- **Archetype**: Which category? (Load `references/portfolio-types.md` if needed)
- **Key questions answered**: What decisions will this enable?

### Step 2: Specify Content

For each visualization or data element:
- **Metric/measure**: What is being shown?
- **Dimensions**: How can it be sliced (time, section, instrument, staff)?
- **Comparisons**: Targets, benchmarks, prior periods?
- **Drill-down paths**: What details should be accessible?

Load `references/quality-indicators.md` for standard KPIs by lab phase and specialty.

### Step 3: Define Interactions

Specify user experience:
- **Filters**: What parameters can users control?
- **Refresh frequency**: Real-time, hourly, daily, on-demand?
- **Alerts/thresholds**: What conditions trigger notifications?
- **Export needs**: PDF, Excel, API access?

### Step 4: Validate with Stakeholders

Before building:
- Review specification with primary persona representatives
- Confirm metrics align with how they actually make decisions
- Identify any missing context or comparisons
- Agree on acceptable data latency and accuracy requirements

---

## Governance Workflow

Use when establishing or improving portfolio management practices.

### Step 1: Establish Ownership Model

Load `references/governance.md` for detailed guidance. Key decisions:
- **Product owner**: Who approves changes and prioritizes enhancements?
- **Data steward**: Who ensures data quality and definitions?
- **Technical owner**: Who maintains the implementation?

### Step 2: Define Review Cadence

Establish recurring review cycles:
- **Usage review** (quarterly): Which products are used? By whom?
- **Quality review** (quarterly): Are metrics accurate? Definitions current?
- **Strategic review** (annual): Does portfolio align with lab priorities?

### Step 3: Set Lifecycle Policies

Define criteria for each lifecycle stage:
- **Promotion**: From pilot to production
- **Enhancement**: When to invest in improvements
- **Deprecation**: When to retire (low usage, superseded, inaccurate)
- **Archival**: How long to retain historical access

### Step 4: Manage Portfolio Health

Ongoing activities:
- Track usage metrics for all products
- Maintain a portfolio registry with ownership and status
- Conduct rationalization exercises to reduce redundancy
- Balance self-service enablement with governed core products

---

## Output Formats

### Portfolio Assessment Summary

When completing discovery, output:

```markdown
# Lab Intelligence Portfolio Assessment

## Current State
- Total products: [N]
- Active/used: [N]
- Orphaned/unused: [N]

## Coverage by Archetype
| Category | Products | Gaps |
|----------|----------|------|
| Operational | ... | ... |
| Quality/Compliance | ... | ... |
| Financial | ... | ... |
| Clinical Decision Support | ... | ... |
| Strategic | ... | ... |

## Coverage by Persona
[Table showing which personas are well-served vs. underserved]

## Recommended Priorities
1. [Priority 1 with rationale]
2. [Priority 2 with rationale]
3. [Priority 3 with rationale]
```

### Product Specification

When completing design, output:

```markdown
# [Product Name] Specification

## Overview
- **Archetype**: [Category]
- **Primary personas**: [List]
- **Key questions answered**: [List]
- **Refresh frequency**: [Frequency]

## Content Specification
| Element | Metric | Dimensions | Target/Benchmark |
|---------|--------|------------|------------------|
| ... | ... | ... | ... |

## Interactions
- **Filters**: [List]
- **Drill-downs**: [List]
- **Alerts**: [Conditions and recipients]

## Data Requirements
- **Sources**: [Systems]
- **Latency**: [Acceptable delay]
- **Quality requirements**: [Accuracy, completeness]

## Governance
- **Product owner**: [Role]
- **Review cycle**: [Frequency]
```

---

## Reference Files

Load these as needed based on the workflow:

- `references/personas.md` - Detailed stakeholder needs by role
- `references/portfolio-types.md` - Dashboard/report archetypes with examples
- `references/governance.md` - Lifecycle management, ownership, review practices
- `references/quality-indicators.md` - Standard KPIs by lab phase and specialty
