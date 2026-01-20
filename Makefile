# =============================================================================
# Makefile for Lab Intelligence Framework
# =============================================================================

.PHONY: all data reports test lint clean help docker-build docker-run \
        data-activity data-quality data-qc data-critical data-incidents \
        data-cost data-utilization data-antibiogram data-executive \
        report-activity report-quality report-qc report-critical report-incidents \
        report-cost report-utilization report-antibiogram report-executive

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SHELL := /bin/bash
R := Rscript
QUARTO := quarto

# Directories
REPORTS_DIR := reports
TAT_DIR := tat-report
TESTS_DIR := tests

# Report subdirectories
REPORT_DIRS := activity-volume quality-scorecard qc-trending critical-values \
               incidents cost-analysis utilization antibiogram executive-scorecard

# -----------------------------------------------------------------------------
# Default target
# -----------------------------------------------------------------------------

all: data reports ## Generate data and render all reports
	@echo "Build complete!"

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

help: ## Show this help message
	@echo "Lab Intelligence Framework - Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make all          # Full build"
	@echo "  make data         # Generate synthetic data only"
	@echo "  make reports      # Render all reports"
	@echo "  make test         # Run test suite"
	@echo "  make clean        # Remove generated files"

# -----------------------------------------------------------------------------
# Data Generation
# -----------------------------------------------------------------------------

data: ## Generate all synthetic data
	@echo "Generating synthetic data..."
	cd $(REPORTS_DIR) && $(R) generate_all_data.R
	@echo "Data generation complete."

data-synthpop: ## Generate data using synthpop (production mode)
	@echo "Generating synthetic data with synthpop..."
	cd $(REPORTS_DIR) && SYNTH_MODE=development $(R) generate_synthetic_data.R
	@echo "Synthpop data generation complete."

# Individual data targets
data-activity: ## Generate activity volume data
	@echo "Generating activity volume data..."
	cd $(REPORTS_DIR) && $(R) -e "source('generate_all_data.R')" 2>/dev/null || \
		$(R) -e "source('generate_all_data.R')"

# -----------------------------------------------------------------------------
# Report Rendering
# -----------------------------------------------------------------------------

reports: ## Render all Quarto reports
	@echo "Rendering all reports..."
	@for dir in $(REPORT_DIRS); do \
		echo "Rendering $$dir..."; \
		$(QUARTO) render $(REPORTS_DIR)/$$dir/$$dir-report.qmd || exit 1; \
	done
	@echo "All reports rendered."

# Individual report targets
report-activity: ## Render activity volume report
	$(QUARTO) render $(REPORTS_DIR)/activity-volume/activity-volume-report.qmd

report-quality: ## Render quality scorecard report
	$(QUARTO) render $(REPORTS_DIR)/quality-scorecard/quality-scorecard-report.qmd

report-qc: ## Render QC trending report
	$(QUARTO) render $(REPORTS_DIR)/qc-trending/qc-trending-report.qmd

report-critical: ## Render critical values report
	$(QUARTO) render $(REPORTS_DIR)/critical-values/critical-values-report.qmd

report-incidents: ## Render incidents report
	$(QUARTO) render $(REPORTS_DIR)/incidents/incidents-report.qmd

report-cost: ## Render cost analysis report
	$(QUARTO) render $(REPORTS_DIR)/cost-analysis/cost-analysis-report.qmd

report-utilization: ## Render utilization report
	$(QUARTO) render $(REPORTS_DIR)/utilization/utilization-report.qmd

report-antibiogram: ## Render antibiogram report
	$(QUARTO) render $(REPORTS_DIR)/antibiogram/antibiogram-report.qmd

report-executive: ## Render executive scorecard report
	$(QUARTO) render $(REPORTS_DIR)/executive-scorecard/executive-scorecard-report.qmd

report-tat: ## Render TAT report (proof-of-concept)
	cd $(TAT_DIR) && $(R) generate_data.R
	$(QUARTO) render $(TAT_DIR)/tat-report.qmd

# -----------------------------------------------------------------------------
# Testing
# -----------------------------------------------------------------------------

test: ## Run test suite
	@echo "Running tests..."
	@if [ -d "$(TESTS_DIR)" ]; then \
		$(R) -e "testthat::test_dir('$(TESTS_DIR)')"; \
	else \
		echo "No tests directory found. Create tests/testthat/ to add tests."; \
	fi

test-coverage: ## Run tests with coverage report
	$(R) -e "covr::package_coverage(path = '.', type = 'tests')"

# -----------------------------------------------------------------------------
# Code Quality
# -----------------------------------------------------------------------------

lint: ## Check code style with lintr
	@echo "Linting R code..."
	$(R) -e "lintr::lint_dir('$(REPORTS_DIR)')"
	@echo "Linting complete."

style: ## Auto-format code with styler
	@echo "Formatting R code..."
	$(R) -e "styler::style_dir('$(REPORTS_DIR)')"
	@echo "Formatting complete."

# -----------------------------------------------------------------------------
# Dependency Management
# -----------------------------------------------------------------------------

deps-install: ## Install R dependencies
	$(R) -e "install.packages(c('dplyr','tidyr','purrr','ggplot2','scales','lubridate','gt','testthat','lintr','styler'))"

deps-snapshot: ## Create renv.lock snapshot
	$(R) -e "renv::snapshot()"

deps-restore: ## Restore dependencies from renv.lock
	$(R) -e "renv::restore()"

# -----------------------------------------------------------------------------
# Docker
# -----------------------------------------------------------------------------

DOCKER_IMAGE := lab-intelligence
DOCKER_TAG := latest

docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-run: ## Run interactive Docker container
	docker run -it --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		/bin/bash

docker-data: docker-build ## Generate data in Docker
	docker run --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		$(R) $(REPORTS_DIR)/generate_all_data.R

docker-reports: docker-build ## Render reports in Docker
	docker run --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		/bin/bash -c "for dir in $(REPORT_DIRS); do \
			$(QUARTO) render $(REPORTS_DIR)/\$$dir/\$$dir-report.qmd; \
		done"

docker-all: docker-build ## Full build in Docker
	docker run --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		make all

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------

clean: ## Remove generated files
	@echo "Cleaning generated files..."
	# Remove rendered HTML
	find $(REPORTS_DIR) -name "*.html" -type f -delete
	find $(TAT_DIR) -name "*.html" -type f -delete 2>/dev/null || true
	# Remove Quarto artifacts
	find . -name "*_files" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".quarto" -type d -exec rm -rf {} + 2>/dev/null || true
	# Remove generated data
	find $(REPORTS_DIR) -path "*/data/*.rds" -type f -delete
	rm -f $(TAT_DIR)/*.rds $(TAT_DIR)/*.csv 2>/dev/null || true
	# Remove R artifacts
	find . -name ".Rhistory" -type f -delete
	find . -name ".RData" -type f -delete
	@echo "Clean complete."

clean-data: ## Remove only generated data files
	find $(REPORTS_DIR) -path "*/data/*.rds" -type f -delete
	rm -f $(TAT_DIR)/*.rds $(TAT_DIR)/*.csv 2>/dev/null || true

clean-reports: ## Remove only rendered reports
	find $(REPORTS_DIR) -name "*.html" -type f -delete
	find $(TAT_DIR) -name "*.html" -type f -delete 2>/dev/null || true

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

validate: ## Validate data and report integrity
	@echo "Validating data files..."
	@for dir in $(REPORT_DIRS); do \
		if [ -d "$(REPORTS_DIR)/$$dir/data" ]; then \
			count=$$(find $(REPORTS_DIR)/$$dir/data -name "*.rds" | wc -l); \
			echo "  $$dir: $$count data file(s)"; \
		else \
			echo "  $$dir: WARNING - no data directory"; \
		fi \
	done
	@echo "Validation complete."

check: lint test validate ## Run all checks (lint, test, validate)
	@echo "All checks passed!"

# -----------------------------------------------------------------------------
# CI/CD Support
# -----------------------------------------------------------------------------

ci: deps-restore data test lint ## CI pipeline target
	@echo "CI pipeline complete."

ci-full: ci reports ## Full CI including report rendering
	@echo "Full CI pipeline complete."
