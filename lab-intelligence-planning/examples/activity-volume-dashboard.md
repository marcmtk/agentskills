# Activity Volume Dashboard Specification

Example product specification created using the Lab Intelligence Planning skill.

## Overview
- **Archetype**: Financial / Strategic
- **Primary personas**: Technical/Financial Director, Section Heads
- **Secondary personas**: Medical Director, Hospital executives, Clinical Department Heads
- **Key questions answered**:
  - How many tests are we performing?
  - How is volume trending vs. last year?
  - Where is volume concentrated?
  - Are there volume anomalies? (high-value for leadership)
- **Refresh frequency**: Weekly

## Content Specification
| Element | Metric | Dimensions | Comparison |
|---------|--------|------------|------------|
| Total volume | Test count | Week | vs. same week last year |
| Volume by section | Test count | KBA, KMA, KPA | vs. same week last year |
| Volume trend | Test count over time | Weekly, 12+ months | Overlay prior year |
| Anomaly flags | Deviation from expected | All drill-down levels | Statistical threshold |

## Drill-Down Hierarchy
| Level | Scope | Anomaly Detection |
|-------|-------|-------------------|
| Department | KDA (total) | Yes |
| Section | KBA, KMA, KPA | Yes |
| Test Category | KMA: Culture, PCR, Serology; KBA/KPA: TBD by Section Heads | Yes |
| Individual Test | Specific tests | Yes (primary signal source) |

## Interactions
- **Default view**: Current week, KDA total, vs. same week last year
- **Filters**: Time range, Section, Test Category
- **Drill-downs**: Department → Section → Test Category → Individual Test
- **Anomaly display**: Visual highlighting at all levels
- **Anomaly alerts**: Email/notification to configurable recipient list
- **Export**: PDF summary, Excel data extract

## Data Requirements
- **Sources**: 3 LIMS (KBA, KMA, KPA systems)
- **Integration**: Weekly extract/aggregation from each LIMS
- **Latency**: Weekly acceptable
- **Key fields**: Test code, test name, section, category, count, date
- **Quality requirements**:
  - Complete test counts across all LIMS
  - Consistent test-to-category mapping
  - Historical data for same-period-last-year comparison (minimum 13 months)

## Anomaly Detection
- **Method**: Robust statistical thresholds (minimize false positives)
- **Granularity**: All levels (department, section, category, individual test)
- **Expected behavior**: Most positives at individual test level
- **Notification**: Configurable recipient list per section or overall

## Governance
- **Product owner**: Technical/Financial Director (or delegate)
- **Data steward**: TBD (someone with cross-LIMS knowledge)
- **Technical owner**: Data science team
- **Review cycle**: Quarterly usage and accuracy review

## Stakeholder Validation Required
| Stakeholder | Input Needed |
|-------------|--------------|
| Technical/Financial Director | Confirm this answers cost center visibility needs |
| KBA Section Head | Define test categories for Biochemistry |
| KMA Section Head | Confirm Culture/PCR/Serology grouping |
| KPA Section Head | Define test categories for Clinical Pathology |
| Medical Director | Confirm anomaly alerting meets oversight needs |

## Future Enhancements
- Cost layer overlay (Priority 2)
- KMA seasonality adjustment
- Drill-down to ordering clinician/department
