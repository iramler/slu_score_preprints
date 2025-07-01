# build_sport_pages.R

library(fs)
library(stringr)
library(glue)

# Step 1: Find all index.qmd files in subfolders like Sport/Module/index.qmd
module_files <- dir_ls(path = ".", recurse = TRUE, glob = "*/*/index.qmd")
module_files <- module_files[!str_detect(
  module_files,
  regex("(^|/)early[_\\-\\s]?drafts(/|$)", ignore_case = TRUE)
)]

# Step 2: Extract the sport name from the top-level folder
file_df <- data.frame(
  file = module_files,
#  sport = str_match(module_files, "^.*/(.*?)/.*/index\\.qmd$")[,2],
  sport = str_match(module_files, "^([^/]+)/[^/]+/index\\.qmd$")[,2],
  stringsAsFactors = FALSE
)

# Step 3: Keep only valid entries
file_df <- file_df[!is.na(file_df$sport), ]

# Step 4: Create the 'sports' folder if it doesn't exist
dir_create("sports")

# Step 5: Generate one .qmd file per sport
for (sport in unique(file_df$sport)) {
  file_slug <- str_to_lower(str_replace_all(sport, "\\s+", "-"))
  file_path <- glue("sports/{file_slug}.qmd")

  page_content <- glue(
'---
title: "{sport} Modules"
listing:
  contents:
    - "../{sport}/*/index.qmd"
  sort: date desc
  type: grid
  fields: [title, author, date, categories]
---

These modules use **{sport}** data to teach topics in statistics and data science.
'
  )

  writeLines(page_content, file_path)
  cat(glue("✓ Created {file_path}\n"))
}
