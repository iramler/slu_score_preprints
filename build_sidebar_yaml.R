# build_sidebar_yaml.R

library(fs)
library(stringr)
library(glue)

# Find all sport listing files in the sports/ folder
sport_files <- dir_ls("sports", regexp = ".*\\.qmd$")

# Extract sport names from filenames
sports <- path_ext_remove(path_file(sport_files))
sports_sorted <- sort(sports)

# Build YAML block
yaml_lines <- c("sidebar:",
                '  - section: "By Sport"',
                '    contents:')

for (sport in sports_sorted) {
  text_label <- str_to_title(str_replace_all(sport, "-", " "))
  href_path <- glue("sports/{sport}.html")
  yaml_lines <- c(yaml_lines, glue('      - text: "{text_label}"'),
                               glue('        href: {href_path}'))
}

# Write to file
writeLines(yaml_lines, "sidebar-sports.yml")
cat("✓ sidebar-sports.yml created\n")
