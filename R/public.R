#' Download and prepare a player's career tennis matches
#'
#' Fetches Tennis Abstract's career JavaScript and returns a data frame with
#' match dates, opponent names, player and opponent ages, age differences, and
#' win/loss results. Age difference is player age minus opponent age.
#'
#' @param player_name Name with or without spaces, case-insensitive.
#' @return A data.frame with player, match_date, opponent, player_age,
#'   opponent_age, age_difference, and result.
#' @examples
#' \dontrun{serena <- get_career_matches("Serena Williams")}
#' @export
get_career_matches <- function(player_name) {
  slug <- player_slug(player_name)
  url <- sprintf("https://www.tennisabstract.com/jsmatches/%sCareer.js", slug)
  js <- fetch_text(url)
  if (!grepl("\\bmorematchmx\\s*=", js))
    stop("No career match data for '", player_name, "'. Check the name on Tennis Abstract.", call. = FALSE)
  rows <- extract_match_array(js)
  if (!length(rows)) stop("No career matches found for '", player_name, "'.", call. = FALSE)
  sample_rows <- rows[seq_len(min(20L, length(rows)))]
  female <- any(vapply(sample_rows, function(r) length(r) >= 17L &&
                         grepl("^[0-9]{8}$", r[[17]]), logical(1)))
  tour <- if (female) "w" else ""
  birth <- get_player_birthdate(slug, tour)
  clean_career_matches(js, player_name, birth)
}

#' Plot a player's age against the relative ages of career opponents
#'
#' Positive age differences indicate that the player was older than the
#' opponent. Blue points represent wins and purple points losses.
#'
#' @param matches Data frame returned by [get_career_matches()].
#' @return A ggplot object, which can be displayed or saved with ggplot2::ggsave().
#' @examples
#' \dontrun{plot_career_ages(get_career_matches("Rafael Nadal"))}
#' @export
plot_career_ages <- function(matches) {
  required <- c("player", "player_age", "age_difference", "result")
  if (!is.data.frame(matches) || !all(required %in% names(matches)))
    stop("Provide a match data frame returned by get_career_matches().", call. = FALSE)
  if (!nrow(matches)) stop("There are no matches to plot.", call. = FALSE)
  ggplot2::ggplot(matches, ggplot2::aes(x = player_age, y = age_difference, color = result)) +
    ggplot2::geom_hline(yintercept = 0, color = "grey45", linewidth = 0.5) +
    ggplot2::geom_point(alpha = 0.7, size = 1.5) +
    ggplot2::scale_color_manual(values = c(Won = "#159bc6", Lost = "#743d9c"),
                                breaks = c("Won", "Lost"),
                                labels = c("Match Won by Player of Interest", "Match Lost"),
                                name = NULL) +
    ggplot2::scale_x_continuous(position = "top", breaks = function(x) pretty(x, n = 12)) +
    ggplot2::scale_y_continuous(breaks = seq(-20, 20, 10),
                                labels = c("−20", "−10", "Same age", "+10", "+20")) +
    ggplot2::labs(title = paste(unique(matches$player)[1], "Professional Matches"),
                  x = "Player age (years)", y = "", color = NULL) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      legend.position = "top",
      legend.location = "plot",
      legend.box.just = "center",
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.title.position = "plot",
      axis.title.x.top = ggplot2::element_text(hjust = 0)
    )
}
