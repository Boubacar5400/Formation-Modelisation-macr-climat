library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)

irf <- read_csv("data_raw/resultats_chocs_fiscaux_pour_R.csv")
  
# Par ex : IRF de Y en % par type de taxe
irf_long<-irf%>%
  pivot_longer(
    !c(
      periode,
      tax_name,
      shock_size
    ),
    names_to="variables",
    values_to="value"
  )%>%
  mutate(
    var_def=
      case_when(variables=="y"~"Production",
                variables=="c"~"Consumption",
                variables=="l"~"Labour",
                variables=="k"~"Capital",
                variables=="invest"~"Investment",
                variables=="g"~"Public spending",
                variables=="w"~"Wage",
                variables=="r"~"Interest rate",
                variables=="k_over_l"~"Capital over labour ratio",
                variables=="w_over_r"~"price ratio (w/r)",
                variables=="c_over_y"~"consumption to GDP ratio",
                variables=="invest_over_y"~"Investment to GDP ratio",
                variables=="g_over_y"~"Public spending over GDP ratio")
  )

str(irf_long)

irf_long_pct <- irf_long %>%
  filter(!variables %in% c("g","g_over_y") )%>%
  group_by(tax_name, variables) %>%
  mutate(
    value0 = value[periode == 1][1],
    irf_pct = 100 * (value / value0 - 1)
  ) %>%
  ungroup()


p2 <- irf_long_pct %>%
  ggplot(aes(x = periode, y = irf_pct, colour = tax_name)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(linewidth = 0.8) +
  facet_wrap(~ var_def, scales = "free_y") +
  scale_y_continuous(
    labels = scales::label_percent(accuracy = 1, scale = 1)
  ) +
  labs(
    x = "Period",
    y = "IRF (% deviation from baseline)",
    colour = "Tax type",
    title = "Impulse responses by variable\n(overlay of different tax shocks)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(size = 9)
  )

p2
# ggsave("figures/irf_overlay_by_variable.png", p2,
#        width = 10, height = 7, dpi = 300)
