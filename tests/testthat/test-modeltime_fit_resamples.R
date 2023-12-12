context("TEST: modeltime_fit_resamples()")

# Machine Learning
library(tidymodels)
library(modeltime)
library(modeltime.resample)

# Core Packages
library(timetk)
library(lubridate)

# SETUP ----

resamples_tscv <- training(m750_splits) %>%
    time_series_cv(assess = "2 years", initial = "5 years", skip = "2 years", slice_limit = 2)

# Workflow
m750_models_resample <- m750_models %>%
    modeltime_fit_resamples(resamples_tscv, control = control_resamples(verbose = F))

# Parsnip
prophet_fit <- prophet_reg() %>%
    set_engine("prophet") %>%
    fit(value ~ date, training(m750_splits))

m750_prophet_resample <- modeltime_table(prophet_fit) %>%
    modeltime_fit_resamples(resamples_tscv, control = control_resamples(verbose = F))

# MODELTIME FIT RESAMPLES ----

test_that("Structure: modeltime_fit_resamples()", {

    # Structure

    expect_true(".resample_results" %in% names(m750_models_resample))
    expect_true(".resample_results" %in% names(m750_prophet_resample))

    # Workflow
    resamples_unnested <- unnest_modeltime_resamples(m750_models_resample)
    expect_true(all(c(".model_id", ".model_desc", ".pred") %in% names(resamples_unnested)))

    # Parsnip
    resamples_unnested <- unnest_modeltime_resamples(m750_prophet_resample)
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

    # NULL summary function
    resample_null <- m750_models_resample %>%
        modeltime_resample_accuracy(summary_fns = NULL)

    expect_equal(nrow(resample_null), 6)
    expect_equal(ncol(resample_null), 10)


    # Interactive Tables
    table_reactable <- resample_accuracy %>%
        table_modeltime_accuracy(.interactive = TRUE)

    expect_s3_class(table_reactable, "reactable")

    # Static Tables
    table_gt <- resample_accuracy %>%
        table_modeltime_accuracy(.interactive = FALSE)

    expect_s3_class(table_gt, "gt_tbl")

})

# RESAMPLE PLOT ----

test_that("plot_modeltime_resamples() works", {

    # Interactive
    p <- m750_models_resample %>%
        plot_modeltime_resamples(.interactive = TRUE)

    expect_s3_class(p, "plotly")

    # Static
    g <- m750_models_resample %>%
        plot_modeltime_resamples(.interactive = FALSE)

    expect_s3_class(g, "ggplot")

})

