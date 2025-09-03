# PLOT MODELTIME RESAMPLES ----

#' Interactive Resampling Accuracy Plots
#'
#' A convenient plotting function for visualizing resampling accuracy by
#' resample set for each model in a Modeltime Table.
#'
#' @inheritParams modeltime::plot_modeltime_forecast
#' @param .data A modeltime table that includes a column `.resample_results` containing
#'  the resample results. See [modeltime_fit_resamples()] for more information.
#' @param .metric_set  A `yardstick::metric_set()` that is used to summarize
#'  one or more forecast accuracy (regression) metrics.
#'  See [modeltime::default_forecast_accuracy_metric_set()] for defaults.
#' @param .summary_fn A single summary function that is applied to aggregate the
#'  metrics across resample sets. Default: `mean`.
#' @param ... Additional arguments passed to the `.summary_fn`.
#' @param .facet_ncol Default: `NULL`. The number of facet columns.
#' @param .facet_scales Default: `free_x`.
#' @param .point_show Whether or not to show the individual points for each combination
#'  of models and metrics. Default: `TRUE`.
#' @param .point_size Controls the point size. Default: 1.
#' @param .point_shape Controls the point shape. Default: 16.
#' @param .point_alpha Controls the opacity of the points. Default: 1 (full opacity).
#' @param .summary_line_show Whether or not to show the summary lines. Default: `TRUE`.
#' @param .summary_line_size  Controls the summary line width. Default: 0.5.
#' @param .summary_line_type  Controls the summary line type. Default: 1.
#' @param .summary_line_alpha Controls the summary line opacity. Default: 1 (full opacity).
#' @param .x_intercept        Numeric. Adds an x-intercept at a location (e.g. 0). Default: NULL.
#' @param .x_intercept_color  Controls the x-intercept color. Default: "red".
#' @param .x_intercept_size   Controls the x-intercept linewidth. Default: 0.5.
#'
#' @details
#' See [modeltime::default_forecast_accuracy_metric_set()] for defaults.
#'
#' @examples
#' m750_training_resamples_fitted %>%
#'     plot_modeltime_resamples(
#'         .interactive = FALSE
#'     )
#'
#' @export
plot_modeltime_resamples <- function(.data,
                                     .metric_set = default_forecast_accuracy_metric_set(),

                                     .summary_fn = mean,
                                     ...,

                                     .facet_ncol   = NULL,
                                     .facet_scales = "free_x",

                                     .point_show  = TRUE,
                                     .point_size  = 1,
                                     .point_shape = 16,
                                     .point_alpha = 1,

                                     .summary_line_show  = TRUE,
                                     .summary_line_size  = 0.5,
                                     .summary_line_type  = 1,
                                     .summary_line_alpha = 1,

                                     .x_intercept       = NULL,
                                     .x_intercept_color = "red",
                                     .x_intercept_size  = 0.5,

                                     .legend_show      = TRUE,
                                     .legend_max_width = 40,

                                     .title = "Resample Accuracy Plot", .x_lab = "", .y_lab = "",
                                     .color_lab = "Legend",
                                     .interactive = TRUE) {

    # ---- checks ----
    if (!inherits(.data, "data.frame")) {
        rlang::abort(message = stringr::str_glue("No method for {class(.data)[1]}. Expecting the output of 'modeltime_fit_resamples()'."))
    }
    if (!(".resample_results" %in% names(.data))) {
        rlang::abort(message = "Expecting '.resample_results' to be in the data frame. Try using 'modeltime_fit_resamples()' first.")
    }

    summary_fn_partial <- purrr::partial(.f = .summary_fn, ...)

    # helpers -----------------------------------------------------------------
    pick_first <- function(candidates, nms) {
        f <- candidates[candidates %in% nms]
        if (length(f)) f[[1]] else NA_character_
    }

    normalize_truth_estimate <- function(df) {
        # Try common names first
        truth_cands <- c(".actual", ".value", "value", "y", "truth", "target")
        pred_cands  <- c(".pred", ".prediction", ".fitted", ".estimate")

        truth_col <- pick_first(truth_cands, names(df))
        pred_col  <- pick_first(pred_cands,  names(df))

        # If still missing truth, infer heuristically:
        if (is.na(truth_col)) {
            reserved <- c(".model_id",".model_desc",".resample_id",".row_id",".config",
                          "id",".id",".resample_results",".predictions",".notes",
                          pred_cands)
            # choose the first non-reserved, non-list column that is numeric
            candidates <- setdiff(names(df), reserved)
            if (length(candidates)) {
                # prefer a column literally named "value" if present in the remainder
                if ("value" %in% candidates) truth_col <- "value"
                else {
                    # pick first numeric column among candidates
                    num_cands <- candidates[vapply(df[candidates], is.numeric, logical(1))]
                    if (length(num_cands)) truth_col <- num_cands[[1]]
                }
            }
        }

        if (is.na(truth_col) || is.na(pred_col)) {
            rlang::abort(message = paste0(
                "Could not identify truth/estimate columns for yardstick metrics.\n",
                "Looked for truth in {", paste(truth_cands, collapse = ", "), "} and ",
                "estimate in {", paste(pred_cands, collapse = ", "), "}.\n",
                "Columns present were: ", paste(names(df), collapse = ", ")
            ))
        }

        df %>%
            dplyr::rename(.actual = !!rlang::sym(truth_col),
                          .pred   = !!rlang::sym(pred_col))
    }

    # data --------------------------------------------------------------------
    resample_results_tbl <- .data %>%
        dplyr::ungroup() %>%
        unnest_modeltime_resamples()

    data_prepared <- resample_results_tbl %>%
        normalize_truth_estimate() %>%
        dplyr::mutate(
            .model_desc = ifelse(!is.na(.model_id),
                                 stringr::str_c(.model_id, "_", .model_desc),
                                 .model_desc),
            .model_desc = stringr::str_trunc(.model_desc, width = .legend_max_width),
            .model_desc = as.factor(.model_desc)
        )

    # compute metrics per resample, then summarise across resamples -----------
    mset <- .metric_set

    metrics_long <- data_prepared %>%
        dplyr::group_by(.resample_id, .model_desc) %>%
        mset(truth = .actual, estimate = .pred) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(.metric = as.factor(.metric)) %>%
        dplyr::group_by(.model_desc, .metric) %>%
        dplyr::mutate(..summary_fn = summary_fn_partial(.estimate)) %>%
        dplyr::ungroup()

    # plot --------------------------------------------------------------------
    g <- ggplot2::ggplot(metrics_long, ggplot2::aes(x = .estimate, y = .resample_id, color = .model_desc)) +
        ggplot2::facet_wrap(~ .metric, scales = .facet_scales, ncol = .facet_ncol)

    if (.point_show) {
        g <- g + ggplot2::geom_point(size = .point_size, alpha = .point_alpha, shape = .point_shape)
    }

    if (.summary_line_show) {
        g <- g + ggplot2::geom_vline(ggplot2::aes(xintercept = ..summary_fn, color = .model_desc),
                                     linewidth = .summary_line_size,
                                     alpha     = .summary_line_alpha,
                                     linetype  = .summary_line_type)
    }

    if (!is.null(.x_intercept)) {
        g <- g + ggplot2::geom_vline(xintercept = .x_intercept,
                                     color      = .x_intercept_color,
                                     linewidth  = .x_intercept_size)
    }

    g <- g + theme_tq() + scale_color_tq()

    g <- g + ggplot2::labs(x = .x_lab, y = .y_lab, title = .title, color = .color_lab)

    if (!.legend_show) {
        g <- g + ggplot2::theme(legend.position = "none")
    }

    if (isTRUE(.interactive) && requireNamespace("plotly", quietly = TRUE)) {
        return(plotly::ggplotly(g))
    }

    g
}
