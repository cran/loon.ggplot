% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/g_getPlots.R
\name{g_getPlots}
\alias{g_getPlots}
\alias{g_getPlots.default}
\alias{g_getPlots.l_pairs}
\title{get \code{ggplot}s}
\usage{
g_getPlots(target, asAes = TRUE, selectedOnTop = TRUE)

\method{g_getPlots}{default}(target, asAes = TRUE, selectedOnTop = TRUE)

\method{g_getPlots}{l_pairs}(target, asAes = TRUE, selectedOnTop = TRUE)
}
\arguments{
\item{target}{the (compound) loon plot}

\item{asAes}{logical; set aesthetics attributes, i.e. `color`, `fill` as
variables (default \code{TRUE}) or general visual properties (\code{FALSE}).
See details}

\item{selectedOnTop}{logical and default is \code{TRUE}; whether to display the
selected points on top. See details.}
}
\value{
a list of \code{ggplot}s.
}
\description{
For the target compound loon plot, determines all the \code{ggplot}s based on
the compound \code{loon} plot.
}
\seealso{
\code{\link{l_getPlots}}, \code{\link{g_getLocations}}
}
