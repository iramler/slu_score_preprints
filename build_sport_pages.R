# build_sport_pages.R

library(fs)
library(stringr)
library(glue)

# make pretty titles
title_case_smart <- function(x) {
  words <- str_split(str_replace_all(x, "[-_]", " "), " ")[[1]]
  small_words <- c("and", "or", "of", "the", "in", "with", "for", "a", "an")
  words <- ifelse(tolower(words) %in% small_words, tolower(words), str_to_title(words))
  words[1] <- str_to_title(words[1])  # Always capitalize the first word
  paste(words, collapse = " ")
}

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


# Step 4: Generate one index.qmd file inside each sport folder
for (sport in unique(file_df$sport)) {
  file_path <- glue("{sport}/index.qmd")

  pretty_title <- title_case_smart(sport)
  
  page_content <- glue(
'---
title: "{pretty_title}"
listing:
  contents:
    - "./*/index.qmd"
  sort: date desc
  image-placeholder: "../_img/default_thumbnail.png"
  fields: [image, title, author, date, categories, description]
---

These modules use **{sport}** data to teach topics in statistics and data science.
'
  )

  writeLines(page_content, file_path)
  cat(glue("✓ Created {file_path}\n"))
}
