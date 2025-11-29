library(readr)
library(dplyr)
library(ggplot2)

# ===============================
# 0) Préparation
# ===============================

df <- read_csv("data_raw/unanticipated_tax_irf.csv")


# Labels des variables
var_labels <- c(
  Y = "PIB (Y)",
  C = "Consommation (C)",
  K = "Capital (K)",
  E = "Émissions (E)",
  S = "Stock de GES (S)"
)

df <- df %>%
  mutate(variable_label = factor(variable, levels = names(var_labels),
                                 labels = unname(var_labels)))

# ===============================
# 1) IRF en niveaux : baseline + non anticipé
# ===============================

p_levels <- ggplot(df, aes(x = t, y = level)) +
  
  # Baseline (noir pointillé)
  geom_line(
    data = df %>% filter(scenario == "baseline"),
    aes(group = scenario),
    color = "black",
    linetype = "dashed",
    linewidth = 1.2
  ) +
  
  # Non anticipé (couleur standard)
  geom_line(
    data = df %>% filter(scenario == "unanticipated"),
    aes(color = "Choc non anticipé"),
    linewidth = 1
  ) +
  
  facet_wrap(~ variable_label, scales = "free_y") +
  
  scale_color_manual(values = c("Choc non anticipé" = "steelblue")) +
  
  labs(
    x = "Temps (périodes)",
    y = "Niveau",
    color = "",
    title = 'Choc de taxe "non anticipé" : IRF en niveaux'
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

p_levels
# Sauvegarde PNG
ggsave("figures/unanticipated_irf_levels.png",
       p_levels, width = 12, height = 8, dpi = 300)

# ===============================
# 2) IRF en écart % vs baseline
# ===============================

df_unant <- df %>% filter(scenario == "unanticipated")

p_dev <- ggplot(df_unant, aes(x = t, y = dev_pct, color = variable_label)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(linewidth = 1) +
  
  facet_wrap(~ variable_label, scales = "free_y") +
  
  scale_color_manual(values = rep("steelblue", length(var_labels))) +
  
  labs(
    x = "Temps (périodes)",
    y = "Écart (%) vs baseline",
    color = "",
    title = 'Choc de taxe "non anticipé" : IRF en % vs baseline'
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  )

p_dev

# Sauvegarde PNG
ggsave("figures/unanticipated_irf_dev_pct.png",
       p_dev, width = 12, height = 8, dpi = 300)


