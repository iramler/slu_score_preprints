library(tidyverse)
library(MASS)
library(quantreg)

# https://www.pro-football-reference.com/about/glossary.htm#ay/a

# (Adjusted Net Yards Per Attempt (ANY/A))

nfl_qbr <- read_csv("nfl_qbr.csv") |>
  mutate(comp_rate = completions / attempts,
         anypa = (passing_yards + (20 * passing_tds) - (45 * passing_interceptions) - sack_yards) /
           (attempts + sacks),
         qbr_pred = -13.5  + 11.23 * anypa)

# Testing pre-established formula attempt from online
cor(nfl_qbr$qbr, nfl_qbr$qbr_pred)^2 # 45.09%


# Testing step wise regression
predictors <- c("anypa", "comp_rate", "fumbles", "prop_total", "result",
                "passing_yards", "passing_tds", "passing_interceptions", "sack_yards", 
                "attempts", "sacks", "completions")
full_mod <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])
step_mod <- stepAIC(full_mod, direction = "both")

summary(step_mod) # 61.81% without completions, 62.15% with it & comp_rate

# Testing quantile regression
quantiles <- c(0.25, 0.50, 0.75, 0.90)
qr_models <- map(quantiles, ~ rq(qbr ~ anypa + comp_rate + completions, tau = .x, data = nfl_qbr))
map(qr_models, summary)

qr_rsq <- function(model) {
  rho <- function(u, tau) tau * u * (u >= 0) + (tau - 1) * u * (u < 0)
  y <- model$model$qbr
  ss_res <- sum(rho(y - fitted(model), model$tau))
  ss_tot <- sum(rho(y - median(y), model$tau))
  1 - ss_res/ss_tot}
pseudo_r2 <- map_dfr(qr_models, ~ data.frame(tau = .x$tau, r2 = qr_rsq(.x)), 
                     .id = "model")
print(pseudo_r2) # model 4, 69.79% 

# Most accurate for top 10% of QB ratings, okay for lower scores but tough to predict middle
# Maybe middle is more inconsistent
