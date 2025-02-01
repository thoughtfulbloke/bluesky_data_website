library(bskyr)
library(lubridate)
library(dplyr)

global_defaults <- function(x){
  varlines <- readLines(x)
  splitvars <- strsplit(varlines, ": ")
  named_vars <- setNames(lapply(splitvars, `[`, 2), sapply(splitvars, `[`, 1))
  return(named_vars)
}

update_data_csv <- function(named_vars) {
  now_is <- now(tzone = "UTC")
  formatted_now <- format(now_is, "%Y-%m-%dT%H:%M:%S.000Z")
  ors <- unlist(strsplit(named_vars[["or_search_string"]], split = ","))
  latest <- lapply(ors, bs_search_posts, 
                   since=named_vars[["last_update"]],
                   until=formatted_now,
                   limit=as.numeric(named_vars[["estimate_hash_limit"]]))
  new_data <- bind_rows(latest)
  texts <- sapply(new_data[["record"]], function(x){return(x$text)})
  times <- sapply(new_data[["record"]], function(x){return(x$createdAt)})
  authors <- sapply(new_data[["author"]], function(x){return(x$handle)})
  uri <- new_data[["uri"]]
  replies <- new_data[["reply_count"]]
  reposts <- new_data[["repost_count"]]
  news <- data.frame(texts, times, authors, uri, replies, reposts) |> 
    distinct()
  # only if there are results add to the csv & update when ran info
  if(nrow(news) > 0){
    write.table(news, file = "Data/posts.csv", append = TRUE, 
                row.names = FALSE, col.names = FALSE, sep = ",")
    }
  named_vars[["prior_update"]] <- named_vars[["last_update"]]
  named_vars[["last_update"]] <- formatted_now
  char_output <- paste0(names(unlist(named_vars)), ": ",
                        unname(unlist(named_vars)))
  writeLines(char_output, "Data/datavars.txt")
}
