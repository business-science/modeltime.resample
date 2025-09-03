# FIT RESAMPLES ----

#' Fits Models in a Modeltime Table to Resamples
#'
#' Resampled predictions are commonly used for:
#' 1. Analyzing accuracy and stability of models
#' 2. As inputs to Ensemble methods (refer to the `modeltime.ensemble` package)
#'
#' @param object A Modeltime Table
#' @param resamples An `rset` resample object.
#'   Used to generate sub-model predictions for the meta-learner.
#'   See [timetk::time_series_cv()] or [rsample::vfold_cv()] for making resamples.
#' @param control A [tune::control_resamples()] object to provide
#'  control over the resampling process.
#'
#' @return A Modeltime Table (`mdl_time_tbl`) object with a column containing
#'  resample results (`.resample_results`)
#'
#' @details
#'
#' The function is a wrapper for `tune::fit_resamples()` to iteratively train and predict models
#' contained in a Modeltime Table on resample objects.
#' One difference between `tune::fit_resamples()` and `modeltime_fit_resamples()`
#' is that predictions are always returned
#' (i.e. `control = tune::control_resamples(save_pred = TRUE)`). This is needed for
#' `ensemble_model_spec()`.
#'
#' __Resampled Prediction Accuracy__
#'
#' Calculating Accuracy Metrics on models fit to resamples can help
#' to understand the model performance and stability under different
#' forecasting windows. See [modeltime_resample_accuracy()] for
#' getting resampled prediction accuracy for each model.
#'
#'
#' __Ensembles__
#'
#' Fitting and Predicting Resamples is useful in
#' creating Stacked Ensembles using `modeltime.ensemble::ensemble_model_spec()`.
#' The sub-model cross-validation predictions are used as the input to the meta-learner model.
#'
#'
#'
#' @examples
#' library(tidymodels)
#' library(modeltime)
#' library(timetk)
#' library(magrittr)
#'
#' # Make resamples
#' resamples_tscv <- training(m750_splits) %>%
#'     time_series_cv(
#'         assess      = "2 years",
#'         initial     = "5 years",
#'         skip        = "2 years",
#'         # Normally we do more than one slice, but this speeds up the example
#'         slice_limit = 1
#'     )
#'
#' \donttest{
#' # Fit and generate resample predictions
#' m750_models_resample <- m750_models %>%
#'     modeltime_fit_resamples(
#'         resamples = resamples_tscv,
#'         control   = control_resamples(verbose = TRUE)
#'     )
#'
#' # A new data frame is created from the Modeltime Table
#' #  with a column labeled, '.resample_results'
#' m750_models_resample
#' }
#'
#' @export
modeltime_fit_resamples <- function(object, resamples, control = control_resamples()) {

    # Check object
    if (rlang::is_missing(object)) rlang::abort(message = "'object' is missing. Try using 'modeltime_table()' to create a Modeltime Table.")
    if (!inherits(object, "mdl_time_tbl")) rlang::abort(message = "'object' must be a Modeltime Table.")

    # Check resamples
    if (rlang::is_missing(resamples)) rlang::abort(message = "'resamples' is missing. Try using 'timetk::time_series_cv()' or 'rsample::vfold_cv()' to create a resample 'rset' object.")
    if (!inherits(resamples, "rset")) rlang::abort(message = "'resamples' must be an rset object. Try using 'timetk::time_series_cv()' or 'rsample::vfold_cv()' to create an rset.")

    UseMethod("modeltime_fit_resamples", object)
}

#' @export
modeltime_fit_resamples.mdl_time_tbl <- function(object, resamples, control = control_resamples()) {

    data <- object # object is a Modeltime Table

    # Always save predictions
    if (!isTRUE(control$save_pred)) control$save_pred <- TRUE

    # TODO: consider replacing tictoc/progressr with cli progress if desired
    if (isTRUE(control$verbose)) {
        tictoc::tic()
        print(cli::rule("Fitting Resamples", width = 65))
        cli::cat_line()
    }

    # Map fitting of resample
    if (isTRUE(control$verbose)) {
        ret <- map_fit_resamples(data, resamples, control)
    } else {
        suppressMessages({
            ret <- map_fit_resamples(data, resamples, control)
        })
    }

    if (isTRUE(control$verbose)) {
        tictoc::toc()
        cli::cat_line()
    }

    return(ret)
}

# INTERNAL HELPERS ----

# pick first matching name
.pick_first <- function(candidates, nms) {
    f <- candidates[candidates %in% nms]
    if (length(f)) f[[1]] else NA_character_
}

# Ensure the tibble returned by tune::fit_resamples() has a `.predictions` column.
# If missing, rebuild it via tune::collect_predictions() and nest by resample id.
.capture_resample_results <- function(x) {
    if (!is.data.frame(x)) return(x)

    # fast-path if predictions present
    if (".predictions" %in% names(x)) {
        return(
            x %>%
                dplyr::select(dplyr::any_of(c("id", ".id", ".resample_id", ".metrics", ".notes", ".predictions")))
        )
    }

    # Try to reconstruct via collect_predictions()
    preds <- try(tune::collect_predictions(x), silent = TRUE)
    if (!inherits(preds, "try-error") && is.data.frame(preds) && nrow(preds) > 0) {

        idcol <- .pick_first(c("id", ".id", ".resample_id"), names(preds))
        if (!is.na(idcol)) {
            nested <- preds %>%
                dplyr::group_by(!!rlang::sym(idcol)) %>%
                tidyr::nest() %>%
                dplyr::rename(.predictions = data)

            x <- x %>%
                dplyr::left_join(nested, by = stats::setNames(idcol, idcol))
        }
    }

    x %>%
        dplyr::select(dplyr::any_of(c("id", ".id", ".resample_id", ".metrics", ".notes", ".predictions")))
}

map_fit_resamples <- function(data, resamples, control) {

    # safely run mdl_time_fit_resamples; if it errors, keep error message
    safe_mdl_time_fit_resamples <- purrr::safely(
        mdl_time_fit_resamples,
        otherwise = NULL,
        quiet     = FALSE
    )

    # Progress
    p <- progressr::progressor(steps = nrow(data))

    data %>%
        dplyr::ungroup() %>%
        dplyr::mutate(.resample_results = purrr::pmap(
            .l = list(.model, .model_id, .model_desc),
            .f = function(obj, id, desc) {

                p(stringr::str_glue("Model ID = {id} / {max(data$.model_id)}"))
                if (isTRUE(control$verbose)) {
                    cli::cli_li(stringr::str_glue("Model ID: {cli::col_blue(as.character(id))} {cli::col_blue(desc)}"))
                }

                # Ensure RNG exists & is deterministic per model
                ret_safe <- withr::with_seed(123L + as.integer(id),
                                             safe_mdl_time_fit_resamples(
                                                 object    = obj,
                                                 resamples = resamples,
                                                 control   = control
                                             )
                )

                # If an error occurred, return a small tibble with a .notes column
                if (is.null(ret_safe$result)) {
                    note <- if (inherits(ret_safe$error, "error")) conditionMessage(ret_safe$error) else "Unknown error in fit_resamples()"
                    return(tibble::tibble(.notes = note))
                }

                ret <- ret_safe$result

                # Standardize to include `.predictions` if possible
                ret <- .capture_resample_results(ret)

                # If still no predictions and no ids, at least keep .notes
                if (!is.data.frame(ret) || !any(c(".predictions", ".preds", ".prediction") %in% names(ret))) {
                    return(tibble::tibble(.notes = "No predictions available from fit_resamples()"))
                }

                ret
            })
        )
}



# LOW-LEVEL HELPERS ----

#' Modeltime Fit Resample Helpers
#'
#' Used for low-level resample fitting of modeltime, parsnip, and workflow models.
#' These functions are not intended for user use.
#'
#' @inheritParams modeltime_fit_resamples
#'
#' @return A tibble with forecast features
#'
#' @keywords internal
#'
#' @export
mdl_time_fit_resamples <- function(object, resamples, control = control_resamples()) {
    UseMethod("mdl_time_fit_resamples", object)
}

#' @export
#' @importFrom yardstick rmse
mdl_time_fit_resamples.workflow <- function(object, resamples, control = control_resamples()) {

    # UPDATES FOR HARDHAT 1.0.0
    preprocessor    <- workflows::extract_preprocessor(object)
    mld             <- hardhat::mold(preprocessor, preprocessor$template)
    object$pre$mold <- mld
    object$pre$actions$recipe$blueprint <- mld$blueprint

    tune::fit_resamples(
        object    = object,
        resamples = resamples,
        metrics   = yardstick::metric_set(rmse),
        control   = control
    )
}

#' @export
mdl_time_fit_resamples.model_fit <- function(object, resamples, control = control_resamples()) {

    # Get Model Spec & Parsnip Preprocessor
    model_spec  <- object$spec
    form        <- object %>% modeltime::pull_parsnip_preprocessor()
    data        <- resamples %>%
        dplyr::slice(1) %>%
        purrr::pluck(1, 1) %>%
        rsample::training()
    recipe_spec <- recipes::recipe(form, data = data)

    wflw <- workflows::workflow() %>%
        workflows::add_model(model_spec) %>%
        workflows::add_recipe(recipe_spec)

    ret <- tune::fit_resamples(
        object       = wflw,
        resamples    = resamples,
        metrics      = yardstick::metric_set(rmse),
        control      = control
    )

    return(ret)
}
