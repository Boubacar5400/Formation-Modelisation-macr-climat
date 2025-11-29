library(readr)
library(dplyr)
library(ggplot2)

df <- read_csv("data_raw/tax_shocks_levels_and_dev.csv")

# Pour renommer les variables en labels plus jolis :
var_labels <- c(
  Y_ns = "PIB (Y)",
  C_ns = "Consommation (C)",
  K_ns = "Capital (K)",
  I_ns = "Investissement (I)",
  E_ns = "Émissions (E)",
  S_ns = "Stock de GES (S)"
)

df <- df %>%
  mutate(variable_label = factor(variable, levels = names(var_labels),
                                 labels = unname(var_labels)))

# ---- (1) Niveaux non stationnaires ----
p_levels<-ggplot(df, aes(x = t, y = level)) +
  # Baseline : noir + pointillé + épais
  geom_line(
    data = df %>% filter(scenario == "baseline"),
    aes(group = scenario),
    color = "black",
    linetype = "dashed",
    linewidth = 1.2
  ) +
  # Scénarios : couleurs automatiques
  geom_line(
    data = df %>% filter(scenario != "baseline"),
    aes(color = scenario),
    linewidth = 1
  ) +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "Niveau",
    title = "Chocs de taxes : niveaux non stationnaires",
    color = "Scénario"
  ) +
  theme_minimal()

p_levels

# ---- (2) Écarts % vs baseline (sans baseline dans la légende) ----
df_dev <- df %>% filter(scenario != "baseline")

p_dev<-ggplot(df_dev, aes(x = t, y = dev_pct, color = scenario)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line() +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(x = "Temps (périodes)", y = "Écart (%) vs baseline",
       title = "Chocs de taxes : écarts (%) vs baseline") +
  theme_minimal()


p_dev

#### export des figures

# Sauvegarde plot 1
ggsave("figures/tax_shocks_levels.png", p_levels,
       width = 12, height = 8, dpi = 300)


# Sauvegarde plot 2
ggsave("figures/tax_shocks_dev_pct.png", p_dev,
       width = 12, height = 8, dpi = 300)
