library(tidyverse)

miami2023_data <- read_csv("~/github_v2/slu_score_preprints/motor_sports/formula1_laps/miami2023_data.csv")

verstappen <- miami2023_data |>
  filter(str_detect(string = driverName, pattern = "Verstappen"))

ggplot(verstappen, aes(x = lap, y = lapTime)) + geom_line() +
  geom_point()


miami2023_data |>
  group_by(driverName) |>
  summarise(avgLP = mean(lapPosition), madTime = mad(lapTime)) |>
  arrange(desc(avgLP))


d2 <- miami2023_data |>
  filter(str_detect(string = driverName, pattern = "Lance Stroll"))


verstappen |>
  write_csv(file = "motor_sports/formula1_laps/verstappen_2023_miami.csv")




bind_rows(verstappen, d2) |>
  write_csv(file = "motor_sports/formula1_laps/verstappen_stroll_2023_miami.csv")


  ggplot(aes(x = lap, y = lapTime, group = driverName, color = driverName)) + geom_line() +
  geom_point() + lims(y = c(85,110)) +theme(legend.position = "top")


bind_rows(verstappen, d2) |>
  ggplot(aes(x = lapTime, fill = driverName)) + 
  geom_density(alpha = 0.5) +
  lims(x = c(88, 98)) +
  theme_bw()



