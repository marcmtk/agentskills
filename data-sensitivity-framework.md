# Data Science Team: Data Sensitivity and AI Development Framework

Operating model for enabling AI-assisted development while protecting patient data confidentiality.

## Principles

1. **AI never sees patient data** - All AI-assisted development uses synthetic data only
2. **Humans control the boundaries** - Human-written code bridges sensitive and non-sensitive layers
3. **Accept pragmatic trade-offs** - Some development friction (Layer 5 failures) is acceptable for data protection
4. **Clear access rules** - No ambiguity about what AI tools can access

---

## Layered Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 1: Production Databases                                   │
│ Access: Read-only (humans), No AI-generated code                │
│ Contains: Raw patient data, operational systems                 │
└─────────────────────────────────────────────────────────────────┘
                            ↓ ETL (human-written)
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 2: Analytics Data Store                                   │
│ Access: Read/write (humans), No AI access                       │
│ Contains: Aggregated, mostly de-identified data                 │
│ Note: Still sensitive due to some small-n observations          │
└─────────────────────────────────────────────────────────────────┘
              ↓                                    ↑
     Synthpop model training              Final testing (human)
        (human-supervised)                         │
              ↓                                    │
┌────────────────────────────┐    ┌──────────────────────────────┐
│ LAYER 3: Synthetic Data    │    │ LAYER 5: Staging             │
│ Access: AI-readable        │    │ Access: Humans only          │
│ Contains: Synthpop-        │    │ Data source: Layer 2         │
│ generated data matching    │    │ Purpose: Validate code       │
│ Layer 2 structure          │    │ against real data before     │
│ Sensitivity: Non-sensitive │    │ production deployment        │
└────────────────────────────┘    └──────────────────────────────┘
              ↓                                    ↑
┌────────────────────────────┐                    │
│ LAYER 4: Development       │────────────────────┘
│ Access: Humans + AI        │   Code promotion (human review)
│ Data source: Layer 3 only  │
│ Purpose: Write and test    │
│ code with AI assistance    │
└────────────────────────────┘
                                  ┌──────────────────────────────┐
                                  │ LAYER 6: Production          │
                                  │ Access: Humans only          │
                                  │ Data source: Layer 2         │
                                  │ Purpose: Live reports and    │
                                  │ dashboards                   │
                                  └──────────────────────────────┘
```

---

## Layer Specifications

### Layer 1: Production Databases

| Attribute | Value |
|-----------|-------|
| Contents | Raw patient data, LIS/LIMS operational data |
| Human access | Read-only |
| AI access | None - no AI-generated code ever executes here |
| Purpose | Source of truth for clinical operations |

### Layer 2: Analytics Data Store

| Attribute | Value |
|-----------|-------|
| Contents | Aggregated data, mostly de-identified, some small-n observations |
| Sensitivity | Sensitive (small-n can be re-identifiable) |
| Human access | Read and write |
| AI access | None |
| Purpose | Data foundation for analytics, source for synthetic data generation |

### Layer 3: Synthetic Data

| Attribute | Value |
|-----------|-------|
| Contents | Synthpop-generated data matching Layer 2 structure and distributions |
| Sensitivity | Non-sensitive (see rationale below) |
| Human access | Read and write |
| AI access | Read |
| Purpose | Enable AI-assisted development without exposing real data |

### Layer 4: Development Environment

| Attribute | Value |
|-----------|-------|
| Contents | Code, reports, dashboards in development |
| Data access | Layer 3 only |
| Human access | Read and write |
| AI access | Read and write |
| Purpose | AI-assisted code and report development |
| Enforcement | Network segmentation - git repository never connects to real data servers |

### Layer 5: Staging Environment

| Attribute | Value |
|-----------|-------|
| Contents | Code promoted from Layer 4 |
| Data access | Layer 2 |
| Human access | Full access |
| AI access | None |
| Purpose | Validate code against real data before production |

### Layer 6: Production Environment

| Attribute | Value |
|-----------|-------|
| Contents | Deployed reports and dashboards |
| Data access | Layer 2 |
| Human access | Full access |
| AI access | None |
| Purpose | Serve live reports and dashboards to end users |

---

## Synthetic Data Generation

### Approach: Synthpop (R)

We use the Synthpop package to generate synthetic data that preserves the statistical properties and correlations of Layer 2 data.

### Why Synthpop?

- Preserves correlations between variables (unlike simple random generation)
- Handles mixed data types (numeric, categorical, dates)
- Well-documented, academically validated
- Fits our R-capable team

### Why Layer 3 is Non-Sensitive

Given that Layer 2 contains aggregated, mostly de-identified data:

1. **Low memorization risk** - Aggregated data has no individual patient records to memorize
2. **Common patterns** - Lab operational data (volumes, TAT, etc.) consists of common patterns, not unique identifiable combinations
3. **No patient journeys** - We are not synthesizing sequences of patient events

This assessment may be revisited if Layer 2 contents change or if new use cases emerge.

### Synthetic Data Workflow

```
1. Human queries Layer 2 to extract data for synthesis
2. Human runs Synthpop training (supervised, in controlled environment)
3. Human reviews synthetic output for obvious anomalies
4. Synthetic data placed in Layer 3
5. AI and humans use Layer 3 data for development
6. Repeat periodically as Layer 2 evolves
```

### Handling Layer 5 Failures

When code developed against synthetic data fails against real data:

1. Human diagnoses the discrepancy
2. Human updates Synthpop parameters or adds rules to better capture the pattern
3. Regenerate Layer 3 data
4. Fix code and re-test
5. Document the failure pattern to improve future synthesis

This feedback loop improves synthetic data fidelity over time.

---

## Access Control Summary

| Layer | Humans | AI Tools | Contains Real Patient Data |
|-------|--------|----------|---------------------------|
| 1 - Production DB | Read | None | Yes |
| 2 - Analytics | Read/Write | None | Aggregated, some sensitive |
| 3 - Synthetic | Read/Write | Read | No |
| 4 - Development | Read/Write | Read/Write | No |
| 5 - Staging | Full | None | Accesses Layer 2 |
| 6 - Production | Full | None | Accesses Layer 2 |

---

## Enforcement Mechanisms

### Network Segmentation

- Layer 4 (Development) exists in an isolated environment
- Git repository in Layer 4 cannot connect to servers hosting Layer 1 or 2
- Code promotion from Layer 4 → Layer 5 requires explicit human action (PR/review)

### Code Review

- All code moving from Layer 4 to Layer 5 undergoes human review
- Review checks for:
  - Hardcoded references to production systems
  - Appropriate data access patterns
  - No embedded sensitive data

---

## Future Considerations

### Differential Privacy

If regulatory requirements increase or if Layer 2 evolves to contain more sensitive data, consider adding differential privacy to the synthesis process:

- Provides formal, mathematical privacy guarantees
- Trade-off: Some loss of data fidelity
- Tools: Smartnoise, MOSTLY AI, Gretel.ai

### Monitoring

Track over time:

- Layer 5 failure rate (indicator of synthetic data fidelity)
- Time spent maintaining Synthpop configuration
- New data patterns requiring synthesis updates

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-16 | Initial framework documented |
