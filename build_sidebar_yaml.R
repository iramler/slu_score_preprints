library(fs)
library(stringr)
library(glue)

# Step 1: Find top-level directories (sports)
top_dirs <- dir_ls(path = ".", type = "directory", recurse = FALSE)

# Step 2: Filter out undesired folders (e.g., system folders, early drafts, .git, etc.)
valid_sports <- top_dirs[
  !str_detect(top_dirs, regex("(^|/)early[_\\-\\s]?drafts(/|$)", ignore_case = TRUE)) &
    !basename(top_dirs) %in% c("_freeze","docs", ".git", ".quarto", "_site", "_extensions", "sports")
]

# Step 3: Extract folder names and sort
sport_names <- sort(basename(valid_sports))

# Step 4: Build YAML block
yaml_lines <- c("sidebar:",
                '  - section: "By Sport"',
                '    contents:')

for (sport in sport_names) {
#  text_label <- str_to_title(str_replace_all(sport, "-", " "))
  text_label <- str_to_title(str_replace_all(sport, "[-_]", " "))
  href_path <- glue("{sport}/index.html")
  yaml_lines <- c(yaml_lines, glue('      - text: "{text_label}"'),
                  glue('        href: {href_path}'))
}

# Step 5: Write to sidebar-sports.yml
writeLines(yaml_lines, "sidebar-sports.yml")
cat("✓ sidebar-sports.yml created\n")
