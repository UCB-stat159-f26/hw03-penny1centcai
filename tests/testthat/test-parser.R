fixture <- function(name) {
  path <- system.file("extdata", name, package = "tennisage")
  if (!nzchar(path)) stop("Missing test fixture: ", name)
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

test_that("female opponent birth dates become match-time ages", {
  matches <- tennisage:::clean_career_matches(
    fixture("FemalePlayerCareer.js"),
    "Serena Williams", as.Date("1981-09-26")
  )
  
  expect_equal(nrow(matches), 3L)
  expect_equal(matches$result, rep("Lost", 3))
  expect_equal(matches$match_date[1], as.Date("1995-10-30"))
  
  expect_equal(
    matches$opponent_age[1],
    as.numeric(as.Date("1995-10-30") - as.Date("1977-01-19")) / 365.2425
  )
  
  expect_equal(
    matches$opponent_age[2],
    as.numeric(as.Date("1997-03-07") - as.Date("1970-05-03")) / 365.2425
  )
  
  expect_equal(
    matches$age_difference,
    matches$player_age - matches$opponent_age
  )
})

test_that("male decimal age field remains numeric", {
  matches <- tennisage:::clean_career_matches(
    fixture("MalePlayerCareer.js"),
    "Rafael Nadal", as.Date("1986-06-03")
  )
  
  expect_equal(nrow(matches), 3L)
  expect_equal(matches$result, c("Lost", "Lost", "Won"))
  expect_equal(matches$opponent_age[1], 22.264202601)
  
  expect_equal(
    matches$player_age[1],
    as.numeric(as.Date("2001-09-10") - as.Date("1986-06-03")) / 365.2425
  )
})

test_that("name normalization accepts case, spaces and joined names", {
  expect_equal(
    tennisage:::player_slug("serena williams"),
    "SerenaWilliams"
  )
  expect_equal(
    tennisage:::player_slug("SerenaWilliams"),
    "SerenaWilliams"
  )
  expect_equal(
    tennisage:::player_slug("RAFAEL NADAL"),
    "RafaelNadal"
  )
  
  expect_error(tennisage:::player_slug(""), "valid full player")
  expect_error(tennisage:::player_slug(123), "Supply one player name")
  expect_error(tennisage:::player_slug(NA_character_), "Supply one player name")
})

test_that("bad or empty JS produces explanatory errors", {
  expect_error(
    tennisage:::extract_match_array("var wrong = [];"),
    "no readable"
  )
  
  expect_error(
    tennisage:::clean_career_matches(
      "var morematchmx = [];",
      "X",
      as.Date("1990-01-01")
    ),
    "No career"
  )
})

test_that("plot function validates data and returns ggplot", {
  matches <- tennisage:::clean_career_matches(
    fixture("MalePlayerCareer.js"),
    "Rafael Nadal", as.Date("1986-06-03")
  )
  
  p <- plot_career_ages(matches)
  
  expect_s3_class(p, "ggplot")
  expect_equal(rlang::as_label(p$mapping$x), "player_age")
  expect_equal(rlang::as_label(p$mapping$y), "age_difference")
  expect_equal(rlang::as_label(p$mapping$colour), "result")
  
  expect_error(
    plot_career_ages(data.frame(x = 1)),
    "Provide a match"
  )
})
