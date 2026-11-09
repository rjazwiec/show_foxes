# run_analysis.R
#
# Demo report only: simulates FICTIONAL fox morphometric data (no real or
# corporate data), fits two linear models and saves
#   output/fox_demo/plots/*.png         figures
#   output/fox_demo/_cache/fox_data.rds data and model tables
# The report reports/fox_demo/fox_demo.qmd only reads these files.

.generator <- "programs/fox_demo/run_analysis.R"
here::i_am(.generator)

library(dplyr)
library(tidyr)
library(ggplot2)

source(here::here("setup/sysfont_module.R"))
source(here::here("R/plot_theme.R")) # theme_celon(base_size = 32)
source(here::here("R/save_figure.R")) # save_figure()

set.seed(2026)

.plot_dir <- here::here("output/fox_demo/plots")
.cache_dir <- here::here("output/fox_demo/_cache")
dir.create(.cache_dir, recursive = TRUE, showWarnings = FALSE)

.fox_palette <- c(
  "Red fox" = "#F17E00",
  "Arctic fox" = "darkgrey",
  "Fennec fox" = "black"
)

# Simulate specimens ----

.species <- tibble(
  common = names(.fox_palette),
  species = c("Vulpes vulpes", "Vulpes lagopus", "Vulpes zerda"),
  mass0 = c(6.5, 3.5, 1.2),
  ear0 = c(9.5, 6.5, 15),
  temp0 = c(8, -8, 24),
  habitat = c("Temperate woodland", "Arctic tundra", "Hot desert")
)

.sites <- tibble(
  site = c(
    "Site A", "Site B", "Site C", "Site D", "Site E", "Site F"
  ),
  region = c(
    "Northern Europe", "Siberia", "Greenland", "Sahara", "Arabia", "Alaska"
  ),
  latitude = c(58, 68, 72, 24, 25, 65)
)

specimens <- .species |>
  slice(rep(1:3, times = c(60, 45, 45))) |>
  mutate(
    specimen_id = sprintf("FX-%03d", row_number()),
    site = sample(.sites$site, n(), replace = TRUE),
    age_ma = round(runif(n(), 0, 3.5), 2),
    temp_c = round(temp0 + 1.8 * age_ma + rnorm(n(), 0, 2.5), 1),
    body_mass_kg = round(
      mass0 * (1 - 0.1 * age_ma / 3.5) * exp(rnorm(n(), 0, 0.08)),
      2
    ),
    ear_cm = round(ear0 + 0.16 * (temp_c - temp0) + rnorm(n(), 0, 0.6), 1),
    skull_cm = round(7.2 * body_mass_kg^0.31 + rnorm(n(), 0, 0.25), 1),
    tail_cm = round(34 * body_mass_kg^0.26 + rnorm(n(), 0, 1.5), 1),
    hind_foot_cm = round(10.5 * body_mass_kg^0.24 + rnorm(n(), 0, 0.5), 1),
    pc1 = scale(skull_cm + 0.4 * ear_cm + rnorm(n(), 0, 0.4))[, 1],
    pc2 = scale(0.5 * tail_cm - hind_foot_cm + rnorm(n(), 0, 1.2))[, 1]
  ) |>
  select(-mass0, -ear0, -temp0) |>
  left_join(.sites, by = "site") |>
  mutate(common = factor(common, levels = names(.fox_palette)))

# Models ----

.coef_table <- function(fit) {
  summary(fit)$coefficients |>
    as.data.frame() |>
    tibble::rownames_to_column("term") |>
    rename(estimate = 2, se = 3, t = 4, p = 5)
}

fit_mass <- lm(log(body_mass_kg) ~ age_ma * common, data = specimens)
fit_ear <- lm(ear_cm ~ temp_c * common, data = specimens)

.fox_data <- list(
  specimens = specimens,
  sites = .sites,
  species = .species,
  coef_mass = .coef_table(fit_mass),
  coef_ear = .coef_table(fit_ear)
)
saveRDS(.fox_data, file.path(.cache_dir, "fox_data.rds"))

# Figures ----

p_mass <- specimens |>
  ggplot(aes(age_ma, body_mass_kg, colour = common)) +
  geom_point(alpha = 0.6, size = 1.6) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8, alpha = 0.15) +
  scale_x_reverse() +
  scale_colour_manual(values = .fox_palette, name = NULL) +
  labs(x = "Specimen age (Ma)", y = "Body mass (kg)") +
  theme_celon(base_size = 32)
save_figure(
  p_mass,
  file.path(.plot_dir, "body_mass_time.png"),
  .generator,
  width = 20,
  height = 11
)

p_ear <- specimens |>
  ggplot(aes(temp_c, ear_cm, colour = common)) +
  geom_point(alpha = 0.6, size = 1.6) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_colour_manual(values = .fox_palette, name = NULL) +
  labs(x = "Mean annual temperature (°C)", y = "Ear length (cm)") +
  theme_celon(base_size = 32)
save_figure(
  p_ear,
  file.path(.plot_dir, "ear_temperature.png"),
  .generator,
  width = 20,
  height = 11
)

# Lineages through time: three fictional clades, pure-birth process
p_ltt <- tidyr::expand_grid(
  clade = c("Clade I", "Clade II", "Clade III"),
  time_ma = seq(5, 0, by = -0.1)
) |>
  mutate(
    rate = case_when(
      clade == "Clade I" ~ 6,
      clade == "Clade II" ~ 4,
      TRUE ~ 2.5
    )
  ) |>
  group_by(clade) |>
  mutate(lineages = 1 + cumsum(rpois(n(), rate * 0.1))) |>
  ungroup() |>
  ggplot(aes(time_ma, lineages, colour = clade)) +
  geom_step(linewidth = 1) +
  scale_x_reverse() +
  scale_y_log10() +
  scale_colour_manual(
    values = c("Clade I" = "#F17E00", "Clade II" = "darkgrey", "Clade III" = "black"),
    name = NULL
  ) +
  labs(x = "Time before present (Ma)", y = "Number of lineages") +
  theme_celon(base_size = 32)
save_figure(
  p_ltt,
  file.path(.plot_dir, "lineages_through_time.png"),
  .generator,
  width = 20,
  height = 11
)

p_pca <- specimens |>
  ggplot(aes(pc1, pc2, colour = common)) +
  geom_point(alpha = 0.7, size = 1.8) +
  stat_ellipse(level = 0.9, linewidth = 0.7) +
  scale_colour_manual(values = .fox_palette, name = NULL) +
  labs(x = "Skull shape score 1 (standardized)", y = "Skull shape score 2 (standardized)") +
  theme_celon(base_size = 32)
save_figure(
  p_pca,
  file.path(.plot_dir, "skull_shape_scores.png"),
  .generator,
  width = 20,
  height = 12
)

p_resid <- tibble(fitted = fitted(fit_mass), resid = resid(fit_mass)) |>
  ggplot(aes(fitted, resid)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "darkgrey") +
  geom_point(colour = "#F17E00", alpha = 0.7, size = 1.6) +
  geom_smooth(method = "loess", se = FALSE, colour = "black", linewidth = 0.7) +
  labs(x = "Fitted log body mass", y = "Residual") +
  theme_celon(base_size = 32)
save_figure(
  p_resid,
  file.path(.plot_dir, "mass_model_residuals.png"),
  .generator,
  width = 20,
  height = 11
)
