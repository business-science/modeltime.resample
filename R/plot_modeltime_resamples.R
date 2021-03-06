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
#' @param .summary_line_size  Controls the summary line size. Default: 0.5.
#' @param .summary_line_type  Controls the summary line type. Default: 1.
#' @param .summary_line_alpha Controls the summary line opacity. Default: 1 (full opacity).
#' @param .x_intercept        Numeric. Adds an x-intercept at a location (e.g. 0). Default: NULL.
#' @param .x_intercept_color  Controls the x-intercept color. Default: "red".
#' @param .x_intercept_size   Controls the x-intercept size. Default: 0.5.
#'
#' @details
#'
#' __Default Accuracy Metrics__
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
#' __Summary Function__
#'
#' Users can supply a single summary function (e.g. `mean`) to summarize the
#' resample metrics by each model.
#'
#' @examples
#'
#' m750_training_resamples_fitted %>%
#'     plot_modeltime_resamples(
#'         .interactive = FALSE
#'     )
#'
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

    # Checks
    if (!inherits(.data, "data.frame")) {
        rlang::abort(stringr::str_glue("No method for {class(.data)[1]}. Expecting the output of 'modeltime_fit_resamples()'."))
    }

    if (!all(c(".resample_results") %in% names(.data))) {
        rlang::abort("Expecting '.resample_results' to be in the data frame. Try using 'modeltime_fit_resamples()' to return a data frame with the appropriate structure.")
    }

    summary_fn_partial <- purrr::partial(.f = .summary_fn, ...)

    # Data ----

    # Unnest resamples column
    resample_results_tbl <- .data %>%
        dplyr::ungroup() %>%
        unnest_modeltime_resamples()

    # Target Variable is the name in the data
    target_text <- resample_results_tbl %>% get_target_text_from_resamples(column_before_target = ".row")
    target_var  <- rlang::sym(target_text)

    # Prepare Data for Plot
    data_prepared <- resample_results_tbl  %>%
        dplyr::rename(.value = !! target_var) %>%

        dplyr::mutate(.model_desc = ifelse(!is.na(.model_id), stringr::str_c(.model_id, "_", .model_desc), .model_desc)) %>%
        dplyr::mutate(.model_desc = .model_desc %>% stringr::str_trunc(width = .legend_max_width)) %>%
        dplyr::mutate(.model_desc = forcats::as_factor(.model_desc)) %>%

        dplyr::group_by(.resample_id, .model_desc) %>%
        .metric_set(.value, .pred) %>%
        dplyr::ungroup() %>%

        dplyr::mutate(.metric = forcats::as_factor(.metric)) %>%

        dplyr::group_by(.model_desc, .metric) %>%
        dplyr::mutate(..summary_fn = summary_fn_partial(.estimate)) %>%
        dplyr::ungroup()


    # Plot ----
    g <- data_prepared %>%
        ggplot2::ggplot(ggplot2::aes(x = .estimate, y = .resample_id, color = .model_desc))

    # Add facets
    g <- g +
        ggplot2::facet_wrap(~ .metric, scales = .facet_scales, ncol = .facet_ncol)

    # Add points?
    if (.point_show) {
        g <- g +
            ggplot2::geom_point(size  = .point_size,
                                alpha = .point_alpha,
                                shape = .point_shape)
    }

    # Add summary lines?
    if (.summary_line_show) {
        g <- g +
            ggplot2::geom_vline(ggplot2::aes(xintercept = ..summary_fn, color = .model_desc),
                                size     = .summary_line_size,
                                alpha    = .summary_line_alpha,
                                linetype = .summary_line_type)
    }

    # Add a X-Intercept if desired
    if (!is.null(.x_intercept)) {
        g <- g +
            ggplot2::geom_vline(xintercept = .x_intercept,
                                color      = .x_intercept_color,
                                size       = .x_intercept_size)
    }

    # Add theme & labs
    g <- g +
        theme_tq() +
        scale_color_tq() +
        ggplot2::labs(x = .x_lab, y = .y_lab, title = .title, color = .color_lab)

    # Show Legend?
    if (!.legend_show) {
        g <- g +
            ggplot2::theme(legend.position = "none")
    }

    # Interactive?
    if (.interactive) {
        p <- plotly::ggplotly(g)
        return(p)
    } else {
        return(g)
    }

}
