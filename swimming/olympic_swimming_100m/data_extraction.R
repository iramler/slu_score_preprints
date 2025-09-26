library(rvest)
library(xml2)
library(dplyr)
library(stringr)
library(tibble)
library(readr)

# 1) Read the saved page source (adjust the path/filename if needed)
url = "https://www.olympics.com/en/olympic-games/paris-2024/results/swimming/women-100m-breaststroke"
#file = "D:/Users/ivanr/Downloads/new 7.txt"

olympic_slugs <- c(
  "paris-2024",
  "tokyo-2020",
  "rio-2016",
  "london-2012",
  "beijing-2008",
  "athens-2004",
  "sydney-2000",
  "atlanta-1996",
  "barcelona-1992",
  "seoul-1988",
  "los-angeles-1984",
  "moscow-1980",
  "montreal-1976",
  "munich-1972",
  "mexico-city-1968"
)

base_url <- "https://www.olympics.com/en/olympic-games/"
ending_url <- "/results/swimming/women-100m-breaststroke"



for()

page = url
html <- read_html_live(page)
html
html$view()



# 2) Rows: each result row is a grid container.
#    These containers have a stable-ish class that includes "sc-62f3057c-0"
rows <- html %>%
  html_elements("div[class*='sc-62f3057c-0']")

# Helper to safely pull text from a child using a fuzzy, class-contains selector
get_cell <- function(node, class_piece, fallback = NA_character_) {
  # pick the first match
  el <- html_element(node, paste0("[class*='", class_piece, "']"))
  if (length(el) == 0) return(fallback)
  txt <- html_text2(el)
  if (is.na(txt) || txt == "") fallback else txt
}

# 3) Extract columns
dat <- lapply(rows, function(r) {
  # Medal/rank area (shows G/S/B or 4–8)
  medal_or_rank <- get_cell(r, "sc-4ffa8ad5-0")
  
  # Team area is the "flag" cell; the 3-letter code often appears as text near the flag
  # If not present as text, we set NA here and you can fill manually.
  team_raw <- get_cell(r, "sc-4ffa8ad5-1", fallback = NA_character_)
  
  # Athlete name lives in the "athlete" cell
  athlete <- get_cell(r, "sc-4ffa8ad5-4")
  
  # Results time (e.g., "1:04.82" or "1:05.12")
  results_chr <- get_cell(r, "sc-4ffa8ad5-2")
  
  # Notes cell (often empty)
  notes <- get_cell(r, "sc-4ffa8ad5-3", fallback = "")
  
  tibble(
    Rank_raw = medal_or_rank,
    Team     = str_squish(team_raw),
    Athlete  = str_squish(athlete),
    Results_raw = str_squish(results_chr),
    Notes    = str_squish(notes)
  )
}) %>%
  bind_rows()

# 4) Normalize Rank: map G/S/B to 1/2/3; keep numeric otherwise
dat <- dat %>%
  mutate(
    Rank = case_when(
      Rank_raw %in% c("G", "Gold")   ~ 1L,
      Rank_raw %in% c("S", "Silver") ~ 2L,
      Rank_raw %in% c("B", "Bronze") ~ 3L,
      str_detect(Rank_raw, "^[0-9]+$") ~ as.integer(Rank_raw),
      TRUE ~ NA_integer_
    )
  )

# 5) Clean Results to seconds (handles "MM:SS.ss" or "SS.ss")
parse_time_to_seconds <- function(x) {
  x <- str_trim(x)
  ifelse(
    str_detect(x, "^\\d+:\\d"),
    {
      m <- as.numeric(str_extract(x, "^\\d+"))
      s <- as.numeric(str_replace(str_extract(x, ":\\d+\\.?\\d*"), ":", ""))
      m * 60 + s
    },
    suppressWarnings(as.numeric(x))
  )
}

dat <- dat %>%
  mutate(
     Results = str_remove(Results_raw, "Results:"), 
     Results = parse_time_to_seconds(Results)
  )

# 6) Attach your module’s fixed columns (so you can bind to your existing CSV)
final_rows <- dat %>%
  transmute(
    Location   = "Paris",
    Year       = 2024L,
    dist_m     = 100L,
    Stroke     = "Breaststroke",
    Gender     = "Women",
    Team       = Team,
    Athlete    = Athlete,
    Results    = Results,
    Rank       = Rank,
    Era        = "recent"
  )

# 7) Inspect
print(final_rows)
