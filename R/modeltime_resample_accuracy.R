# RESAMPLE ACCURACY ----

#' Calculate Accuracy Metrics from Modeltime Resamples
#'
#' This is a wrapper for `yardstick` that simplifies time
#' series regression accuracy metric calculations from
#' a Modeltime Table that has been resampled and fitted using
#' [modeltime_fit_resamples()].
#'
#' @inheritParams modeltime::modeltime_accuracy
#' @param object a Modeltime Table with a column '.resample_results' (the output of [modeltime_fit_resamples()])
#' @param summary_fns One or more functions to analyze resamples. The default is `mean()`.
#'  Possible values are:
#'  * NULL, to returns the resamples untransformed.
#'  * A function, e.g. mean.
#'  * A purrr-style lambda, e.g. ~ mean(.x, na.rm = TRUE)
#'  * A list of functions/lambdas, e.g. list(mean = mean, sd = sd)
#' @param ... Additional arguments passed to the function calls in `summary_fns`.
#'
#' @details
#'
#' #' __Default Accuracy Metrics__
#'
#' The following accuracy metrics are included by default via [modeltime::default_forecast_accuracy_metric_set()]:
#'
#' - MAE - Mean absolute error, [yardstick::mae()]
#' - MAPE - Mean absolute percentage error, [yardstick::mape()]
#' - MASE  - Mean absolute scaled error, [yardstick::mase()]
#' - SMAPE - Symmetric mean absolute percentage error, [yardstick::smape()]
#' - RMSE  - Root mean squared error, [yardstick::rmse()]
#' - RSQ   - R-squared, [yardstick::rsq()]
#'
#' __Summary Functions__
#'
#' By default, `modeltime_resample_accuracy()` returns
#' the _average_ accuracy metrics for each resample prediction.
#'
#' The user can change this default behavior using `summary_fns`.
#' Simply pass one or more Summary Functions. Internally, the functions are passed to
#' `dplyr::across(.fns)`, which applies the summary functions.
#'
#' __Returning Unsummarized Results__
#'
#' You can pass `summary_fns = NULL` to return unsummarized results by `.resample_id`.
#'
#' __Professional Tables (Interactive & Static)__
#'
#' Use [modeltime::table_modeltime_accuracy()] to format the results for reporting in
#' `reactable` (interactive) or `gt` (static) formats, which are perfect for
#' Shiny Apps (interactive) and PDF Reports (static).
#'
#' @examples
#' library(modeltime)
#'
#' # Mean (Default)
#' m750_training_resamples_fitted %>%
#'     modeltime_resample_accuracy() %>%
#'     table_modeltime_accuracy(.interactive = FALSE)
#'
#' # Mean and Standard Deviation
#' m750_training_resamples_fitted %>%
#'     modeltime_resample_accuracy(
#'         summary_fns = list(mean = mean, sd = sd)
#'     ) %>%
#'     table_modeltime_accuracy(.interactive = FALSE)
#'
#' # When summary_fns = NULL, returns the unsummarized resample results
#' m750_training_resamples_fitted %>%
#'     modeltime_resample_accuracy(
#'         summary_fns = NULL
#'     )
#'
#' @export
modeltime_resample_accuracy <- function(object, summary_fns = mean, metric_set = default_forecast_accuracy_metric_set(), ...) {

    # Checks
    if (!inherits(object, "data.frame")) rlang::abort("object must be a data.frame")
    if (!".resample_results" %in% names(object)) rlang::abort("object must contain a column, '.resample_results'. Try using `modeltime_fit_resamples()` first.")

    # Unnest resamples column
    resample_results_tbl <- unnest_modeltime_resamples(object)

    # Target Variable is the name in the data
    if (utils::packageVersion("tune") >= "1.3.0.9006") {
        target_text <- resample_results_tbl %>%
            get_target_text_from_resamples(column_before_target = ".model_desc")
    } else {
        target_text <- resample_results_tbl %>%
            get_target_text_from_resamples(column_before_target = ".row")
    }
    target_var  <- rlang::sym(target_text)

    # Apply accuracy metrics to resamples
    ret <- resample_results_tbl %>%
        dplyr::mutate(.type = "Resamples") %>%
        dplyr::group_by(.model_id, .model_desc, .resample_id, .type) %>%
        modeltime::summarize_accuracy_metrics(!! target_var, .pred, metric_set = metric_set)

    # If summary functions provided, apply summary functions
    if (!is.null(summary_fns)) {

        ret <- ret %>%
            dplyr::select(-.resample_id) %>%
            dplyr::group_by(.model_id, .model_desc, .type) %>%
            dplyr::mutate(n = dplyr::n()) %>%
            dplyr::group_by(.model_id, .model_desc, .type, n) %>%
            dplyr::summarise(
                dplyr::across(.cols = dplyr::everything(), .fns = summary_fns, ...),
                .groups = "drop"
            )

    }

    return(ret)


}




