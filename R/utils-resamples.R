
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

    # Checks
    if (!inherits(object, "data.frame")) rlang::abort("object must be a data.frame")
    if (!".resample_results" %in% names(object)) rlang::abort("object must contain a column, '.resample_results'. Try using `modeltime_fit_resamples()` first. ")

    # Unnest
    object %>%
        dplyr::select(-.model) %>%
        tidyr::unnest(.resample_results) %>%
        dplyr::select(.model_id, .model_desc, .predictions) %>%

        # Add .resample_id
        dplyr::group_split(.model_id) %>%
        purrr::map( tibble::rowid_to_column, var = ".resample_id") %>%
        dplyr::bind_rows() %>%

        # Add .row_id - Needed to compare observations between models
        tidyr::unnest(.predictions) %>%
        dplyr::group_split(.model_id) %>%
        purrr::map( tibble::rowid_to_column, var = ".row_id") %>%
        dplyr::bind_rows()
}
