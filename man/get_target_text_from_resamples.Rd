% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-resamples.R
\name{get_target_text_from_resamples}
\alias{get_target_text_from_resamples}
\title{Gets the target variable as text from unnested resamples}
\usage{
get_target_text_from_resamples(data, column_before_target = ".row")
}
\arguments{
\item{data}{Unnested resample results}

\item{column_before_target}{The text column located before the target variable.
This is ".row".}
}
\description{
An internal function used by \code{\link[=unnest_modeltime_resamples]{unnest_modeltime_resamples()}}.
}
\examples{

# The .resample_results column is deeply nested
m750_training_resamples_fitted

# Unnest and prepare the resample predictions for evaluation
unnest_modeltime_resamples(m750_training_resamples_fitted) \%>\%
    get_target_text_from_resamples()

}
