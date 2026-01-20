# Data Sensitivity Layers Diagram
# Visualizes the 6-layer architecture for AI-assisted development with patient data protection

library(ggplot2)
library(dplyr)

# Layer definitions
layers <- tibble(
  layer = c("L1", "L2", "L3", "L4", "L5", "L6"),
  name = c(
    "Production\nDatabases",
    "Analytics\nData Store",
    "Synthetic\nData",
    "Development\nEnvironment",
    "Staging",
    "Production"
  ),
  zone = c("Sensitive", "Sensitive", "Synthetic", "Development", "Deployment", "Deployment"),
  x = c(1, 1, 1, 1, 3, 3),
  y = c(6, 5, 3, 2, 3, 2),
  human_access = c("Read-only", "Read/Write", "Read/Write", "Read/Write", "Full", "Full"),
  ai_access = c("None", "None", "Read", "Read/Write", "None", "None"),
  description = c(
    "Raw patient data\nLIS/LIMS systems",
    "Aggregated data\nMostly de-identified",
    "Synthpop-generated\nMatches L2 structure",
    "Code & reports\nin development",
    "Validate against\nreal data",
    "Live reports\n& dashboards"
  )
)

# Zone colors
zone_colors <- c(
  "Sensitive" = "#ffcdd2",
  "Synthetic" = "#c8e6c9",
  "Development" = "#bbdefb",
  "Deployment" = "#ffe0b2"
)

zone_borders <- c(
  "Sensitive" = "#c62828",
  "Synthetic" = "#2e7d32",
  "Development" = "#1565c0",
  "Deployment" = "#ef6c00"
)

# Arrows (data flows)
arrows <- tibble(
  from_x = c(1, 1, 1, 1, 3, 1),
  from_y = c(6, 5, 3, 2, 3, 5),
  to_x =   c(1, 1, 1, 3, 3, 3),
  to_y =   c(5, 3, 2, 3, 2, 3),
  label = c(
    "ETL\n(human-written)",
    "Synthpop training\n(human-supervised)",
    "Data source",
    "Code promotion\n(human review)",
    "Deploy",
    "Real data source"
  ),
  label_x = c(0.5, 0.5, 0.5, 2, 3.3, 2),
  label_y = c(5.5, 4, 2.5, 2.5, 2.5, 4),
  curvature = c(0, 0, 0, 0, 0, -0.3)
)

# Build the plot
p <- ggplot() +
  # Zone background rectangles
  annotate("rect", xmin = 0.3, xmax = 1.7, ymin = 4.4, ymax = 6.6,
           fill = zone_colors["Sensitive"], alpha = 0.5,
           color = zone_borders["Sensitive"], linewidth = 1.2) +
  annotate("rect", xmin = 0.3, xmax = 1.7, ymin = 2.6, ymax = 3.6,
           fill = zone_colors["Synthetic"], alpha = 0.5,
           color = zone_borders["Synthetic"], linewidth = 1.2) +
  annotate("rect", xmin = 0.3, xmax = 1.7, ymin = 1.4, ymax = 2.4,
           fill = zone_colors["Development"], alpha = 0.5,
           color = zone_borders["Development"], linewidth = 1.2) +
  annotate("rect", xmin = 2.3, xmax = 3.7, ymin = 1.4, ymax = 3.6,
           fill = zone_colors["Deployment"], alpha = 0.5,
           color = zone_borders["Deployment"], linewidth = 1.2) +

 # Zone labels
  annotate("text", x = 0.35, y = 6.5, label = "SENSITIVE", fontface = "bold",
           hjust = 0, size = 3, color = zone_borders["Sensitive"]) +
  annotate("text", x = 0.35, y = 3.5, label = "SYNTHETIC", fontface = "bold",
           hjust = 0, size = 3, color = zone_borders["Synthetic"]) +
  annotate("text", x = 0.35, y = 2.35, label = "DEV", fontface = "bold",
           hjust = 0, size = 3, color = zone_borders["Development"]) +
  annotate("text", x = 2.35, y = 3.5, label = "DEPLOYMENT", fontface = "bold",
           hjust = 0, size = 3, color = zone_borders["Deployment"]) +

  # Layer boxes
 geom_tile(data = layers, aes(x = x, y = y), width = 1.2, height = 0.8,
            fill = "white", color = "#424242", linewidth = 0.8) +

 # Layer numbers
  geom_text(data = layers, aes(x = x - 0.5, y = y + 0.25, label = layer),
            fontface = "bold", size = 4, color = "#1565c0") +

 # Layer names
  geom_text(data = layers, aes(x = x, y = y + 0.1, label = name),
            fontface = "bold", size = 3, lineheight = 0.9) +

  # Access info
  geom_text(data = layers,
            aes(x = x, y = y - 0.25,
                label = paste0("Human: ", human_access, " | AI: ", ai_access)),
            size = 2.2, color = "#616161", fontface = "italic") +

  # Straight arrows
  geom_segment(data = arrows |> filter(curvature == 0),
               aes(x = from_x, y = from_y - 0.4, xend = to_x, yend = to_y + 0.4),
               arrow = arrow(length = unit(0.15, "inches"), type = "closed"),
               color = "#5a9ab8", linewidth = 0.8) +

  # Curved arrow (L2 to L5)
  geom_curve(data = arrows |> filter(curvature != 0),
             aes(x = from_x + 0.6, y = from_y, xend = to_x - 0.6, yend = to_y),
             arrow = arrow(length = unit(0.15, "inches"), type = "closed"),
             color = "#5a9ab8", linewidth = 0.8, curvature = -0.3) +

  # Arrow labels
  geom_label(data = arrows,
             aes(x = label_x, y = label_y, label = label),
             size = 2, fill = "white", label.padding = unit(0.15, "lines"),
             label.size = 0, lineheight = 0.9) +

  # Formatting
  coord_fixed(ratio = 1, xlim = c(0, 4), ylim = c(1, 7)) +
  theme_void() +
  labs(
    title = "Data Sensitivity & AI Development Framework",
    subtitle = "6-layer architecture for protecting patient data while enabling AI-assisted development",
    caption = "AI never sees patient data | Humans control the boundaries"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "#616161", margin = margin(b = 15)),
    plot.caption = element_text(size = 9, hjust = 0.5, color = "#424242", face = "italic",
                                margin = margin(t = 15)),
    plot.margin = margin(20, 20, 20, 20)
  )

# Save the plot
ggsave("data-layers-diagram.png", p, width = 10, height = 8, dpi = 300, bg = "white")
ggsave("data-layers-diagram.pdf", p, width = 10, height = 8, bg = "white")

# Print for interactive use
print(p)
