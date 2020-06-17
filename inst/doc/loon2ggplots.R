## ----setup, warning=FALSE, include=FALSE--------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      message = FALSE,
                      fig.align = "center", 
                      fig.width = 6, 
                      fig.height = 5,
                      out.width = "60%", 
                      collapse = TRUE,
                      comment = "#>",
                      tidy.opts = list(width.cutoff = 65),
                      tidy = FALSE)
library(knitr)
set.seed(12314159)
imageDirectory <- "./img/loon2ggplots"
dataDirectory <- "./data/loon2ggplots"
path_concat <- function(path1, path2, sep="/") {paste(path1, path2, sep = sep)}

library(ggplot2, quietly = TRUE)
library(dplyr, quietly = TRUE)
library(nycflights13, quietly = TRUE)
library(loon, quietly = TRUE)
library(magrittr, quietly = TRUE)
library(maps, quietly = TRUE)

## ----l_plot, message = FALSE,  warning = FALSE, eval = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  library(dplyr)
#  library(loon)
#  mt <- mtcars %>%
#    rename(transmission = am, weight = wt, horsepower = hp) %>%
#    mutate(lp100km = (100 * 3.785411784) / (1.609344 * mpg))
#  
#  p <- mt %>%
#    with(
#      l_plot(horsepower, lp100km,
#             color = gear)
#    )

## ----l_plot_to_gg, message = FALSE,  warning = FALSE, eval = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  library(loon.ggplot)
#  g1 <- loon2ggplot(p)
#  g1

## ----l_plot_to_gg_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "ggScatter.png"))

## ----l_plot_to_gg_modification, message = FALSE, eval = FALSE, warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  g1 +
#    scale_fill_manual(values = c("#999999", "#A6CEE3", "#FFC0CB"),
#                      name = "gear",
#                      labels = c("4", "3", "5")) +
#    ggtitle(label = "horsepower versus lp100km",
#            subtitle = "loon --> ggplot") +
#    theme(
#      plot.title = element_text(color = "red", size = 12, face = "bold"),
#      plot.subtitle = element_text(color = "blue")
#    )

## ----l_plot_to_gg_modification_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "ggScatter_modification.png"))

## ----loon pairs, message = FALSE, warning = FALSE, eval = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  mt %>%
#    select(lp100km, weight, transmission) %>%
#    # and pass the built plot on
#    l_pairs(showHistograms = TRUE,
#            linkingGroup = "Motor Trend 1974") ->  # and assign the result.
#    l_pp

## ----p1_piped_staic  ggplot, message = FALSE, eval = FALSE, warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  g2 <- loon2ggplot(l_pp)
#  g2

## ----p1_piped_staic_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "loon_l_pairs.png"))

## ----p1_piped_modification  ggplot, message = FALSE, eval = FALSE, warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
#  # Add a smooth line on g[2,2]
#  # the index of `lp100km vs weight` scatterplot is
#  # 1 * 4 + 2
#  g2$plots[[6]] <- g2$plots[[6]] + geom_smooth()
#  # Add a density curve on g[1,2]
#  # the index of `weight` histogram is
#  # 1 * 4 + 1
#  g2$plots[[5]] <- g2$plots[[5]] + geom_density()
#  # Modify theme
#  g2 <- g2 + theme_light()
#  g2

## ----p1_piped_modification_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "loon_l_pairs_modification.png"))

## ----glyph_ggplot, message = FALSE, warning = FALSE, eval = FALSE, fig.width = 5, fig.height = 3, fig.align = "center", out.width = "70%"----
#  library(nycflights13)
#  library(maps)
#  destinations <- nycflights13::airports %>%
#    rename(dest = faa) %>%
#    semi_join(nycflights13::flights, by = "dest") %>%
#    filter(lon > -151,
#           lat < 55)
#  LA <- data.frame(
#    lon = -118.243683,
#    lat = 34.052235
#  )
#  map_data("state") %>%
#    ggplot(aes(long, lat, group = group)) +
#    geom_polygon(color="black", fill="cornsilk") +
#    geom_polygonGlyph(data = destinations,
#                      mapping = aes(x = lon, y = lat),
#                      inherit.aes = FALSE,
#                      polygon_x = x_airplane,
#                      polygon_y = y_airplane,
#                      size = 2,
#                      alpha = 0.75,
#                      fill = "deepskyblue") +
#    geom_polygonGlyph(data = LA,
#                      mapping = aes(x = lon, y = lat),
#                      inherit.aes = FALSE,
#                      polygon_x = x_star,
#                      polygon_y = y_star,
#                      alpha = 0.75,
#                      fill = "red")

## ----glyph_ggplot_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "map.png"))

## ----serialaxes, message = FALSE, warning = FALSE, eval = FALSE, fig.width = 5, fig.height = 3, fig.align = "center", out.width = "70%"----
#  # parallel axes plot
#  ggplot(data = iris,
#         mapping = aes(colour = Species)) %>%
#    ggSerialAxes(layout = "parallel") +
#    theme(axis.text.x = element_text(angle = 30, hjust = 0.7))

## ----serialaxes_graph, echo = FALSE, message = FALSE,  warning = FALSE, fig.width = 5, fig.height = 4, fig.align = "center", out.width = "70%"----
include_graphics(path_concat(imageDirectory, "parallel.png"))

