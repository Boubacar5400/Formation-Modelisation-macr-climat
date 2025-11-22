
## Chap 2_3_1
## IRF et graphiques pour le modèle avec Etat

# 0. Packages nécessaires -------------------------------------------------


library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(readxl)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(janitor)
library(zoo)
library(readr)


# 1. Import ---------------------------------------------------------------

resultats_taxes_pour_R <- read_csv("data_raw/resultats_taxes_pour_R.csv")
str(resultats_taxes_pour_R)


# 2. Traitement -----------------------------------------------------------


df <- resultats_taxes_pour_R %>%
  mutate(
    id = row_number(),
    # 11 valeurs par taxe, dans l'ordre TVA, INV, IR, SS, K, Y
    tax_type = rep(c("TVA", "INV", "IR", "SS", "K", "Y"), each = 11),
    tax_rate = case_when(
      tax_type == "TVA" ~ tau_tva,
      tax_type == "INV" ~ tau_inv,
      tax_type == "IR"  ~ tau_ir,
      tax_type == "SS"  ~ tau_ss,
      tax_type == "K"   ~ tau_k,
      tax_type == "Y"   ~ tau_y,
      TRUE ~ 0
    )
  )

vars_ss <- c("y_ss", "c_ss", "l_ss", "k_ss","g_ss","w_ss","r_ss","k_over_l_ss","w_over_r_ss","welfare_ss")

df_long_ss <- df %>%
  select(tax_type, tax_rate, all_of(vars_ss)) %>%
  pivot_longer(cols = all_of(vars_ss),
               names_to = "variable", values_to = "value")

gg_steady <- ggplot(df_long_ss,
                    aes(x = tax_rate, y = value, color = tax_type)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~ variable, scales = "free_y") +
  labs(x = "Taux de taxe", y = "Valeur au steady state",
       color = "Type de taxe") +
  theme_minimal()

gg_steady

# Calcul des bases "sans taxe" par groupe
bases <- df %>%
  group_by(tax_type) %>%
  filter(tax_rate == 0) %>%
  summarise(
    y_base  = first(y_ss),
    c_base  = first(c_ss),
    l_base  = first(l_ss),
    k_base  = first(k_ss),
    kl_base = first(k_over_l_ss),
    wr_base = first(w_over_r_ss),
    w_base  = first(welfare_ss),
    .groups = "drop"
  )

df_rel <- df %>%
  left_join(bases, by = "tax_type") %>%
  mutate(
    y_pct  = 100 * (y_ss / y_base - 1),
    c_pct  = 100 * (c_ss / c_base - 1),
    l_pct  = 100 * (l_ss / l_base - 1),
    k_pct  = 100 * (k_ss / k_base - 1),
    kl_pct = 100 * (k_over_l_ss / kl_base - 1),
    wr_pct = 100 * (w_over_r_ss / wr_base - 1),
    welfare_pct  = 100 * (welfare_ss / w_base - 1)
  )

heat <- df_rel %>%
  group_by(tax_type) %>%
  filter(tax_rate == max(tax_rate)) %>%
  ungroup() %>%
  select(tax_type, y_pct, c_pct, l_pct, k_pct, kl_pct, wr_pct, welfare_pct) %>%
  pivot_longer(
    cols = -tax_type,
    names_to = "variable",
    values_to = "pct"
  )%>%
  mutate(
    variable=
      case_when(
        variable=="c_pct"~"Consumption",
        variable=="k_pct"~"Capital",
        variable=="kl_pct"~"Capital to labour ratio",
        variable=="l_pct"~"Labour",
        variable=="welfare_pct"~"Welfare",
        variable=="wr_pct"~"Wage to interest rate ratio",
        variable=="y_pct"~"Production"
      )
  )

gg_heat <- ggplot(heat,
                  aes(x = variable,
                      y = forcats::fct_rev(tax_type),
                      fill = pct)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            size = 3) +
  scale_fill_gradient2(
    midpoint = 0,
    low  = "#2166ac",
    mid  = "white",
    high = "#b2182b"
  ) +
  labs(
    x = "Variable (%)",
    y = "Tax type",
    fill = "% change\nrelative to baseline",
    title = "Impact of each tax at maximum rate (%, relative to baseline)"
  )+
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

gg_heat


