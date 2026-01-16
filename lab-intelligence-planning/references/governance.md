# Lab Intelligence Governance

Lifecycle management, ownership models, and review practices for lab BI portfolios.

---

## Governance Principles

1. **Every product has an owner** - No orphaned dashboards or reports
2. **Usage informs investment** - Build what people use, retire what they don't
3. **Quality over quantity** - Fewer excellent products beat many mediocre ones
4. **Balance autonomy and consistency** - Enable self-service within guardrails
5. **Continuous improvement** - Regular review cycles, not set-and-forget

---

## Ownership Model

### Three Roles per Product

| Role | Responsibility | Typical Assignment |
|------|----------------|-------------------|
| **Product Owner** | Defines requirements, prioritizes enhancements, approves changes | Lab manager, section head, or lead user from primary persona |
| **Data Steward** | Ensures data quality, maintains definitions, validates accuracy | Quality manager, senior tech, or specialty MD |
| **Technical Owner** | Implements, maintains, troubleshoots, ensures performance | Data science team member, IT analyst |

### Assignment Guidelines

- **Product Owner** should be from the primary consumer group, not IT
- **Data Steward** should understand the clinical/operational context of metrics
- **Technical Owner** should have access to underlying systems and tools
- One person may hold multiple roles for simple products
- Complex products may have co-owners (e.g., joint clinical and operational ownership)

### Escalation Path

When issues arise:
1. Technical issues → Technical Owner
2. Data quality concerns → Data Steward
3. Requirement changes → Product Owner
4. Cross-product conflicts → Governance Committee (if established)

---

## Lifecycle Stages

### Stage 1: Proposal
- **Entry**: Need identified through discovery or user request
- **Activities**: Document requirements, identify personas, estimate effort
- **Exit criteria**: Approved by relevant stakeholders, resourced for development
- **Artifacts**: Product specification (see Design Workflow output format)

### Stage 2: Development
- **Entry**: Approved proposal with assigned Technical Owner
- **Activities**: Build product, integrate data sources, implement visualizations
- **Exit criteria**: Functional product meeting specifications
- **Artifacts**: Working product in development/test environment

### Stage 3: Pilot
- **Entry**: Functional product ready for limited testing
- **Activities**: Deploy to pilot users, gather feedback, iterate
- **Duration**: 2-8 weeks depending on complexity
- **Exit criteria**: Pilot users validate product meets needs, data accuracy confirmed
- **Artifacts**: Pilot feedback summary, data quality validation

### Stage 4: Production
- **Entry**: Successful pilot, Data Steward sign-off on accuracy
- **Activities**: Full deployment, user training, documentation
- **Exit criteria**: Product accessible to all intended users
- **Artifacts**: User guide (if needed), training materials

### Stage 5: Maintenance
- **Entry**: Production deployment complete
- **Activities**: Monitor usage, fix issues, implement minor enhancements
- **Ongoing**: Regular review cycles (see below)
- **Exit criteria**: Product remains valuable and used, OR triggers deprecation

### Stage 6: Deprecation
- **Entry**: Product identified for retirement (see deprecation criteria)
- **Activities**: Notify users, provide alternatives, archive data
- **Duration**: Minimum 30 days notice for established products
- **Exit criteria**: Product decommissioned, access removed
- **Artifacts**: Deprecation notice, archive location (if applicable)

---

## Review Cadences

### Usage Review (Quarterly)

**Purpose**: Understand who uses what, and how much

**Metrics to track**:
- Unique users per product
- Sessions/views per product
- Frequency of use (daily, weekly, monthly)
- Features used (filters applied, drill-downs, exports)

**Actions**:
- Flag products with declining usage for investigation
- Identify power users for feedback
- Note products never accessed after deployment

### Quality Review (Quarterly)

**Purpose**: Ensure products remain accurate and relevant

**Questions to address**:
- Do metrics still calculate correctly after system changes?
- Are definitions still aligned with how users interpret them?
- Have underlying data sources changed?
- Are there known data quality issues affecting products?

**Actions**:
- Validate key metrics against source systems
- Update definitions documentation if needed
- Fix accuracy issues immediately

### Strategic Review (Annual)

**Purpose**: Align portfolio with lab priorities

**Questions to address**:
- Does portfolio coverage match current lab strategy?
- Are emerging needs (new service lines, regulations) addressed?
- Is there redundancy that should be consolidated?
- What should be prioritized for the coming year?

**Actions**:
- Update portfolio roadmap
- Identify products for deprecation
- Allocate resources for new development

---

## Deprecation Criteria

Consider deprecating a product when:

| Criterion | Threshold | Investigation Action |
|-----------|-----------|---------------------|
| **Low usage** | <5 users in 90 days | Confirm no regulatory/compliance requirement |
| **Superseded** | Newer product covers same need | Verify new product is adequate replacement |
| **Inaccurate** | Known data quality issues unfixable | Assess impact of removing vs. living with issues |
| **Orphaned** | No Product Owner willing to maintain | Seek new owner or confirm deprecation |
| **Obsolete** | Business process it supports no longer exists | Confirm with former users |

### Deprecation Process

1. **Identify**: Flag product meeting deprecation criteria
2. **Investigate**: Confirm no hidden users or requirements
3. **Notify**: Inform all users with deprecation timeline and alternatives
4. **Transition**: Help users migrate to alternatives if available
5. **Archive**: Preserve historical data/screenshots if needed for audit
6. **Decommission**: Remove access, reclaim resources

---

## Portfolio Registry

Maintain a central registry of all BI products:

| Field | Purpose |
|-------|---------|
| Product name | Unique identifier |
| Description | Brief purpose statement |
| Archetype | Category (Operational, Quality, Financial, Clinical, Strategic) |
| Primary personas | Who it serves |
| Product Owner | Accountability |
| Data Steward | Data quality responsibility |
| Technical Owner | Maintenance responsibility |
| Status | Lifecycle stage |
| Launch date | When deployed to production |
| Last review date | Most recent quality/usage review |
| Usage tier | High/Medium/Low based on quarterly metrics |
| Data sources | Systems feeding the product |
| Access location | Where users find it |

### Registry Maintenance

- Update status changes immediately
- Review ownership assignments when staff change
- Refresh usage tier quarterly
- Archive deprecated products (don't delete from registry)

---

## Self-Service vs. Governed Products

### Governed Products (Core Portfolio)
- Centrally defined and maintained
- Consistent definitions across lab
- Higher investment in accuracy and design
- Formal ownership and review cycles
- Examples: Quality scorecards, executive dashboards, compliance reports

### Self-Service Products (Extended Portfolio)
- Created by users with available tools
- May use definitions differently
- Lower maintenance investment
- Informal or no ownership structure
- Examples: Ad-hoc analyses, personal productivity views, exploratory dashboards

### Guardrails for Self-Service

Enable self-service while preventing chaos:

1. **Certified data sources**: Provide curated, documented data sets
2. **Standard definitions**: Publish official metric calculations
3. **Naming conventions**: Distinguish personal vs. shared products
4. **Promotion path**: Process to elevate valuable self-service products to governed status
5. **No enforcement of governed metrics**: Self-service can explore, but governed products are authoritative

---

## Governance Committee (Optional)

For larger labs or complex portfolios, establish a governance committee:

### Composition
- Medical Director or delegate (clinical perspective)
- Technical/Financial Director or delegate (operational perspective)
- Data Science/IT lead (technical perspective)
- Rotating section head representation
- Quality manager (data quality perspective)

### Responsibilities
- Prioritize development backlog
- Resolve cross-product conflicts
- Approve major changes to governed products
- Set portfolio-wide standards and policies
- Conduct annual strategic review

### Meeting Cadence
- Monthly for operational decisions
- Quarterly for portfolio reviews
- Ad-hoc for urgent issues

---

## Common Governance Failures

| Failure | Symptom | Prevention |
|---------|---------|------------|
| **Ownership vacuum** | Nobody knows who maintains products | Require ownership assignment before production |
| **Review neglect** | Products drift out of accuracy | Calendar review cycles, track completion |
| **Deprecation avoidance** | Portfolio grows without pruning | Set usage thresholds, enforce review |
| **Over-governance** | Simple changes require excessive approval | Right-size process to product complexity |
| **Shadow portfolios** | Untracked products proliferate | Provide good self-service, periodic discovery |
