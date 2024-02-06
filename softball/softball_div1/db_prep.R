library("DBI")

batting2021 <- readr::read_csv("softball_div1/data/batting2021.csv")
batting2022 <- readr::read_csv("softball_div1/data/batting2022.csv")
batting2021_subset <- readr::read_csv("softball_div1/data/batting2021_subset.csv")
batting2022_subset <- readr::read_csv("softball_div1/data/batting2022_subset.csv")


con <- dbConnect(RSQLite::SQLite(), "softball_batting.sqlite")
dbWriteTable(con, "batting2021", batting2021)
dbWriteTable(con, "batting2022", batting2022)
dbWriteTable(con, "batting2021_subset", batting2021_subset)
dbWriteTable(con, "batting2022_subset", batting2022_subset)
dbListTables(con)
dbDisconnect(con)


con2 <- dbConnect(duckdb::duckdb(), dbdir = "softball_batting.duckdb")
dbWriteTable(con2, "batting2021", batting2021)
dbWriteTable(con2, "batting2022", batting2022)
dbWriteTable(con2, "batting2021_subset", batting2021_subset)
dbWriteTable(con2, "batting2022_subset", batting2022_subset)

dbListTables(con2)
dbDisconnect(con2)

