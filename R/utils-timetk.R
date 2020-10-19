#' Time Series Resampling Sets and Plans
#'
#' @description
#'
#' These resampling tools are exported from the `timetk` package.
#'
#' - [timetk::time_series_cv()]: Creates resample sets using time series cross validation
#'
#' - [timetk::time_series_split()]: Makes an initial time series split
#'
#' - [timetk::plot_time_series_cv_plan()]: Plots a cross validation plan
#'
#' - [timetk::tk_time_series_cv_plan()]: Unnests a cross validation plan
#'
#' @examples
#'
#' # Generate Time Series Resamples
#' resamples_tscv <- time_series_cv(
#'     data        = m750,
#'     assess      = "2 years",
#'     initial     = "5 years",
#'     skip        = "2 years",
#'     slice_limit = 4
#' )
#'
#' resamples_tscv
#'
#' # Visualize the Resample Sets
#' resamples_tscv %>%
#'     tk_time_series_cv_plan() %>%
#'     plot_time_series_cv_plan(
#'         date, value,
#'         .facet_ncol  = 2,
#'         .interactive = FALSE
#'     )
#'
#' @md
#' @name time_series_cv
#' @keywords internal
#' @importFrom timetk time_series_cv time_series_split plot_time_series_cv_plan tk_time_series_cv_plan
#' @aliases time_series_cv time_series_split plot_time_series_cv_plan tk_time_series_cv_plan
#' @export time_series_cv time_series_split plot_time_series_cv_plan tk_time_series_cv_plan
NULL
