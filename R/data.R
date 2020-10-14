#' Time Series Cross Validation Resample Predictions (Results) from the M750 Data (Training Set)
#'
#' @format
#' A Modeltime Table that has been fitted to resamples with predictions in the `.resample_results` column
#'
#' @details
#'
#' ``` {r eval = FALSE}#'
#' m750_training_resamples_fitted <- m750_models %>%
#'     modeltime_fit_resamples(
#'         resamples = m750_training_resamples,
#'         control   = control_resamples(verbose = T)
#'     )
#' ```
#'
#' @seealso
#' - [modeltime::m750_models]
#' - [modeltime::m750_training_resamples]
#'
#' @examples
#'
#' m750_training_resamples_fitted
#'
#'
#'
"m750_training_resamples_fitted"
