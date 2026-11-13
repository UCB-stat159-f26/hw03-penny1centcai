# Extract the JSON array assigned to morematchmx.
extract_match_array <- function(js_text) {
  m <- regexpr("(?s)\\bmorematchmx\\s*=\\s*\\[.*?\\]\\s*(?:;|$)", js_text, perl = TRUE)
  if (m[1] < 0) stop("Career JS has no readable morematchmx array.", call. = FALSE)
  fragment <- regmatches(js_text, m)
  fragment <- sub("(?s)^.*?=\\s*", "", fragment, perl = TRUE)
  fragment <- sub(";\\s*$", "", fragment)
  tryCatch(jsonlite::fromJSON(fragment, simplifyVector = FALSE),
           error = function(e) stop("Could not parse career match array: ", conditionMessage(e), call. = FALSE))
}

# Parse the YYYYMMDD dates in the match records.
parse_ymd <- function(x) {
  as.Date(as.character(x), format = "%Y%m%d")
}

# Standardization of ages across genders.
opponent_age <- function(raw_value, match_date) {
  value <- as.character(raw_value)
  if (grepl("^[0-9]{8}$", value)) {
    birthday <- parse_ymd(value)
    return(as.numeric(match_date - birthday) / 365.2425)
  }
  suppressWarnings(as.numeric(value))
}

clean_career_matches <- function(js_text, player_name, birth_date) {
  rows <- extract_match_array(js_text)
  if (!length(rows)) stop("No career matches found.", call. = FALSE)
  if (is.na(birth_date)) stop("Player date of birth is unavailable.", call. = FALSE)
  parsed <- lapply(rows, function(r) make_match_row(r, player_name, birth_date))
  out <- do.call(rbind, parsed)
  out <- out[!is.na(out$player_age) & !is.na(out$opponent_age) &
               out$result %in% c("Won", "Lost"), , drop = FALSE]
  if (!nrow(out)) stop("No matches with usable age and result fields.", call. = FALSE)
  rownames(out) <- NULL
  out
}

make_match_row <- function(r, player_name, birth_date) {
  if (length(r) < 17) r <- c(r, rep("", 17 - length(r)))
  date <- parse_ymd(r[[1]])
  own_age <- as.numeric(date - birth_date) / 365.2425
  rival_age <- opponent_age(r[[17]], date)
  result <- switch(r[[5]], W = "Won", L = "Lost", NA_character_)
  data.frame(player = player_name, match_date = date,
             opponent = as.character(r[[12]]), player_age = own_age,
             opponent_age = rival_age, age_difference = own_age - rival_age,
             result = result, stringsAsFactors = FALSE)
}
