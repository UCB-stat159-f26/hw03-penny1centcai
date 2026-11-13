# Known birth dates help keep examples reliable if a profile changes layout.
known_birthdays <- function() {
  c(SerenaWilliams = "1981-09-26", RafaelNadal = "1986-06-03",
    VenusWilliams = "1980-06-17", RogerFederer = "1981-08-08",
    NovakDjokovic = "1987-05-22", NaomiOsaka = "1997-10-16",
    IgaSwiatek = "2001-05-31", CarlosAlcaraz = "2003-05-05",
    CocoGauff = "2004-03-13", MariaSharapova = "1987-04-19")
}

player_slug <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name))
    stop("Supply one player name as text.", call. = FALSE)
  ascii <- iconv(trimws(name), to = "ASCII//TRANSLIT")
  words <- strsplit(gsub("([a-z])([A-Z])", "\\1 \\2", ascii), "[^[:alnum:]]+")[[1]]
  words <- words[nzchar(words)]
  slug <- paste0(vapply(words, function(w) paste0(toupper(substr(w, 1, 1)),
                                  tolower(substring(w, 2))), ""), collapse = "")
  if (nchar(slug) < 3L) stop("Supply a valid full player name.", call. = FALSE)
  slug
}

# Treat network failures and missing pages as errors.
fetch_text <- function(url) {
  con <- tryCatch(base::url(url, open = "rb"), error = function(e) NULL)
  if (is.null(con)) stop("Could not connect to Tennis Abstract: ", url, call. = FALSE)
  on.exit(close(con))
  tryCatch(paste(readLines(con, warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
           error = function(e) stop("Could not download Tennis Abstract data: ", conditionMessage(e), call. = FALSE))
}

# Extract a date associated with 'Born' or 'DOB' from player profile.
profile_birthdate <- function(page) {
  plain <- gsub("<[^>]+>", " ", page)
  hit <- regmatches(plain, regexpr("(?i)(?:born|date of birth|dob)\\s*:?\\s*.{0,55}", plain, perl = TRUE))
  if (!length(hit)) return(as.Date(NA))
  date <- regmatches(hit, regexpr("\\b[0-9]{1,2}[- /][A-Za-z]{3,9}[- /][0-9]{4}\\b|\\b[0-9]{4}-[0-9]{2}-[0-9]{2}\\b", hit, perl = TRUE))
  if (!length(date)) return(as.Date(NA))
  for (fmt in c("%d-%b-%Y", "%d %B %Y", "%d %b %Y", "%Y-%m-%d")) {
    parsed <- as.Date(date, format = fmt)
    if (!is.na(parsed)) return(parsed)
  }
  as.Date(NA)
}

get_player_birthdate <- function(slug, tour) {
  fallback <- known_birthdays()[slug]
  if (length(fallback) && !is.na(fallback)) return(as.Date(fallback))
  page <- tryCatch(fetch_text(sprintf("https://www.tennisabstract.com/cgi-bin/%splayer-classic.cgi?p=%s", tour, slug)),
                   error = function(e) "")
  dob <- profile_birthdate(page)
  if (is.na(dob)) stop("Could not determine birth date for ", slug,
                       ". The Tennis Abstract player profile may be unavailable.", call. = FALSE)
  dob
}
