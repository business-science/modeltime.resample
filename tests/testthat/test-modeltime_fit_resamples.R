context("TEST: modeltime_fit_resamples()")

resamples_tscv <- training(m750_splits) %>%
    time_series_cv(assess = "2 years", initial = "5 years", skip = "2 years", slice_limit = 2)

m750_models_resample <- m750_models %>%
    modeltime_fit_resamples(resamples_tscv, control = control_resamples(verbose = F))

# MODELTIME FIT RESAMPLES ----

test_that("Structure: modeltime_fit_resamples()", {

    # Structure

    expect_true(".resample_results" %in% names(m750_models_resample))

    resamples_unnested <- unnest_resamples(m750_models_resample)
    expect_true(all(c(".model_id", ".model_desc", ".pred") %in% names(resamples_unnested)))

})

# * Checks/Errors ----
test_that("Checks/Errors: modeltime_fit_resamples()", {

    # Object is Missing
    expect_error(modeltime_fit_resamples())

    # Incorrect Object
    expect_error(modeltime_fit_resamples(1))

    # No resamples
    expect_error(modeltime_fit_resamples(m750_models))

    # Needs 'model_spec'
    expect_error({
        modeltime_fit_resamples(m750_models, 1)
    })

})

# MODELTIME RESAMPLE ACCURACY ----

test_that("Structure:: modeltime_resample_accuracy()", {

    # Structure
    resample_accuracy <- m750_models_resample %>%
        modeltime_resample_accuracy()

    expect_equal(nrow(resample_accuracy), 3)
    expect_equal(ncol(resample_accuracy), 10)

    # Multiple functions
    resample_mean_sd <- m750_models_resample %>%
        modeltime_resample_accuracy(summary_fns = list(mean = mean, sd = sd))

    expect_equal(nrow(resample_mean_sd), 3)
    expect_equal(ncol(resample_mean_sd), 16)


})

