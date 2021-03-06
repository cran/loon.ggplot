scatterplotAsAesTRUE <- function(ggObj, widget, x, y,
                                 glyph, color, size, index, selectedOnTop = TRUE) {

  pch <- glyph_to_pch(glyph)

  if (!any(is.na(pch)) && !any(pch %in% 21:24)) {

    size <- as_ggplot_size(size)

    ggObj <- ggObj +
      ggplot2::geom_point(
        data = data.frame(x = x,
                          y = y,
                          color = color,
                          size = size),
        mapping = ggplot2::aes(x = x, y = y, color = color,
                               size = size),
        shape = pch
      )

  } else if (!any(is.na(pch)) && all(pch %in% 21:24)) {

    size <- as_ggplot_size(size)

    # No NAs and ALL points with borders
    if(!selectedOnTop) {

      # to preserve orders
      # the shape of the points may not be satisfying
      ggObj <- ggObj +
        ggplot2::geom_point(
          data = data.frame(x = x,
                            y = y,
                            fill = color,
                            size = size),
          mapping = ggplot2::aes(x = x, y = y,
                                 fill = fill,
                                 size = size),
          shape = pch
        )

    } else {

      for(p in unique(pch)) {

        pid <- pch == p

        ggObj <- ggObj +
          ggplot2::geom_point(
            data = data.frame(x = x[pid],
                              y = y[pid],
                              fill = color[pid],
                              size = size[pid]),
            mapping = ggplot2::aes(x = x, y = y,
                                   fill = fill,
                                   size = size),
            shape = p
          )
      }

    }


  } else {
    # possibly some NAs (means some points are text, polygons, images, etc.)
    # and/or a mix of regular and closed points.
    type <- sapply(glyph, function(glyph) loon::l_glyph_getType(widget, glyph))
    types <- paste(type, names(type), sep = ".")
    uniqueTypes <- unique(types)

    lenUniqueTypes <- length(uniqueTypes)
    if(lenUniqueTypes > 1 && !selectedOnTop) {
      warning("More than one non-primitive glyphs are detected. ",
              "The selected points will be always on top. ",
              "The displayed order may be different from the original data set order.",
              call. = FALSE)
    }

    for(utypes in uniqueTypes) {

      id <- which(types == utypes)

      aesthetic <- list(
        x = x[id],
        y = y[id],
        glyph = glyph[id],
        color = color[id],
        size = size[id],
        index = index[id]
      )

      utype <- strsplit(utypes, "[.]")[[1L]][1L]

      switch(utype,
             "polygon" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))

               # `showArea` is a length `n` logical value
               showArea <- gh['showArea'][aesthetic$index]

               point_size <- as_ggplot_size(aesthetic$size,
                                            margin = ggplot2::GeomPolygon$default_aes$size)
               size[id] <- point_size

               if(!selectedOnTop && lenUniqueTypes == 1) {
                 if(all(showArea) || all(!showArea)) {
                   NULL
                 } else {
                   warning("To preserve the elements order, `showArea` must be either TRUE or FALSE. " ,
                           "The `showArea` is set TRUE",
                           call. = FALSE)
                   showArea <- rep(TRUE, length(id))
                 }
               }

               if(sum(!showArea) > 0) {
                 ggObj <- ggObj +
                   ggmulti::geom_polygon_glyph(
                     data = data.frame(x = aesthetic$x[!showArea],
                                       y = aesthetic$y[!showArea],
                                       color = aesthetic$color[!showArea],
                                       size = point_size[!showArea]),
                     mapping = ggplot2::aes(x = x,
                                            y = y,
                                            color = color,
                                            size = size),
                     fill = NA,
                     linewidth = gh['linewidth'][aesthetic$index][!showArea],
                     polygon_x = gh['x'][aesthetic$index][!showArea],
                     polygon_y = lapply(gh['y'][aesthetic$index], function(y) -y)[!showArea]
                   )
               }

               if(sum(showArea) > 0) {
                 ggObj <- ggObj +
                   ggmulti::geom_polygon_glyph(
                     data = data.frame(x = aesthetic$x[showArea],
                                       y = aesthetic$y[showArea],
                                       fill = aesthetic$color[showArea],
                                       size = point_size[showArea]),
                     mapping = ggplot2::aes(x = x,
                                            y = y,
                                            fill = fill,
                                            size = size),
                     linewidth = gh['linewidth'][aesthetic$index][showArea],
                     polygon_x = gh['x'][aesthetic$index][showArea],
                     polygon_y = lapply(gh['y'][aesthetic$index], function(y) -y)[showArea]
                   )
               }
             },
             "serialaxes" = {

               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               # loon data will be converted into character by default

               point_size <- as_ggplot_size(aesthetic$size,
                                            margin = ggplot2::GeomLine$default_aes$size)
               size[id] <- point_size

               # `showArea` is a length `1` logical value
               showArea <- gh['showArea']

               if(showArea) {
                 dat <- data.frame(x = aesthetic$x,
                                   y = aesthetic$y,
                                   fill = aesthetic$color,
                                   size = point_size)
                 mapping <- ggplot2::aes(x = x, y = y,
                                         fill = fill,
                                         size = size)

               } else {
                 dat <- data.frame(x = aesthetic$x,
                                   y = aesthetic$y,
                                   color = aesthetic$color,
                                   size = point_size)

                 mapping <- ggplot2::aes(x = x, y = y,
                                         color = color,
                                         size = size)
               }

               # make the scaling operation is applied on the whole data set
               # rather the subset of it
               serialaxes.data <- get_scaledData(char2num.data.frame(gh['data']),
                                                 scaling = gh['scaling'],
                                                 as.data.frame = TRUE)[aesthetic$index, ]

               ggObj <- ggObj +
                 ggmulti::geom_serialaxes_glyph(
                   data = dat,
                   mapping = mapping,
                   serialaxes.data = serialaxes.data,
                   axes.sequence = gh['sequence'],
                   scaling = "none",
                   andrews = gh['andrews'],
                   axes.layout = gh['axesLayout'],
                   show.axes = gh['showAxes'],
                   linewidth = gh['linewidth'][aesthetic$index],
                   show.enclosing = gh['showEnclosing'],
                   axescolour = as_hex6color(gh['axesColor']),
                   bboxcolour = as_hex6color(gh['bboxColor'])
                 )
             },
             "text" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               label <- gh["text"][aesthetic$index]

               text_size <- as_ggplot_size(aesthetic$size)
               # update size by text adjustment
               size[id] <- text_size

               ggObj <- ggObj +
                 ggplot2::geom_text(
                   data = data.frame(x = aesthetic$x,
                                     y = aesthetic$y,
                                     color = aesthetic$color,
                                     size = text_size,
                                     label = label),
                   mapping = ggplot2::aes(x = x, y = y,
                                          label = label,
                                          color = color,
                                          size = size)
                 )
             },
             "primitive_glyph" = {

               point_pch <- glyph_to_pch(aesthetic$glyph)
               bounded_id <- point_pch %in% 21:24

               xx <- aesthetic$x
               yy <- aesthetic$y

               point_size <- as_ggplot_size(aesthetic$size)
               size[id] <- point_size

               if(!selectedOnTop && lenUniqueTypes == 1) {

                 ggObj <- ggObj +
                   ggplot2::geom_point(
                     data = data.frame(x = xx,
                                       y = yy,
                                       size = point_size,
                                       color = aesthetic$color,
                                       fill = aesthetic$color),
                     mapping = ggplot2::aes(x = x,
                                            y = y,
                                            colour = color,
                                            size = size,
                                            fill = fill),
                     shape = point_pch
                   )

               } else {

                 if(sum(bounded_id, na.rm = TRUE) > 0) {

                   for(p in unique(point_pch[bounded_id])) {

                     pid <- point_pch[bounded_id] == p

                     ggObj <- ggObj +
                       ggplot2::geom_point(
                         data = data.frame(x = xx[bounded_id][pid],
                                           y = yy[bounded_id][pid],
                                           size = point_size[bounded_id][pid],
                                           fill = aesthetic$color[bounded_id][pid]),
                         mapping = ggplot2::aes(x = x,
                                                y = y,
                                                size = size,
                                                fill = fill),
                         shape = p
                       )
                   }
                 }

                 if(sum(!bounded_id, na.rm = TRUE) > 0) {

                   ggObj <- ggObj +
                     ggplot2::geom_point(
                       data = data.frame(x = xx[!bounded_id],
                                         y = yy[!bounded_id],
                                         color = aesthetic$color[!bounded_id],
                                         size = point_size[!bounded_id]),
                       mapping = ggplot2::aes(x = x,
                                              y = y,
                                              color = color,
                                              size = size),
                       shape = point_pch[!bounded_id]
                     )
                 }

               }

             },
             "pointrange" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               # showArea
               point_pch <- ifelse(gh["showArea"], 1, 16)

               point_size <- as_ggplot_size(aesthetic$size,
                                            margin = ggplot2::GeomPointrange$default_aes$size)
               size[id] <- point_size

               ggObj <- ggObj +
                 ggplot2::geom_pointrange(
                   data = data.frame(x = aesthetic$x,
                                     y = aesthetic$y,
                                     ymin = gh["ymin"][aesthetic$index],
                                     ymax = gh["ymax"][aesthetic$index],
                                     color = aesthetic$color,
                                     size = point_size),
                   mapping = ggplot2::aes(x = x, y = y,
                                          color = color,
                                          size = size,
                                          ymin = ymin,
                                          ymax = ymax),
                   pch = point_pch
                 )
             },
             "image" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               tcl_img <- gh['images'][aesthetic$index]

               point_size <- as_ggplot_size(aesthetic$size,
                                            ggplot2::GeomRect$default_aes$size)
               size[id] <- point_size

               width_p <- height_p <- c()

               images <- lapply(seq(length(tcl_img)),
                                function(i) {

                                  height <- as.numeric(tcltk::tcl("image", "height", tcl_img[i]))
                                  width <- as.numeric(tcltk::tcl("image", "width", tcl_img[i]))

                                  area <- as.numeric(tcltk::tcl("::loon::map_image_size", point_size[i]))

                                  scale <- sqrt(area/(width*height))

                                  image_w <- floor(scale*width)
                                  image_h <- floor(scale*height)

                                  width_p[i] <<- image_w
                                  height_p[i] <<- image_h

                                  scaled_img <- as.character(tcltk::tkimage.create("photo"))
                                  tcltk::tcl(tcltk::tcl("set", "::loon::Options(image_scale)"),
                                             tcl_img[i],
                                             image_w,
                                             image_h,
                                             scaled_img)
                                  # get the scaled_image
                                  image <- tcl_img_2_r_raster(scaled_img)
                                  tcl("image", "delete", scaled_img)
                                  image
                                })

               ggObj <- ggObj +
                 ggmulti::geom_image_glyph(
                   data = data.frame(x = aesthetic$x,
                                     y = aesthetic$y,
                                     size = point_size,
                                     fill = aesthetic$color),
                   mapping = ggplot2::aes(x = x,
                                          y = y,
                                          size = size,
                                          fill = fill),
                   color = aesthetic$color,
                   images = images,
                   imagewidth = adjust_image_size(width_p),
                   imageheight = adjust_image_size(height_p)
                 )
             }
      )
    }
  }

  uni_color <- unique(color[!is.na(color)])
  if(length(uni_color) > 0) {

    ggObj <- ggObj +
      ggplot2::scale_color_manual(values = uni_color,
                                  labels = selection_color_labels(
                                    uni_color
                                  ),
                                  breaks = uni_color) +
      ggplot2::scale_fill_manual(values = uni_color,
                                 labels = selection_color_labels(
                                   uni_color
                                 ),
                                 breaks = uni_color)
  }

  if(length(uni_color) <= 1) {
    ggObj <- ggObj + ggplot2::guides(color = FALSE, fill = FALSE)
  }

  uni_size <- unique(size[!is.na(size)])
  if(length(uni_size) > 0) {
    ggObj <- ggObj +
      ggplot2::scale_size_identity(guide = "legend")
  }

  if(length(uni_size) <= 1)
    ggObj <- ggObj + ggplot2::guides(size = FALSE)

  return(ggObj)
}

scatterplotAsAesFALSE <- function(ggObj, widget, x, y,
                                  glyph, color, size, index, selectedOnTop = TRUE) {

  pch <- glyph_to_pch(glyph)

  if (!any(is.na(pch)) && !any(pch %in% 21:24)) {

    size <- as_ggplot_size(size)

    # No NAs and no points with borders
    ggObj <- ggObj +
      ggplot2::geom_point(
        color = color,
        shape = pch,
        size = size
      )

  } else if (!any(is.na(pch)) && all(pch %in% 21:24)) {

    size <- as_ggplot_size(size)

    # No NAs and ALL points with borders
    ggObj <- ggObj +
      ggplot2::geom_point(
        fill = color,
        size = size,
        color = loon::l_getOption("foreground"),
        shape = pch
      )

  } else {
    # possibly some NAs (means some points are text, polygons, images, etc.)
    # and/or a mix of regular and closed points.
    type <- sapply(glyph, function(glyph) loon::l_glyph_getType(widget, glyph))
    types <- paste(type, names(type), sep = ".")
    uniqueTypes <- unique(types)
    lenTypes <- length(uniqueTypes)

    lenUniqueTypes <- length(uniqueTypes)
    if(lenUniqueTypes > 1 && !selectedOnTop) {
      warning("More than one non-primitive glyphs are detected. ",
              "The selected points will be always on top. ",
              "The displayed order may be different from the original data set order.",
              call. = FALSE)
    }

    for(utypes in uniqueTypes) {

      id <- which(types == utypes)

      aesthetic <- list(
        x = x[id],
        y = y[id],
        glyph = glyph[id],
        color = color[id],
        size = size[id],
        index = index[id]
      )

      utype <- strsplit(utypes, "[.]")[[1L]][1L]

      switch(utype,
             "polygon" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))

               ggObj <- ggObj +
                 do.call(ggmulti::geom_polygon_glyph,
                         remove_null(
                           data = if(lenTypes == 1) {
                             NULL
                           } else {
                             data.frame(x = aesthetic$x,
                                        y = aesthetic$y)
                           },
                           fill = ifelse(gh['showArea'][aesthetic$index],
                                         aesthetic$color, NA),
                           color = aesthetic$color,
                           size = as_ggplot_size(aesthetic$size,
                                                 margin = ggplot2::GeomPolygon$default_aes$size),
                           polygon_x = gh['x'][aesthetic$index],
                           polygon_y = lapply(gh['y'][aesthetic$index], function(y) -y),
                           linewidth = gh['linewidth'][aesthetic$index]
                         )
                 )
             },
             "serialaxes" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               # loon data will be converted into character by default

               serialaxes.data <- get_scaledData(char2num.data.frame(gh['data']),
                                                 scaling = gh['scaling'],
                                                 as.data.frame = TRUE)[aesthetic$index, ]
               ggObj <- ggObj +
                 do.call(
                   ggmulti::geom_serialaxes_glyph,
                   remove_null(
                     data = if(lenTypes == 1) {
                       NULL
                     } else {
                       data.frame(x = aesthetic$x,
                                  y = aesthetic$y)
                     },
                     mapping = ggplot2::aes(x = x, y = y),
                     fill = ifelse(gh['showArea'][aesthetic$index], aesthetic$color, NA),
                     color = aesthetic$color,
                     size = as_ggplot_size(aesthetic$size,
                                           margin = ggplot2::GeomLine$default_aes$size),
                     serialaxes.data = serialaxes.data,
                     axes.sequence = gh['sequence'],
                     scaling = "none",
                     andrews = gh['andrews'],
                     axes.layout = gh['axesLayout'],
                     show.axes = gh['showAxes'],
                     show.enclosing = gh['showEnclosing'],
                     axescolour = as_hex6color(gh['axesColor']),
                     bboxcolour = as_hex6color(gh['bboxColor']),
                     linewidth = gh['linewidth'][aesthetic$index]
                   )
                 )

             },
             "text" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               label <- gh["text"][aesthetic$index]

               ggObj <- ggObj +
                 do.call(
                   ggplot2::geom_text,
                   remove_null(
                     data = if(lenTypes == 1) {
                       NULL
                     }else {
                       data.frame(x = aesthetic$x,
                                  y = aesthetic$y,
                                  label = label)
                     },
                     mapping = ggplot2::aes(label = label),
                     color = aesthetic$color,
                     size = as_ggplot_size(aesthetic$size)
                   )
                 )

             },
             "primitive_glyph" = {

               pch <- glyph_to_pch(aesthetic$glyph)
               bounded_id <- pch %in% 21:24

               xx <- aesthetic$x
               yy <- aesthetic$y

               if(!selectedOnTop && lenUniqueTypes == 1) {

                 ggObj <- ggObj +
                   ggplot2::geom_point(
                     data = data.frame(x = xx,
                                       y = yy),
                     fill = aesthetic$color,
                     pch = pch,
                     size = as_ggplot_size(aesthetic$size),
                     colour = aesthetic$color
                   )

               } else {

                 if(sum(bounded_id, na.rm = TRUE) != 0) {

                   ggObj <- ggObj +
                     ggplot2::geom_point(
                       data = data.frame(x = xx[bounded_id],
                                         y = yy[bounded_id]),
                       fill = aesthetic$color[bounded_id],
                       pch = pch[bounded_id],
                       size = as_ggplot_size(aesthetic$size[bounded_id]),
                       colour = loon::l_getOption("foreground")
                     )
                 }

                 if(sum(!bounded_id, na.rm = TRUE) != 0) {

                   ggObj <- ggObj +
                     ggplot2::geom_point(
                       data = data.frame(x = xx[!bounded_id],
                                         y = yy[!bounded_id]),
                       color = aesthetic$color[!bounded_id],
                       pch = pch[!bounded_id],
                       size = as_ggplot_size(aesthetic$size[!bounded_id])
                     )
                 }
               }
             },
             "pointrange" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))

               # showArea
               pch <- ifelse(gh["showArea"], 1, 19)
               ymin <- gh["ymin"][aesthetic$index]
               ymax <- gh["ymax"][aesthetic$index]

               ggObj <- ggObj +
                 do.call(
                   ggplot2::geom_pointrange,
                   remove_null(
                     data = if(lenTypes == 1) {
                       NULL
                     } else {
                       data.frame(x = aesthetic$x,
                                  y = aesthetic$y,
                                  ymin = ymin,
                                  ymax = ymax)
                     },
                     mapping = ggplot2::aes(ymin = ymin, ymax = ymax),
                     color = aesthetic$color,
                     pch = pch,
                     size = as_ggplot_size(aesthetic$size,
                                           margin = ggplot2::GeomPointrange$default_aes$size)
                   )
                 )
             },
             "image" = {
               gh <- loon::l_create_handle(c(widget, aesthetic$glyph[1L]))
               tcl_img <- gh['images'][aesthetic$index]
               image_size <- as_ggplot_size(aesthetic$size,
                                            ggplot2::GeomRect$default_aes$size)
               width_p <- height_p <- c()

               images <- lapply(seq(length(tcl_img)),
                                function(i) {

                                  height <- as.numeric(tcltk::tcl("image", "height", tcl_img[i]))
                                  width <- as.numeric(tcltk::tcl("image", "width", tcl_img[i]))

                                  area <- as.numeric(tcltk::tcl("::loon::map_image_size", image_size[i]))

                                  scale <- sqrt(area/(width*height))

                                  image_w <- floor(scale*width)
                                  image_h <- floor(scale*height)

                                  width_p[i] <<- image_w
                                  height_p[i] <<- image_h

                                  scaled_img <- as.character(tcltk::tkimage.create("photo"))
                                  tcltk::tcl(tcltk::tcl("set", "::loon::Options(image_scale)"),
                                             tcl_img[i],
                                             image_w,
                                             image_h,
                                             scaled_img)
                                  # get the scaled_image
                                  image <- tcl_img_2_r_raster(scaled_img)
                                  tcl("image", "delete", scaled_img)
                                  image
                                })

               ggObj <- ggObj +
                 do.call(
                   ggmulti::geom_image_glyph,
                   remove_null(
                     data = if(lenTypes == 1) {
                       NULL
                     } else {
                       data.frame(x = aesthetic$x,
                                  y = aesthetic$y)
                     },
                     fill = aesthetic$color,
                     color = aesthetic$color,
                     size = image_size,
                     images = images,
                     imagewidth = adjust_image_size(width_p),
                     imageheight = adjust_image_size(height_p)
                   )
                 )
             }
      )
    }
  }
  return(ggObj)
}

