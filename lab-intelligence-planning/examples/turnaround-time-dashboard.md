# Turnaround Time Dashboard Specification

Example product specification created using the Lab Intelligence Planning skill.

## Overview
- **Archetype**: Operational / Quality
- **Primary personas**: Section Heads (MD and tech)
- **Secondary personas**: Department leadership, Lab techs, Clinical Department Heads
- **Key questions answered**:
  - What is our TAT performance by segment?
  - Are we meeting targets (Segment 2)?
  - Where is time being spent?
  - How do we trend over time?
  - Are there TAT anomalies?
- **Refresh frequency**: Weekly

## TAT Segments
| Segment | Definition | Comparison |
|---------|------------|------------|
| 1: Pre-lab | Requisition → Received | vs. same period last year |
| 2: In-lab | Received → Released | vs. target |
| 3: Post-lab | Released → Acknowledged | vs. same period last year |
| 4: End-to-end lab | Requisition → Released | vs. same period last year |
| 5: Total clinical | Requisition → Acknowledged | vs. same period last year |

## Content Specification
| Element | Metrics | Dimensions |
|---------|---------|------------|
| Segment TAT | Percentiles: 50, 80, 90, 95, 99 | Section, Test Category, Test |
| Target compliance (Segment 2) | % samples within target | Section, Test Category, Test |
| Trend | Percentiles over time | Weekly, 12+ months |
| Anomaly flags | Deviation from expected | All drill-down levels |

## Drill-Down Hierarchy
| Level | Scope |
|-------|-------|
| Department | KDA (total) |
| Section | KBA, KMA, KPA |
| Test Category | KMA: Culture, PCR, Serology; KBA/KPA: TBD by Section Heads |
| Individual Test | Specific tests |

## Visualization Design

### Layout
```
┌────────────────────────────────────────────────────────────┐
│  PROCESS FLOW - Median TAT by Segment (click to select)    │
│  Req ──[S1]──▶ Rec ──[S2]──▶ Rel ──[S3]──▶ Ack            │
│        12m          45m            8m                      │
│                      ▲                                     │
│                [selected]                                  │
│                                                            │
│  End-to-end (S4): 57m | Total clinical (S5): 65m          │
├────────────────────────────────────────────────────────────┤
│  PERCENTILE DISTRIBUTION - Selected Segment                │
│  ┌─────┬─────┬─────┬─────┬─────┐                          │
│  │ P50 │ P80 │ P90 │ P95 │ P99 │                          │
│  │ 32m │ 51m │ 68m │ 89m │142m │                          │
│  └─────┴─────┴─────┴─────┴─────┘                          │
│  Target: 30m | Within target: 67%                          │
├────────────────────────────────────────────────────────────┤
│  TREND OVER TIME - Selected Segment                        │
│                                                            │
│  ─── P90 actual                                            │
│  ─ ─ Target (or same period last year)                     │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Interaction Flow
1. User views process flow at current drill-down level
2. Click segment → percentile and trend panels update
3. Click drill-down (section/category/test) → all panels update
4. Anomalies highlighted in process flow and trend

## Interactions
- **Default view**: Current week, KDA level, Segment 2 selected
- **Filters**: Time range, Section, Test Category
- **Drill-downs**: KDA → Section → Test Category → Individual Test
- **Segment selection**: Click in process flow
- **Anomaly display**: Visual highlighting in process flow and trend
- **Anomaly alerts**: Email/notification to configurable recipients
- **Export**: PDF summary, Excel data extract

## Anomaly Detection
- **Method**: Robust statistical thresholds (same as Activity Volume)
- **Granularity**: All levels (department, section, category, test) × all segments
- **Triggers**: Percentile significantly exceeds baseline
- **Notification**: Configurable recipient list

## Data Requirements
- **Sources**: 3 LIMS (KBA, KMA, KPA systems)
- **Key timestamps**:
  - Requisition datetime
  - Sample received datetime
  - Result released datetime
  - Clinician acknowledgment datetime (if available)
- **Integration**: Weekly extract/aggregation from each LIMS
- **Historical data**: Minimum 13 months for same-period comparison

## Governance
- **Product owner**: Section Head (MD or tech lead)
- **Data steward**: TBD
- **Technical owner**: Data science team
- **Review cycle**: Quarterly usage and accuracy review

## Stakeholder Validation Required
| Stakeholder | Input Needed |
|-------------|--------------|
| KBA Section Head | Confirm test categories, validate Segment 2 targets |
| KMA Section Head | Confirm test categories, validate Segment 2 targets |
| KPA Section Head | Confirm test categories, validate Segment 2 targets |
| Medical Director | Confirm anomaly thresholds meet oversight needs |
| Clinical Dept Heads | Validate Segment 3 (post-lab) is useful for their needs |

## Relationship to Activity Volume Dashboard
- Same drill-down hierarchy (KDA → Section → Category → Test)
- Same refresh cadence (weekly)
- Same comparison approach (same period last year, except Segment 2 vs. target)
- Same anomaly detection method and notification system
- Consider: Combined view or linked navigation between dashboards

## Future Enhancements
- Real-time TAT view for operational management
- STAT vs. routine TAT breakdown
- TAT by ordering department/clinician
- Correlation with volume (does high volume increase TAT?)
