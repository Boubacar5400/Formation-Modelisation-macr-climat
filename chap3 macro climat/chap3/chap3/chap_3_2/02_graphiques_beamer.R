library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

# ===============================
# 0) Lecture des données
# ===============================
df <- read_csv("data_raw/climate_feedback_all_levels.csv")
stats <- read_csv("data_raw/climate_statistics.csv")


T_shock_start <- 50
T_shock_end   <- 100
T_display     <- 100

# Ordre des scénarios (phi croissant)
scen_order <- df %>%
  distinct(scenario_label, phi) %>%
  arrange(phi) %>%
  pull(scenario_label)

baseline_label <- scen_order[1]

df <- df %>%
  mutate(
    scenario_label = factor(scenario_label, levels = scen_order),
    is_baseline    = (scenario_label == baseline_label)
  )

# Palette simple pour les scénarios ≠ baseline
cols_vals <- c("#D55E00", "#0072B2", "#009E73")

# ===============================
# 1) Production stationnarisée (ŷ)
# ===============================
df_y_hat <- df %>%
  filter(kind == "hat", variable == "y", t <= T_display)

p_y_hat <- ggplot(df_y_hat, aes(x = t, y = level)) +
  annotate("rect",
           xmin = T_shock_start, xmax = T_shock_end,
           ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "grey50") +
  geom_line(
    data = df_y_hat %>% filter(is_baseline),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  geom_line(
    data = df_y_hat %>% filter(!is_baseline),
    aes(color = scenario_label),
    linewidth = 1.3
  ) +
  scale_color_manual(values = cols_vals, name = "Scénario") +
  labs(
    x = "Temps",
    y = "y_hat",
    title = "Production stationnarisée"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )
p_y_hat
ggsave("figures/Beamer/climate_feedback_stationary_y.png",
       p_y_hat, width = 8, height = 6, dpi = 300)

# ===============================
# 2) Production en niveaux (Y)
# ===============================
df_y_ns <- df %>%
  filter(kind == "ns", variable == "y", t <= T_display)

p_y_ns <- ggplot(df_y_ns, aes(x = t, y = level)) +
  annotate("rect",
           xmin = T_shock_start, xmax = T_shock_end,
           ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "grey50") +
  geom_line(
    data = df_y_ns %>% filter(is_baseline),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  geom_line(
    data = df_y_ns %>% filter(!is_baseline),
    aes(color = scenario_label),
    linewidth = 1.3
  ) +
  scale_color_manual(values = cols_vals, name = "Scénario") +
  labs(
    x = "Temps",
    y = "Y",
    title = "Production (niveaux)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )
p_y_ns
ggsave("figures/Beamer/climate_feedback_levels_y.png",
       p_y_ns, width = 8, height = 6, dpi = 300)

# ===============================
# 3) Déviation de production (stationnarisée)
# ===============================
df_y_hat_dev <- df %>%
  filter(kind == "hat", variable == "y", !is_baseline, t <= T_display)

p_y_hat_dev <- ggplot(df_y_hat_dev, aes(x = t, y = dev_pct, color = scenario_label)) +
  annotate("rect",
           xmin = T_shock_start, xmax = T_shock_end,
           ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "grey50") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_line(linewidth = 1.3) +
  scale_color_manual(values = cols_vals, name = "Scénario") +
  labs(
    x = "Temps",
    y = "Déviation (%)",
    title = "Perte de production vs baseline (stationnarisé)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )

p_y_hat_dev
ggsave("figures/Beamer/climate_deviations_stationary_y.png",
       p_y_hat_dev, width = 8, height = 6, dpi = 300)

