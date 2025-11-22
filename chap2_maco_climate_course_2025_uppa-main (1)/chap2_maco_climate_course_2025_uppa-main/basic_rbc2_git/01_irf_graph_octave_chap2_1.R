

## IRF à partir des 2 mod file qui ont tourné sous octave: 

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



# 1. Imports --------------------------------------------------------------

endo_simul_LBAR_raw <- read_csv("data_raw/endo_simul_LBAR.csv")%>%
  clean_names()


endo_simul_TFP_raw <- read_csv("data_raw/endo_simul_TFP.csv")%>%
  clean_names()

# 2. Traitement -----------------------------------------------------------

# on rajoute les chocs 

endo_simul_LBAR<-endo_simul_LBAR_raw%>%
  mutate(
    shock="labour supply"
  )

endo_simul_TFP<-endo_simul_TFP_raw%>%
  mutate(
    shock="TFP"
  )

# fusion des bases 

df<-endo_simul_LBAR%>%
  rbind(
    endo_simul_TFP
  )

## passage en long :
df_long <- df %>%
  # on passe toutes les variables endogènes en long
  pivot_longer(
    cols = -c(time, shock),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(shock, variable) %>%
  arrange(time, .by_group = TRUE) %>%
  
  # IRF = écart % par rapport à la première période 
  mutate(
    ss       = first(value),
    irf_pct  = 100 * (value / ss - 1)
  ) %>%
  ungroup()%>%
  filter(variable!="dk")%>%
  mutate(variable=
           case_when(
             variable =="c" ~ "Consumtpion",
             variable =="invest" ~ "investment",
             variable =="k" ~ "Capital",
             variable =="l" ~ "labour supply",
             variable =="r" ~ "interest rate",
             variable =="w" ~ "Wage",
             variable =="y" ~ "Production",
           ))

cols <- c(
  "TFP"            = "#FF6B6B",
  "labour supply"  = "#3C8DAD"
)

# graphique pour le choc sur le travail
p_labour <- df_long %>%
  filter(shock == "labour supply") %>%
  ggplot(aes(x = time, y = irf_pct/100)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(col="#3C8DAD",
            linewidth=1.5) +
  facet_wrap(~ variable, scales = "free_y") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  labs(
    title = "IRF – Labour supply exogenous shock",
    x="",
    #x = "Periods",
    y = "Variation % wrt SS"
  ) +
  theme_minimal()

p_labour

## 2è graphique 
p_tfp <- df_long %>%
  filter(shock == "TFP") %>%
  ggplot(aes(x = time, y = irf_pct/100))+ ## pour exprimer corretement en %)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
    geom_line(col="#FF6B6B",,
              linewidth=1.5) +
    facet_wrap(~ variable, scales = "free_y") +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  labs(
    title = "IRF – Choc TFP",
    x="",
    #x = "Periods",
    y = "Variation % wrt SS"
  ) +
  theme_minimal()

p_tfp

p_compare <- df_long %>%
  ggplot(aes(x = time, y = irf_pct, colour = shock, )) +
  geom_hline(yintercept = 0, linetype=2) +
  geom_line(linewidth=1.5) +
  scale_color_manual(values=cols)+
  facet_wrap(~ variable, scales = "free_y") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1, scale = 1)) +
  labs(
    title = "IRF ",
    x = "",
    y = "Variation % wrt SS",
    colour   = "Choc",
    linetype = "Choc"
  ) +
  theme_minimal()

p_compare


# Export 

# Dossier d'exportation
fig_dir <- "figures"


ggsave(file.path(fig_dir, "IRF_TFP.png"),      p_tfp,      dpi = 300, width = 10, height = 7)
ggsave(file.path(fig_dir, "IRF_Labour.png"),   p_labour,     dpi = 300, width = 10, height = 7)
ggsave(file.path(fig_dir, "IRF_Compare.png"),  p_compare,  dpi = 300, width = 10, height = 7)


