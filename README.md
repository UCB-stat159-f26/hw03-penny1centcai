# tennisage

`tennisage` is an R package for retrieving professional tennis players' career match data 
from Tennis Abstract and visualizing the age differences between players of interest and 
their opponents.

## Installation and package workflow

Install the package directly:

```r
install.packages(c("devtools", "usethis", "roxygen2", "testthat", "ggplot2", "jsonlite"))
devtools::install_github("UCB-stat159-f26/hw03-penny1centcai")
```

Once installed, load the package:

```r
library(tennisage)
```

## usage

Retrieve and plot Serena Williams' career matches:

```r
serena <- get_career_matches("Serena Williams")
plot_career_ages(serena)
```

Retrieve and plot Rafael Nadal's career matches:

```r
nadal <- get_career_matches("Rafael Nadal")
plot_career_ages(nadal)
```

The x-axis represents the player of interest's age at each match. The y-axis represents
the player of interest's age minus the opponent's age.

Positive values indicate that the player of interest was older than their opponent.

Points are colored according to whether the player of interest won or lost that match.

## Functions

### get_career_matches()

Downloads and processes a player's career match data from Tennis Abstract.

Accepts names such as:

- "serena williams"
- "Serena Williams"
- "SerenaWilliams"

Returns a cleaned data frame containing match dates, opponents, player ages, opponent ages,
age differences, and results.

### plot_career_ages()

Takes the cleaned data frame returned by `get_career_matches()` 
and produces a ggplot scatterplot.

## Data Source

Career match data is retrieved from
[Tennis Abstract](https://www.tennisabstract.com/).

Female-player and male-player career files use different formats for opponent age information. 
The package handles both formats.

## Testing

Automated tests use local JavaScript fixtures and do not access live Tennis Abstract servers.

To run tests:

```r
devtools::test()
```

To check the complete package:

```r
devtools::check()
```

## Limitations

- Retrieval requires access to Tennis Abstract.
- Some player profiles or match records may contain missing information.
- Player age calculations depend on the accuracy of recorded birth dates.
- Tennis Abstract may change its website or JavaScript file structure.

## Personal Reflections

Creating this package showed me how much work goes into developing software that other 
people can use. Even creating this package in and of itself required the use of already 
publishedpackages. Among other things, this experience taught me not to take any package for 
granted, as there was definitely someone out there who put a lot of their own time and effort 
to makethe lives of others easier. As for building the package itself, I had to learn to 
think aboutmore than just what the goal of the package is. I also had to consider how a user 
who hasnever interacted with me or my code before would interpret my work, and anticipate any 
hiccups or roadblocks they may encounter. I also had to think about how my work should be
organized, as I won't be there to explain anything to a new user and I would have to set up
my work in a way that is intuitive upon first glance. While much of the workflow was taught
in class, much of my learning came from the combination of applying it, anticipating how 
users would interact with the package, and the assistance of AI to troubleshoot complex 
functions.

Note on AI usage: 
- Model: ChatGPT, GPT-6
- Purpose: Assist with various code generation for complex functions
  - Example Prompt: My original plot_career_ages() function achieves the result I want, 
    however it exceeds 20 lines of code. How can the same result be achieved using fewer lines
    of code?