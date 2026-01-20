# =============================================================================
# Lab Intelligence Framework - Environment Setup
# =============================================================================
#
# Run this script to set up your R environment for development.
# Usage: Rscript setup.R
#
# =============================================================================

cat("=== Lab Intelligence Framework Setup ===\n\n")

# Check R version
r_version <- getRversion()
cat("R version:", as.character(r_version), "\n")

if (r_version < "4.3.0") {
  warning("R version 4.3.0+ recommended for native pipe support")
}

# -----------------------------------------------------------------------------
# Option 1: Use renv (Recommended for reproducibility)
# -----------------------------------------------------------------------------

use_renv <- function() {
  cat("\n--- Setting up renv ---\n")

  if (!requireNamespace("renv", quietly = TRUE)) {
    cat("Installing renv...\n")
    install.packages("renv")
  }

  # Initialize renv if not already done
  if (!file.exists("renv.lock")) {
    cat("Initializing renv project...\n")
    renv::init(bare = TRUE)

    # Install dependencies from DESCRIPTION
    cat("Installing dependencies from DESCRIPTION...\n")
    renv::install()

    # Create snapshot
    cat("Creating renv.lock snapshot...\n")
    renv::snapshot()

    cat("renv setup complete!\n")
  } else {
    cat("renv.lock exists. Restoring environment...\n")
    renv::restore()
    cat("Environment restored!\n")
  }
}

# -----------------------------------------------------------------------------
# Option 2: Direct install (Faster, less reproducible)
# -----------------------------------------------------------------------------

direct_install <- function() {
  cat("\n--- Direct package installation ---\n")

  # Core packages
  core_packages <- c(
    "dplyr",
    "tidyr",
    "purrr",
    "ggplot2",
    "scales",
    "lubridate",
    "gt"
  )

  # Development packages
  dev_packages <- c(
    "testthat",
    "lintr",
    "styler"
  )

  # Optional packages
  optional_packages <- c(
    "synthpop",
    "arrow"
  )

  install_if_missing <- function(packages, type = "core") {
    for (pkg in packages) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        cat(sprintf("Installing %s package: %s\n", type, pkg))
        tryCatch(
          install.packages(pkg),
          error = function(e) {
            warning(sprintf("Failed to install %s: %s", pkg, e$message))
          }
        )
      } else {
        cat(sprintf("  %s: already installed\n", pkg))
      }
    }
  }

  cat("\nInstalling core packages...\n")
  install_if_missing(core_packages, "core")

  cat("\nInstalling development packages...\n")
  install_if_missing(dev_packages, "dev")

  cat("\nInstalling optional packages (may fail on some systems)...\n")
  install_if_missing(optional_packages, "optional")

  cat("\nDirect installation complete!\n")
}

# -----------------------------------------------------------------------------
# Verify Quarto
# -----------------------------------------------------------------------------

check_quarto <- function() {
  cat("\n--- Checking Quarto ---\n")

  quarto_version <- tryCatch(
    system2("quarto", "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) NULL
  )

  if (is.null(quarto_version) || length(quarto_version) == 0) {
    warning("Quarto not found. Install from https://quarto.org/docs/get-started/")
    return(FALSE)
  }

  cat("Quarto version:", quarto_version, "\n")
  return(TRUE)
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

cat("\nSelect installation method:\n")
cat("  1. Use renv (recommended for reproducibility)\n")
cat("  2. Direct install (faster)\n")
cat("\n")

# Auto-detect if running non-interactively
if (!interactive()) {
  cat("Running non-interactively, using direct install...\n")
  direct_install()
} else {
  choice <- readline("Enter choice (1 or 2): ")

  if (choice == "1") {
    use_renv()
  } else {
    direct_install()
  }
}

check_quarto()

# -----------------------------------------------------------------------------
# Final verification
# -----------------------------------------------------------------------------

cat("\n--- Verification ---\n")

verify_packages <- c("dplyr", "ggplot2", "gt", "testthat")
all_ok <- TRUE

for (pkg in verify_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("  ✓ %s\n", pkg))
  } else {
    cat(sprintf("  ✗ %s (missing)\n", pkg))
    all_ok <- FALSE
  }
}

if (all_ok) {
  cat("\n=== Setup complete! ===\n")
  cat("\nNext steps:\n")
  cat("  1. Generate data:    make data\n")
  cat("  2. Run tests:        make test\n")
  cat("  3. Render reports:   make reports\n")
} else {
  cat("\n=== Setup incomplete ===\n")
  cat("Some packages failed to install. Check errors above.\n")
}
