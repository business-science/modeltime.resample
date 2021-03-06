% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modeltime_fit_resamples.R
\name{modeltime_fit_resamples}
\alias{modeltime_fit_resamples}
\title{Fits Models in a Modeltime Table to Resamples}
\usage{
modeltime_fit_resamples(object, resamples, control = control_resamples())
}
\arguments{
\item{object}{A Modeltime Table}

\item{resamples}{An \code{rset} resample object.
Used to generate sub-model predictions for the meta-learner.
See \code{\link[timetk:time_series_cv]{timetk::time_series_cv()}} or \code{\link[rsample:vfold_cv]{rsample::vfold_cv()}} for making resamples.}

\item{control}{A \code{\link[tune:control_grid]{tune::control_resamples()}} object to provide
control over the resampling process.}
}
\value{
A Modeltime Table (\code{mdl_time_tbl}) object with a column containing
resample results (\code{.resample_results})
}
\description{
Resampled predictions are commonly used for:
\enumerate{
\item Analyzing accuracy and stability of models
\item As inputs to Ensemble methods (refer to the \code{modeltime.ensemble} package)
}
}
\details{
The function is a wrapper for \code{tune::fit_resamples()} to iteratively train and predict models
contained in a Modeltime Table on resample objects.
One difference between \code{tune::fit_resamples()} and \code{modeltime_fit_resamples()}
is that predictions are always returned
(i.e. \code{control = tune::control_resamples(save_pred = TRUE)}). This is needed for
\code{ensemble_model_spec()}.

\strong{Resampled Prediction Accuracy}

Calculating Accuracy Metrics on models fit to resamples can help
to understand the model performance and stability under different
forecasting windows. See \code{\link[=modeltime_resample_accuracy]{modeltime_resample_accuracy()}} for
getting resampled prediction accuracy for each model.

\strong{Ensembles}

Fitting and Predicting Resamples is useful in
creating Stacked Ensembles using \code{modeltime.ensemble::ensemble_model_spec()}.
The sub-model cross-validation predictions are used as the input to the meta-learner model.
}
\examples{
library(tidymodels)
library(modeltime)
library(timetk)
library(tidyverse)

# Make resamples
resamples_tscv <- training(m750_splits) \%>\%
    time_series_cv(
        assess      = "2 years",
        initial     = "5 years",
        skip        = "2 years",
        # Normally we do more than one slice, but this speeds up the example
        slice_limit = 1
    )

\donttest{
# Fit and generate resample predictions
m750_models_resample <- m750_models \%>\%
    modeltime_fit_resamples(
        resamples = resamples_tscv,
        control   = control_resamples(verbose = TRUE)
    )

# A new data frame is created from the Modeltime Table
#  with a column labeled, '.resample_results'
m750_models_resample
}

}
