library(readr)
library(dplyr)
library(ggplot2)

# ===============================
# 0) Lecture des données
# ===============================
df <- read_csv("data_raw/compare_anticipated_vs_unanticipated.csv")

if (!dir.exists("figures")) dir.create("figures")

# Labels pour les variables
var_labels <- c(
  Y = "PIB (Y)",
  C = "Consommation (C)",
  K = "Capital (K)",
  E = "Émissions (E)",
  S = "Stock de GES (S)"
)

# Labels pour les scénarios (plus lisibles)
scenario_labels <- c(
  baseline      = "Baseline",
  anticipated   = "Choc anticipé",
  unanticipated = "Choc non anticipé"
)

df <- df %>%
  mutate(
    variable_label = factor(variable,
                            levels = names(var_labels),
                            labels = unname(var_labels)),
    scenario_label = factor(scenario,
                            levels = names(scenario_labels),
                            labels = unname(scenario_labels))
  )

# Palette pour les scénarios "choc"
cols_scen <- c(
  "Choc anticipé"   = "firebrick",
  "Choc non anticipé" = "steelblue"
)

# ===============================
# 1) Niveaux : BAU vs anticipé vs non anticipé
# ===============================

# Baseline + deux scénarios de choc
p_levels <- ggplot(df, aes(x = t, y = level)) +
  # Baseline : noir pointillé
  geom_line(
    data = df %>% filter(scenario == "baseline"),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  # Anticipé / non anticipé : couleurs différentes
  geom_line(
    data = df %>% filter(scenario != "baseline"),
    aes(color = scenario_label),
    linewidth = 1
  ) +
  facet_wrap(~ variable_label, scales = "free_y") +
  scale_color_manual(values = cols_scen) +
  labs(
    x = "Temps (périodes)",
    y = "Niveau",
    color = "Scénario",
    title = "Choc de taxe : anticipé vs non anticipé (niveaux)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("figures/compare_tax_shock_levels.png",
       p_levels, width = 12, height = 8, dpi = 300)

# ===============================
# 2) Écarts % vs baseline
# ===============================

df_dev <- df %>% filter(scenario != "baseline")

p_dev <- ggplot(df_dev, aes(x = t, y = dev_pct, color = scenario_label)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(linewidth = 1) +
  facet_wrap(~ variable_label, scales = "free_y") +
  scale_color_manual(values = cols_scen) +
  labs(
    x = "Temps (périodes)",
    y = "Écart (%) vs baseline",
    color = "Scénario",
    title = "Choc de taxe : anticipé vs non anticipé (écarts % vs baseline)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("figures/compare_tax_shock_dev_pct.png",
       p_dev, width = 12, height = 8, dpi = 300)

ed