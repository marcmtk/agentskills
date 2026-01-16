# Lab Quality Indicators and KPIs

Standard metrics for clinical laboratory BI products, organized by lab phase and specialty.

---

## Metrics by Lab Phase

### Pre-Analytical Phase

The period from test ordering through sample preparation for analysis. Accounts for ~70% of laboratory errors.

| Metric | Definition | Target Benchmark | Notes |
|--------|------------|------------------|-------|
| **Specimen rejection rate** | Rejected specimens / Total specimens received | <1% overall, varies by specimen type | Track by rejection reason |
| **Hemolysis rate** | Hemolyzed specimens / Total blood specimens | <2% | Major pre-analytical quality indicator |
| **Sample labeling error rate** | Mislabeled or unlabeled specimens / Total specimens | <0.1% | Patient safety critical |
| **Collection-to-receipt time** | Time from specimen collection to lab receipt | <2 hours for routine | STAT should be faster |
| **Order accuracy rate** | Correct orders / Total orders | >99% | Track common order errors |
| **Missing sample rate** | Samples unable to be located / Total samples | <0.1% | Track by location of loss |
| **Specimen volume adequacy** | Adequate volume specimens / Total specimens | >98% | By specimen type |

### Analytical Phase

The period of actual sample testing and measurement.

| Metric | Definition | Target Benchmark | Notes |
|--------|------------|------------------|-------|
| **QC pass rate** | QC events within limits / Total QC events | >95% | By instrument and analyte |
| **Auto-validation rate** | Results auto-released / Total results | 70-95% depending on test | Higher = more efficient |
| **Rerun rate** | Repeated tests / Total tests | <3% | Track by reason for rerun |
| **Calibration success rate** | Successful calibrations / Total calibration attempts | >98% | By instrument |
| **Instrument uptime** | Operating hours / Scheduled hours | >95% | Track by instrument |
| **Proficiency testing score** | Acceptable PT results / Total PT challenges | 100% target, >80% required | By survey |
| **Coefficient of variation (CV)** | Standard deviation / Mean for QC | Analyte-specific | Compare to manufacturer claims |

### Post-Analytical Phase

The period from result verification through result delivery and interpretation.

| Metric | Definition | Target Benchmark | Notes |
|--------|------------|------------------|-------|
| **Turnaround time (TAT)** | Order to result available | Test-specific targets | See TAT targets below |
| **TAT compliance rate** | Results within target / Total results | >90% | By test category |
| **Critical value notification time** | Result to provider acknowledgment | <30 minutes | Accreditation requirement |
| **Critical value notification rate** | Successfully notified / Total critical values | 100% | Track failures |
| **Report amendment rate** | Amended reports / Total reports | <0.5% | Track by reason |
| **Result correction rate** | Corrected results / Total results | <0.1% | Patient safety metric |
| **Report delivery success** | Reports delivered / Reports generated | >99.5% | Track failures |

---

## TAT Targets by Test Category

| Category | Routine | STAT | Critical Care |
|----------|---------|------|---------------|
| Basic metabolic panel | <4 hours | <1 hour | <30 minutes |
| Complete blood count | <4 hours | <1 hour | <30 minutes |
| Coagulation (PT/PTT) | <4 hours | <1 hour | <30 minutes |
| Urinalysis | <4 hours | <2 hours | <1 hour |
| Blood gases | N/A | <15 minutes | <10 minutes |
| Cardiac markers (troponin) | <2 hours | <1 hour | <30 minutes |
| Blood cultures (time to detection) | <24-48 hours | N/A | N/A |
| Gram stain | <2 hours | <30 minutes | N/A |
| Microbiology ID/susceptibility | <48-72 hours | N/A | N/A |
| Surgical pathology (routine) | <48 hours | N/A | N/A |
| Surgical pathology (STAT/frozen) | N/A | <20 minutes | N/A |
| Cytology (routine) | <48-72 hours | N/A | N/A |
| Molecular (PCR) | <24 hours | <4 hours | N/A |

*Note: Targets vary by institution. Establish local targets based on clinical needs and capabilities.*

---

## Specialty-Specific Metrics

### Clinical Biochemistry

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Delta check failure rate** | Results exceeding delta limits / Total results | Monitor for specimen mix-ups, analytical errors |
| **Critical value frequency** | Critical values / Total results for analyte | Detect shifts in patient population or thresholds |
| **Reflex test completion rate** | Completed reflexes / Triggered reflexes | Ensure protocol compliance |
| **Reference range appropriateness** | Results outside range / Total results | Monitor reference range validity |
| **Add-on test rate** | Add-on requests / Total orders | May indicate ordering inefficiency |

### Hematology

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Manual differential rate** | Manual diffs / Total CBCs | Track automation effectiveness |
| **Smear review rate** | Smears requiring review / Total CBCs | Monitor flagging algorithms |
| **Blood film TAT** | Order to morphology comment | Track manual process efficiency |
| **Flagging efficiency** | True positives / Total flags | Assess analyzer performance |
| **Reticulocyte correlation** | Correlation with hemoglobin trends | Validate clinical utility |

### Clinical Microbiology

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Time to organism ID** | Collection to identification | Track workflow efficiency |
| **Time to susceptibility** | Collection to AST result | Clinical impact metric |
| **Blood culture contamination rate** | Contaminants / Total blood cultures | Pre-analytical quality (<3% target) |
| **Antibiotic susceptibility concordance** | Agreement with reference method | Method validation |
| **Alert organism notification time** | Detection to infection control notification | Public health compliance |
| **Resistance rate by organism** | Resistant isolates / Total isolates | Antibiogram metrics |

### Anatomic Pathology

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Case TAT by complexity** | Accession to sign-out | Stratify by case type |
| **Frozen section TAT** | Receipt to verbal report | OR efficiency impact |
| **Amendment rate** | Amended reports / Total reports | Track by amendment type |
| **Intraoperative consultation concordance** | Frozen-permanent agreement | Quality metric |
| **Immunohistochemistry TAT** | Order to result | Add-on testing efficiency |
| **Second opinion rate** | Cases with consultation / Total cases | Track complexity |
| **Case complexity distribution** | Cases by CPT or RVU category | Workload planning |

### Molecular Diagnostics

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Sequencing QC pass rate** | Runs meeting quality thresholds / Total runs | Analytical quality |
| **Coverage adequacy** | Samples with adequate coverage / Total samples | Ensure interpretability |
| **Variant classification concordance** | Agreement with reference calls | Interpretation quality |
| **Sample failure rate** | Failed samples / Total samples | Pre-analytical and analytical quality |
| **Test utilization by indication** | Tests ordered / Guideline-appropriate orders | Appropriate use monitoring |
| **Interpretation TAT** | Sequencing complete to report | Post-analytical efficiency |

---

## Operational Metrics

### Productivity

| Metric | Definition | Target |
|--------|------------|--------|
| **Tests per FTE** | Total tests / FTE hours | Benchmark varies by test mix |
| **Samples processed per hour** | Samples / Processing time | By section |
| **Accessioning rate** | Samples accessioned / Hour | Track throughput |
| **Verification rate** | Results verified / Hour per tech | Individual productivity |

### Resource Utilization

| Metric | Definition | Target |
|--------|------------|--------|
| **Instrument utilization** | Actual throughput / Rated capacity | 60-80% optimal |
| **Reagent utilization** | Reagent used / Reagent purchased | >90% (minimize waste) |
| **Calibrator usage** | Calibrations per kit | Compare to expected |
| **QC material usage** | QC events per kit | Compare to expected |

### Cost

| Metric | Definition | Target |
|--------|------------|--------|
| **Cost per test** | Total cost / Test volume | Benchmark by test |
| **Labor cost per test** | Labor expense / Test volume | Major cost driver |
| **Reagent cost per test** | Reagent expense / Test volume | Track trends |
| **Send-out cost ratio** | Send-out expense / Total test expense | Opportunity identification |

---

## Composite Indices

### Quality Index
Weighted composite of key quality metrics:
- Specimen rejection rate (weight: 20%)
- Critical value notification time compliance (weight: 25%)
- TAT compliance (weight: 25%)
- Amendment rate (weight: 15%)
- PT performance (weight: 15%)

### Efficiency Index
Weighted composite of operational metrics:
- Auto-validation rate (weight: 30%)
- Instrument utilization (weight: 25%)
- Tests per FTE vs. benchmark (weight: 25%)
- Rerun rate (inverse) (weight: 20%)

---

## Metric Selection Guidance

When designing a BI product, select metrics based on:

| If the audience is... | Prioritize metrics for... |
|----------------------|--------------------------|
| Lab technologists | Individual work queue, QC status, immediate flags |
| Section supervisors | Section TAT, workload distribution, daily quality |
| Lab directors | Quality indicators, compliance, TAT trends |
| Financial directors | Cost per test, utilization, budget variance |
| Hospital executives | High-level quality scores, benchmarks, strategic KPIs |
| Clinical departments | TAT for their tests, critical value performance |

### Avoid Metric Overload

- Start with 5-7 key metrics per dashboard
- Add detail through drill-down, not more top-level metrics
- Every metric should drive a decision - if no action would result, reconsider including it
