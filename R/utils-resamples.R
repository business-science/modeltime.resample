
# RESAMPLE UTILITIES -----

#' Unnests the Results of Modeltime Fit Resamples
#'
#' An internal function used by [modeltime_resample_accuracy()].
#'
#' @param object A Modeltime Table that has a column '.resample_results'
#'
#' @return
#' Tibble with columns for '.row_id', '.resample_id', '.model_id', '.model_desc', '.pred',
#' '.row', and actual value name from the data set
#'
#' @details
#'
#' The following data columns are unnested and prepared for evaluation:
#' - `.row_id` - A unique identifier to compare observations.
#' - `.resample_id` - A unique identifier given to the resample iteration.
#' - `.model_id` and `.model_desc` - Modeltime Model ID and Description
#' - `.pred` - The Resample Prediction Value
#' - `.row` - The actual row value from the original dataset
#' - _Actual Value Column_ - The name changes to target variable name in dataset
#'
#' @examples
#'
#' # The .resample_results column is deeply nested
#' m750_training_resamples_fitted
#'
#' # Unnest and prepare the resample predictions for evaluation
#' unnest_modeltime_resamples(m750_training_resamples_fitted)
#'
#' @export
unnest_modeltime_resamples <- function(object) {

    # ---- checks ----
    if (!inherits(object, "data.frame")) {
        rlang::abort(message = "object must be a data.frame")
    }
    if (!(".resample_results" %in% names(object))) {
        rlang::abort(message = "object must contain a column, '.resample_results'. Try using `modeltime_fit_resamples()` first.")
    }

    # helpers
    pick_first <- function(candidates, nms) {
        f <- candidates[candidates %in% nms]
        if (length(f)) f[[1]] else NA_character_
    }

    ensure_predictions <- function(x) {
        if (!is.data.frame(x)) return(x)
        if (".predictions" %in% names(x)) return(x)

        preds <- try(tune::collect_predictions(x), silent = TRUE)
        if (!inherits(preds, "try-error") && is.data.frame(preds) && nrow(preds) > 0) {
            idcol <- pick_first(c("id", ".id", ".resample_id"), names(preds))
            if (!is.na(idcol)) {
                nested <- preds %>%
                    dplyr::group_by(!!rlang::sym(idcol)) %>%
                    tidyr::nest() %>%
                    dplyr::rename(.predictions = data)

                x <- x %>% dplyr::left_join(nested, by = stats::setNames(idcol, idcol))
            }
        }
        x
    }

    # ---- try to ensure predictions model-by-model first (so we can drop failures cleanly) ----
    object2 <- object %>%
        dplyr::mutate(.resample_results = purrr::map(.resample_results, ensure_predictions))

    # mark which rows have predictions
    has_preds <- purrr::map_lgl(
        object2$.resample_results,
        ~ is.data.frame(.x) && any(c(".predictions", ".preds", ".prediction") %in% names(.x))
    )

    # keep successful rows, but keep failed ones aside for messaging
    failed_rows <- object2[!has_preds, c(".model_id", ".model_desc", ".resample_results"), drop = FALSE]
    object2 <- object2[has_preds, , drop = FALSE]

    # if nothing succeeded, emit a single actionable error listing the failures/notes
    if (nrow(object2) == 0) {
        notes <- try({
            purrr::map_chr(failed_rows$.resample_results, function(x) {
                if (is.data.frame(x) && ".notes" %in% names(x)) paste0(x$.notes, collapse = "; ") else "No details"
            })
        }, silent = TRUE)
        notes <- if (inherits(notes, "try-error")) "No details" else notes
        msg <- paste0(
            "No resample predictions are available for any models.\n\n",
            "Models and notes:\n",
            paste0("- [", failed_rows$.model_id, "] ", failed_rows$.model_desc, ": ", notes, collapse = "\n"), "\n\n",
            "Hints:\n",
            "- Ensure engines are installed (e.g., prophet),\n",
            "- Use control = tune::control_resamples(save_pred = TRUE), and\n",
            "- Verify `modeltime_fit_resamples()` forwards `control` to `tune::fit_resamples()`."
        )
        rlang::abort(message = msg)
    }

    # ---- unnest the successful subset ----
    outer <- object2 %>%
        dplyr::select(-dplyr::any_of(".model")) %>%
        tidyr::unnest(.resample_results, keep_empty = TRUE)

    id_outer  <- pick_first(c("id", ".id", ".resample_id"), names(outer))
    pred_col  <- pick_first(c(".predictions", ".preds", ".prediction"), names(outer))

    cols_outer <- c(id_outer, ".model_id", ".model_desc", pred_col)
    cols_outer <- cols_outer[!is.na(cols_outer)]

    outer <- outer %>%
        dplyr::select(dplyr::any_of(cols_outer))

    if (!is.na(id_outer) && id_outer != ".resample_id") {
        outer <- outer %>% dplyr::rename(.resample_id = !!rlang::sym(id_outer))
    }

    if (is.na(pred_col)) {
        rlang::abort(message = "Unexpected: successful rows still lack predictions after unnesting.")
    }

    res <- outer %>%
        tidyr::unnest(!!rlang::sym(pred_col), keep_empty = TRUE)

    if (!(".resample_id" %in% names(res))) {
        id_inner <- pick_first(c("id", ".id", ".resample_id"), names(res))
        if (!is.na(id_inner) && id_inner != ".resample_id") {
            res <- res %>% dplyr::rename(.resample_id = !!rlang::sym(id_inner))
        }
    }

    if (!(".resample_id" %in% names(res))) {
        res <- res %>%
            dplyr::group_by(.model_id, .model_desc) %>%
            dplyr::mutate(.resample_id = dplyr::cur_group_id()) %>%
            dplyr::ungroup()
    }

    res <- res %>%
        dplyr::group_by(.model_id, .model_desc, .resample_id) %>%
        dplyr::mutate(.row_id = dplyr::row_number()) %>%
        dplyr::ungroup()

    res
}







# UTILITIES ----

#' Gets the target variable as text from unnested resamples
#'
#' An internal function used by [unnest_modeltime_resamples()].
#'
#' @param data Unnested resample results
#' @param column_before_target The text column located before the target variable.
#'  This is ".row".
#'
#'
#' @examples
#'
#' # The .resample_results column is deeply nested
#' m750_training_resamples_fitted
#'
#' # Unnest and prepare the resample predictions for evaluation
#' unnest_modeltime_resamples(m750_training_resamples_fitted) %>%
#'     get_target_text_from_resamples()
#'
#' @export
get_target_text_from_resamples <- function(data, column_before_target = ".row") {

    names_data <- names(data)

    is_before_target <- names_data %>%
        stringr::str_detect(stringr::str_glue("^{column_before_target}$"))

    loc <- seq_along(names_data)[is_before_target]

    return(names_data[loc + 1])
}
