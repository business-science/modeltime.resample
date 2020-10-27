
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
        dplyr::select(id, .model_id, .model_desc, .predictions) %>%

        dplyr::rename(.resample_id = id) %>%

        # # Add .resample_id
        # dplyr::group_split(.model_id) %>%
        # purrr::map(tibble::rowid_to_column, var = ".resample_id") %>%
        # dplyr::bind_rows() %>%

        # Add .row_id - Needed to compare observations between models
        tidyr::unnest(.predictions) %>%
        dplyr::group_split(.model_id) %>%
        purrr::map( tibble::rowid_to_column, var = ".row_id") %>%
        dplyr::bind_rows()
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
