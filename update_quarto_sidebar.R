library(yaml)

qfile <- "_quarto.yml"

# Detect folders with index.qmd
folders <- list.dirs(".", recursive = FALSE, full.names = FALSE)
folders <- folders[file.exists(file.path(folders, "index.qmd")) & !grepl("^_", folders)]

# Create updated sidebar YAML block
new_sidebar <- list(
  website = list(
    sidebar = list(
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
  )
)

# Dump just the sidebar as YAML
sidebar_yaml <- as.yaml(new_sidebar$website$sidebar, indent.mapping.sequence = TRUE)
sidebar_yaml_lines <- paste("  sidebar:", gsub("\n", "\n    ", sidebar_yaml), sep = "\n")

# Read original _quarto.yml lines
yml_lines <- readLines(qfile)

# Replace the existing sidebar block
start_idx <- grep("^\\s*sidebar:", yml_lines)
if (length(start_idx) > 0) {
  # Remove existing sidebar block
  end_idx <- start_idx
  while (end_idx < length(yml_lines) && !grepl("^\\s*[^\\s]", yml_lines[end_idx + 1])) {
    end_idx <- end_idx + 1
  }
  yml_lines <- c(
    yml_lines[1:(start_idx - 1)],
    sidebar_yaml_lines,
    yml_lines[(end_idx + 1):length(yml_lines)]
  )
} else {
  # Append if sidebar is not found
  insert_idx <- grep("^website:", yml_lines)
  yml_lines <- append(yml_lines, sidebar_yaml_lines, after = insert_idx)
}

# Write back the updated file
writeLines(yml_lines, qfile)
