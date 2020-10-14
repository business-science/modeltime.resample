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
#'
#' @details
#' By default, `modeltime_resample_accuracy()` returns
#' the _average_ accuracy metrics for each resample prediction.
#'
#' The user can change this default behavior using `summary_fns`.
#' Simply pass one or more Summary Functions. Internally, the functions are passed to
#' `dplyr::across(.fns)`, which applies the summary functions.
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
#' @export
modeltime_resample_accuracy <- function(object, summary_fns = mean, metric_set = default_forecast_accuracy_metric_set()) {

    # Checks
    if (!inherits(object, "data.frame")) rlang::abort("object must be a data.frame")
    if (!".resample_results" %in% names(object)) rlang::abort("object must contain a column, '.resample_results'. Try using `modeltime_fit_resamples()` first.")

    # Unnest resamples column
    predictions_tbl <- unnest_modeltime_resamples(object)

    # Target Variable is the name in the data
    target_text <- names(predictions_tbl) %>% utils::tail(1)
    target_var  <- rlang::sym(target_text)

    ret <- predictions_tbl %>%
        dplyr::mutate(.type = "Resamples") %>%
        dplyr::group_by(.model_id, .model_desc, .resample_id, .type) %>%
        modeltime::summarize_accuracy_metrics(!! target_var, .pred, metric_set = metric_set) %>%
        dplyr::select(-.resample_id) %>%
        dplyr::group_by(.model_id, .model_desc, .type) %>%
        dplyr::mutate(n = dplyr::n()) %>%
        dplyr::group_by(.model_id, .model_desc, .type, n) %>%
        dplyr::summarise(
            dplyr::across(.fns = summary_fns),
            .groups = "drop"
        ) %>%
        dplyr::ungroup()

    return(ret)


}




