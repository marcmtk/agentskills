# Lab Intelligence Personas

Stakeholders who consume lab BI products, organized by role and information needs.

---

## Inside the Lab - Clinical Leadership

### Lab Specialty MDs

Physicians with specialty training who provide clinical oversight and interpretation.

#### Pathologists (Anatomic/Clinical)
- **Decisions**: Case signout, quality of diagnostic processes, peer review findings
- **Key metrics**: Case TAT, amendment rates, correlation with clinical outcomes, workload distribution
- **Report needs**: Pending case queues, QA dashboards, subspecialty volume trends
- **Frequency**: Daily for operational, weekly/monthly for quality review

#### Clinical Chemists
- **Decisions**: Method validation, reference range review, test utilization appropriateness
- **Key metrics**: Assay performance (CV, bias), delta checks triggered, critical value patterns
- **Report needs**: QC trend analysis, method comparison studies, utilization outliers
- **Frequency**: Daily QC review, periodic deep-dive analytics

#### Clinical Microbiologists
- **Decisions**: Organism identification confirmation, susceptibility interpretation, outbreak assessment
- **Key metrics**: Time to identification, resistance rates, alert organism frequency
- **Report needs**: Antibiograms, resistance trends, unusual organism alerts
- **Frequency**: Daily workflow, periodic epidemiology summaries

#### Molecular Pathologists
- **Decisions**: Variant interpretation, assay performance assessment, test selection guidance
- **Key metrics**: Sequencing QC (coverage, quality scores), variant classification concordance, TAT
- **Report needs**: Run quality summaries, interpretation turnaround, test utilization by indication
- **Frequency**: Per-run QC, weekly performance summaries

### Medical Lab Director
- **Decisions**: Clinical quality priorities, patient safety initiatives, accreditation readiness, staff competency
- **Key metrics**: Critical value notification compliance, patient outcome correlations, error rates, TAT percentiles
- **Report needs**: Quality indicator dashboards, accreditation scorecards, incident trending
- **Frequency**: Weekly operational review, monthly quality meetings, annual accreditation prep

---

## Inside the Lab - Operational Leadership

### Technical/Financial Director
- **Decisions**: Budget allocation, staffing levels, instrument procurement, process optimization
- **Key metrics**: Cost per test, labor productivity, instrument utilization, reagent waste, budget variance
- **Report needs**: Financial dashboards, staffing models, instrument ROI analysis, vendor comparisons
- **Frequency**: Monthly financial review, quarterly planning, annual budgeting

### Section Heads (Operational)
*Distinct from MD specialty leads; focused on day-to-day management*

- **Decisions**: Shift scheduling, workload balancing, equipment maintenance timing, staff assignments
- **Key metrics**: Section-specific TAT, samples per FTE, equipment downtime, pending workload
- **Report needs**: Section performance dashboards, staff productivity reports, maintenance schedules
- **Frequency**: Daily operational, weekly section meetings

---

## Inside the Lab - Frontline

### Lab Tech Heads / Supervisors
- **Decisions**: Real-time workflow adjustments, staff coaching, immediate problem resolution
- **Key metrics**: Queue depths, individual tech productivity, error rates by person, training completion
- **Report needs**: Shift dashboards, individual performance summaries, competency tracking
- **Frequency**: Real-time monitoring, daily shift summaries

### Lab Technologists/Technicians
- **Decisions**: Sample prioritization, instrument troubleshooting, result verification
- **Key metrics**: Personal queue, pending samples, QC status, instrument alerts
- **Report needs**: Personal worklist, instrument status displays, QC flags requiring action
- **Frequency**: Continuous/real-time during shifts

### Secretaries and Logistics Staff
- **Decisions**: Sample registration prioritization, courier coordination, result delivery follow-up
- **Key metrics**: Registration backlog, courier arrival times, undelivered results, missing samples
- **Report needs**: Registration queue, courier schedules, pending order lists, result delivery status
- **Frequency**: Continuous during shifts

---

## Lab-Adjacent Stakeholders

### Infection Prevention Team
- **Decisions**: Outbreak investigation, isolation precautions, antibiotic stewardship recommendations
- **Key metrics**: Alert organism counts, resistance trends, HAI markers, cluster detection signals
- **Report needs**: Surveillance dashboards, antibiograms, outbreak alerts, trend reports
- **Frequency**: Daily surveillance, immediate alerts for clusters, monthly/quarterly summaries

### Hospital Executives
- **Decisions**: Strategic investment, service line development, performance benchmarking
- **Key metrics**: Lab contribution to hospital quality metrics, cost per case, patient throughput impact
- **Report needs**: Executive scorecards, benchmark comparisons, strategic KPI trends
- **Frequency**: Monthly executive review, quarterly board reports

### Clinical Department Heads
- **Decisions**: Clinical workflow optimization, test ordering patterns, patient care protocols
- **Key metrics**: TAT for their patient population, test availability, critical result notification times
- **Report needs**: Department-specific service reports, utilization summaries, TAT by test type
- **Frequency**: Monthly service reviews, ad-hoc for specific concerns

---

## Persona Selection Guide

When designing a BI product, identify primary and secondary personas:

| If the product is about... | Primary personas | Secondary personas |
|---------------------------|------------------|-------------------|
| Real-time workflow | Lab Techs, Tech Heads | Section Heads |
| Quality/compliance | Medical Director, Specialty MDs | Section Heads, Executives |
| Financial performance | Technical/Financial Director | Executives, Section Heads |
| Infection surveillance | Infection Prevention, Microbiologists | Medical Director, Clinical Depts |
| Strategic planning | Medical Director, Executives | Technical Director |
| Test utilization | Specialty MDs, Clinical Depts | Medical Director, Financial Director |

---

## Common Pitfalls

- **Building for "the lab"** without specific personas leads to cluttered, unfocused products
- **Assuming all personas want the same granularity** - executives need summaries, techs need details
- **Forgetting the clinical context** - lab MDs need different views than operational managers
- **Ignoring lab-adjacent consumers** - infection prevention and clinical departments are key stakeholders
