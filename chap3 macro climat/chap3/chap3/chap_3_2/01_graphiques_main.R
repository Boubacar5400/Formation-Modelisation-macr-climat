library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

# ===============================
# 0) Lecture + préparation
# ===============================
df <- read_csv("data_raw/climate_feedback_all_levels.csv")


# Scénarios : on garde l'ordre du CSV, baseline en premier
scen_order  <- df %>%
  distinct(scenario_label, phi) %>%
  arrange(phi) %>%
  pull(scenario_label)

df <- df %>%
  mutate(
    scenario_label = factor(scenario_label, levels = scen_order),
    is_baseline    = (scenario_label == scen_order[1])
  )

# Labels jolies pour les variables
var_labels_hat <- c(
  y = "Production (stationnarisée y)",
  d = "Facteur de dommage (d)",
  e = "Émissions (stationnarisées, e)",
  s = "Stock de GES (stationnarisé, s)",
  c = "Consommation (c)",
  k = "Capital (k)",
  l = "Travail (l)"
)

var_labels_ns <- c(
  y = "Production (niveaux, y)",
  d = "Facteur de dommage (y)",
  e = "Émissions (niveaux, E)",
  s = "Stock de GES (niveaux, S)",
  c = "Consommation (C)",
  k = "Capital (k)",
  l = "Travail (l)"
)

# Palette pour les scénarios chocs (tous sauf baseline)
cols_scen <- c(
  scen_order[-1]
) |> setNames(c("#D55E00", "#0072B2", "#009E73")[seq_along(scen_order[-1])])

# ===============================
# 1) Niveaux stationnarisés : y, d, e, s
# ===============================
df_hat <- df %>% filter(kind == "hat", variable %in% c("y","d","e","s")) %>%
  mutate(variable_label = factor(variable,
                                 levels = names(var_labels_hat),
                                 labels = unname(var_labels_hat)))

p_hat_levels <- ggplot(df_hat, aes(x = t, y = level)) +
  # baseline = noir pointillé
  geom_line(
    data = df_hat %>% filter(is_baseline),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  # autres scénarios = couleurs
  geom_line(
    data = df_hat %>% filter(!is_baseline),
    aes(color = scenario_label),
    linewidth = 1
  ) +
  scale_color_manual(values = c("#D55E00", "#0072B2", "#009E73"), name = "Scénario") +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "Niveau (stationnarisé)",
    title = "Dommages climatiques : variables stationnarisées"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )
p_hat_levels

ggsave("figures/climate_feedback_stationary.png",
       p_hat_levels, width = 12, height = 8, dpi = 300)

# ===============================
# 2) Niveaux non stationnarisés : y, d, e, s
# ===============================
df_ns <- df %>% filter(kind == "ns", variable %in% c("y","d","e","s")) %>%
  mutate(variable_label = factor(variable,
                                 levels = names(var_labels_ns),
                                 labels = unname(var_labels_ns)))

p_ns_levels <- ggplot(df_ns, aes(x = t, y = level)) +
  geom_line(
    data = df_ns %>% filter(is_baseline),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  geom_line(
    data = df_ns %>% filter(!is_baseline),
    aes(color = scenario_label),
    linewidth = 1
  ) +
  scale_color_manual(values = c("#D55E00", "#0072B2", "#009E73"), name = "Scénario") +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "Niveau (non stationnarisé)",
    title = "Dommages climatiques : niveaux non stationnarisés"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )
p_ns_levels

ggsave("figures/climate_feedback_levels.png",
       p_ns_levels, width = 12, height = 8, dpi = 300)

# ===============================
# 3) Déviations vs baseline (stationnarisé)
#     y, c, k, l
# ===============================
df_hat_dev <- df %>%
  filter(kind == "hat",
         variable %in% c("y","c","k","l"),
         !is_baseline) %>%
  mutate(variable_label = factor(variable,
                                 levels = names(var_labels_hat),
                                 labels = unname(var_labels_hat)))

p_hat_dev <- ggplot(df_hat_dev, aes(x = t, y = dev_pct, color = scenario_label)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("#D55E00", "#0072B2", "#009E73"), name = "Scénario") +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "Écart (%) vs baseline",
    title = "Dommages climatiques : déviations (stationnarisé)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

p_hat_dev

ggsave("figures/climate_deviations_stationary.png",
       p_hat_dev, width = 12, height = 8, dpi = 300)

# ===============================
# 4) Déviations vs baseline (niveaux)
#     y, c, e, s
# ===============================
df_ns_dev <- df %>%
  filter(kind == "ns",
         variable %in% c("y","c","e","s"),
         !is_baseline) %>%
  mutate(variable_label = factor(variable,
                                 levels = names(var_labels_ns),
                                 labels = unname(var_labels_ns)))

p_ns_dev <- ggplot(df_ns_dev, aes(x = t, y = dev_pct, color = scenario_label)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("#D55E00", "#0072B2", "#009E73"), name = "Scénario") +
  facet_wrap(~ variable_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "Écart (%) vs baseline",
    title = "Dommages climatiques : déviations (niveaux)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

p_ns_dev
ggsave("figures/climate_deviations_levels.png",
       p_ns_dev, width = 12, height = 8, dpi = 300)

# ===============================
# 5) Facteur de dommage : niveau + perte (1-d)
# ===============================
df_d <- df %>%
  filter(kind == "hat", variable == "d") %>%
  mutate(
    loss_pct = ifelse(is_baseline, 0, 100 * (1 - level)),
    variable_label = "Facteur de dommage d / Perte 1 - d"
  )

# On met en long : niveau d vs perte 1-d
df_d_long <- df_d %>%
  select(scenario_label, is_baseline, t, level, loss_pct, variable_label) %>%
  pivot_longer(cols = c(level, loss_pct),
               names_to = "metric",
               values_to = "value") %>%
  mutate(
    metric_label = factor(metric,
                          levels = c("level","loss_pct"),
                          labels = c("Facteur de dommage d",
                                     "Perte de productivité (%) = 1 - d"))
  )

p_damage <- ggplot(df_d_long, aes(x = t, y = value)) +
  # baseline en noir pour "level"; pour loss_pct, baseline=0 donc pas très utile
  geom_line(
    data = df_d_long %>% filter(is_baseline & metric == "level"),
    aes(group = scenario_label),
    color = "black",
    linetype = "dashed",
    linewidth = 1
  ) +
  geom_hline(
    data = df_d_long %>% filter(metric == "loss_pct"),
    aes(yintercept = 0),
    linetype = "dashed"
  ) +
  geom_line(
    data = df_d_long %>% filter(!is_baseline),
    aes(color = scenario_label),
    linewidth = 1
  ) +
  scale_color_manual(values = c("#D55E00", "#0072B2", "#009E73"), name = "Scénario") +
  facet_wrap(~ metric_label, scales = "free_y") +
  labs(
    x = "Temps (périodes)",
    y = "",
    title = "Dommages climatiques : facteur d et perte de productivité"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

p_damage
ggsave("figures/climate_damage_factor.png",
       p_damage, width = 12, height = 6, dpi = 300)

