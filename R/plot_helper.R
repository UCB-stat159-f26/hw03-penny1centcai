
# Private helpers for formatting the career age scatterplot.

career_plot_scales <- function() {
  list(
    ggplot2::scale_color_manual(
      values = c(Won = "#159bc6", Lost = "#743d9c"),
      breaks = c("Won", "Lost"),
      labels = c("Match Won by Player of Interest", "Match Lost")
    ),
    ggplot2::scale_x_continuous(
      position = "top", breaks = function(x) pretty(x, n = 12)
    ),
    ggplot2::scale_y_continuous(
      breaks = seq(-20, 20, 10),
      labels = c("−20", "−10", "Same age", "+10", "+20")
    )
  )
}

career_plot_theme <- function() {
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
