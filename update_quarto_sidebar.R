library(yaml)

qfile <- "_quarto.yml"

# Read the full YAML
q <- read_yaml(qfile)

# Detect folders with index.qmd
folders <- list.dirs(".", recursive = FALSE, full.names = FALSE)
folders <- folders[file.exists(file.path(folders, "index.qmd")) & !grepl("^_", folders)]

# Update just the sidebar portion
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

# Custom boolean handler to force true/false without quotes
yaml_text <- as.yaml(q, handlers = list(
  logical = function(x) if (x) "true" else "false"
))

# Write YAML back
writeLines(yaml_text, qfile)
