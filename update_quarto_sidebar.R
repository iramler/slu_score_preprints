# update_quarto_sidebar.R
library(yaml)

# Read the existing _quarto.yml
qfile <- "_quarto.yml"
q <- read_yaml(qfile)

# Detect folders with index.qmd (excluding hidden/system ones)
folders <- list.dirs(".", recursive = FALSE, full.names = FALSE)
folders <- folders[file.exists(file.path(folders, "index.qmd")) & !grepl("^_", folders)]

# Update sidebar with About + Modules by Sport
q$website$sidebar <- list(
  contents = list(
    list(
      section = "About",
      contents = c("_team.qmd", "by-statsds-topic.qmd")
    ),
    list(
      section = "Modules by Sport",
      contents = list(list(auto = TRUE, path = "."))
    )
  )
)

# Write updated YAML
# Write YAML with correct booleans (true/false without quotes)
yaml_text <- as.yaml(q)
yaml_text <- gsub("toc: 'true'", "toc: true", yaml_text)
yaml_text <- gsub("toc: 'false'", "toc: false", yaml_text)
writeLines(yaml_text, qfile)

