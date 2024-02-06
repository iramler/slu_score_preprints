library(rvest)
library(tidyverse)

boston_marathon_1_page <- function(i, sex = c("W","M")){
  
  base_url <- "https://results.baa.org/2023/?page="
  middle_url <- "&event=R&event_main_group=runner&num_results=1000&pid=list&pidp=start&search%5Bsex%5D="
  end_url <- "&search%5Bage_class%5D=%25"
  
  url <- paste0(base_url, i, middle_url, sex, end_url)
  
  obs <- read_html(url) |> 
    html_nodes("li.list-group-item")
  
  tmp <- obs |> html_text(trim = TRUE)
  X <- tmp[-(1:2)] |> str_split(pattern = "(\n)+", simplify = TRUE)

  return(X)
}


# Test run
xx <- boston_marathon_1_page(i = 1, sex = "W")

# will need to clean and add variable names

# within each run of the loop add Sys.sleep(rpois(1, 3)+1)
