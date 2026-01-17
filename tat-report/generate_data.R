# Generate mock TAT data for testing
# Categories: 101 (Culture), 221 (PCR), 218 (POCT PCR)

library(dplyr)
library(lubridate)

set.seed(42)

# Configuration
start_date <- as.POSIXct("2025-01-06 08:00:00")  # Monday week 2
n_weeks <- 3

# Samples per week by category
samples_per_week <- list(
  "101" = 100,  # Culture - slowest
  "221" = 20,   # PCR - medium
  "218" = 5     # POCT PCR - fastest
)

# TAT parameters (in minutes) by category
# Pre-lab: afsendt -> modtaget (similar for all)
# In-lab: modtaget -> besvaret (varies by category)
# Post-lab: besvaret -> kvitteret (similar for all)

tat_params <- list(
  "101" = list(
    prelab_mean = 45, prelab_sd = 20,      # ~45 min transport
    inlab_mean = 48 * 60, inlab_sd = 12 * 60,  # ~48h culture, sd 12h
    postlab_mean = 120, postlab_sd = 60    # ~2h to acknowledge
  ),
  "221" = list(
    prelab_mean = 45, prelab_sd = 20,
    inlab_mean = 8 * 60, inlab_sd = 2 * 60,    # ~8h PCR, sd 2h
    postlab_mean = 120, postlab_sd = 60
  ),
  "218" = list(
    prelab_mean = 10, prelab_sd = 5,       # POCT is near patient
    inlab_mean = 45, inlab_sd = 15,        # ~45 min POCT
    postlab_mean = 30, postlab_sd = 15     # Quick acknowledgment
  )
)

generate_samples <- function(category, n, week_start, proevenr_start) {
  params <- tat_params[[category]]

  # Distribute samples across the week (working hours 7-22, all days)
  afsendt <- week_start +
    runif(n, 0, 7 * 24 * 60) * 60 +  # Random minute in week
    sample(0:15, n, replace = TRUE) * 60  # Add some hour variation

  # Pre-lab: afsendt -> modtaget
  prelab_minutes <- pmax(5, rnorm(n, params$prelab_mean, params$prelab_sd))
  modtaget <- afsendt + prelab_minutes * 60


  # In-lab: modtaget -> besvaret
  inlab_minutes <- pmax(10, rnorm(n, params$inlab_mean, params$inlab_sd))
  besvaret <- modtaget + inlab_minutes * 60

  # Post-lab: besvaret -> kvitteret
  postlab_minutes <- pmax(5, rnorm(n, params$postlab_mean, params$postlab_sd))
  kvitteret <- besvaret + postlab_minutes * 60

  tibble(
    proevenr = proevenr_start:(proevenr_start + n - 1),
    kategori = category,
    afsendt = afsendt,
    modtaget = modtaget,
    besvaret = besvaret,
    kvitteret = kvitteret
  )
}

# Generate data for each week and category
all_data <- list()
proevenr_counter <- 1

for (week in 0:(n_weeks - 1)) {
  week_start <- start_date + weeks(week)

  for (category in names(samples_per_week)) {
    n <- samples_per_week[[category]]

    week_data <- generate_samples(
      category = category,
      n = n,
      week_start = week_start,
      proevenr_start = proevenr_counter
    )

    all_data <- c(all_data, list(week_data))
    proevenr_counter <- proevenr_counter + n
  }
}

tat_data <- bind_rows(all_data) |>
  arrange(afsendt)

# Add missing values at the end of observation period
# Last ~10% of samples: some missing besvaret, more missing kvitteret
n_total <- nrow(tat_data)
late_samples <- tail(tat_data, round(n_total * 0.1))

# ~30% of late samples missing kvitteret
missing_kvitteret_idx <- sample(
  which(tat_data$proevenr %in% late_samples$proevenr),
  size = round(nrow(late_samples) * 0.3)
)
tat_data$kvitteret[missing_kvitteret_idx] <- NA

# ~10% of late samples missing besvaret (and therefore kvitteret)
missing_besvaret_idx <- sample(
  which(tat_data$proevenr %in% late_samples$proevenr),
  size = round(nrow(late_samples) * 0.1)
)
tat_data$besvaret[missing_besvaret_idx] <- NA
tat_data$kvitteret[missing_besvaret_idx] <- NA

# Summary
cat("Generated", nrow(tat_data), "samples\n")
cat("Date range:", as.character(min(tat_data$afsendt)), "to", as.character(max(tat_data$afsendt)), "\n")
cat("Missing besvaret:", sum(is.na(tat_data$besvaret)), "\n")
cat("Missing kvitteret:", sum(is.na(tat_data$kvitteret)), "\n")
cat("\nSamples by category:\n")
print(table(tat_data$kategori))

# Save data
saveRDS(tat_data, "tat_data.rds")
write.csv(tat_data, "tat_data.csv", row.names = FALSE)

cat("\nData saved to tat_data.rds and tat_data.csv\n")
