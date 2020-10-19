
<!-- README.md is generated from README.Rmd. Please edit that file -->

# modeltime.resample <img src='man/figures/logo.png' align="right" height="138.5" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/business-science/modeltime.resample.svg?branch=master)](https://travis-ci.com/business-science/modeltime.resample)
[![Codecov test
coverage](https://codecov.io/gh/business-science/modeltime.resample/branch/master/graph/badge.svg)](https://codecov.io/gh/business-science/modeltime.resample?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/modeltime.resample)](https://CRAN.R-project.org/package=modeltime.resample)
![](http://cranlogs.r-pkg.org/badges/modeltime.resample?color=brightgreen)
![](http://cranlogs.r-pkg.org/badges/grand-total/modeltime.resample?color=brightgreen)
<!-- badges: end -->

> Model Performance and Stability Assessment Tools for Single Time
> Series, Panel Data, & Cross-Sectional Time Series Analysis

A `modeltime` extension that implements ***forecast resampling tools***
for making iterative predictions and evaluating resample results with
the **goal of assessing model performance and stability over time.**

<img src="man/figures/cross_validation_plan.jpg" width="100%" style="display: block; margin: auto;" />

## Benefits: What Modeltime Resample Does

Resampling time series is an important strategy to **evaluate the
stability of models over time.** However, it’s a pain to do this because
it requires multiple for-loops to generate the predictions for multiple
models and potentially multiple time series groups. **Modeltime Resample
simplifies the iterative forecasting process taking the pain away.**

Modeltime Resample makes it easy to:

1.  **Iteratively generate predictions** from time series
    cross-validation plans.
2.  **Evaluate the resample predictions** to compare many time series
    models across multiple time-series windows.

Here is an example from [*Resampling Panel
Data*](https://business-science.github.io/modeltime.resample/articles/getting-started-with-modeltime-resample.html),
where we can see that Prophet Boost and XGBoost Models outperform
Prophet with Regressors for the Walmart Time Series Panel Dataset using
the 6-Slice Time Series Cross Validation plan shown above.

<div class="figure" style="text-align: center">

<img src="man/figures/plotly_resample_error_plot.jpg" alt="Model Accuracy for 6 Time Series Resamples" width="100%" />

<p class="caption">

Model Accuracy for 6 Time Series Resamples

</p>

</div>

<div class="figure" style="text-align: center">

<img src="man/figures/gt_accuracy_table.jpg" alt="Resampled Model Accuracy (3 Models, 6 Resamples, 7 Time Series Groups)" width="80%" />

<p class="caption">

Resampled Model Accuracy (3 Models, 6 Resamples, 7 Time Series Groups)

</p>

</div>

## Installation

Install the CRAN version:

``` r
# Not on CRAN yet
# install.packages("modeltime.resample")
```

Or, install the development version:

``` r
remotes::install_github("business-science/modeltime.resample")
```

## Getting Started

1.  [Getting Started with
    Modeltime](https://business-science.github.io/modeltime/articles/getting-started-with-modeltime.html):
    Learn the basics of forecasting with Modeltime.
2.  [Resampling a Single Time
    Series](https://business-science.github.io/modeltime.resample/articles/getting-started-with-modeltime-resample.html):
    Learn the basics of time series resample evaluation.
3.  [Resampling Panel
    Data](https://business-science.github.io/modeltime.resample/articles/getting-started-with-modeltime-resample.html):
    An advanced tutorial on resample evaluation with **multiple time
    series groups (Panel Data)**

## Learning More

[*My Talk on High-Performance Time Series
Forecasting*](https://youtu.be/elQb4VzRINg)

<a href="https://www.youtube.com/embed/elQb4VzRINg" target="_blank"><img src="http://img.youtube.com/vi/elQb4VzRINg/0.jpg" alt="Anomalize" width="100%" height="450"/></a>

Time series is changing. **Businesses now need 10,000+ time series
forecasts every day.** This is what I call a *High-Performance Time
Series Forecasting System (HPTSF)* - Accurate, Robust, and Scalable
Forecasting.

**High-Performance Forecasting Systems will save companies MILLIONS of
dollars.** Imagine what will happen to your career if you can provide
your organization a “High-Performance Time Series Forecasting System”
(HPTSF System).

I teach how to build a HPTFS System in my **High-Performance Time Series
Forecasting Course**. If interested in learning Scalable
High-Performance Forecasting Strategies then [take my
course](https://university.business-science.io/p/ds4b-203-r-high-performance-time-series-forecasting).
You will learn:

  - Time Series Machine Learning (cutting-edge) with `Modeltime` - 30+
    Models (Prophet, ARIMA, XGBoost, Random Forest, & many more)
  - NEW - Deep Learning with `GluonTS` (Competition Winners)
  - Time Series Preprocessing, Noise Reduction, & Anomaly Detection
  - Feature engineering using lagged variables & external regressors
  - Hyperparameter Tuning
  - Time series cross-validation
  - Ensembling Multiple Machine Learning & Univariate Modeling
    Techniques (Competition Winner)
  - Scalable Forecasting - Forecast 1000+ time series in parallel
  - and more.

<p class="text-center" style="font-size:30px;">

<a href="https://university.business-science.io/p/ds4b-203-r-high-performance-time-series-forecasting">Unlock
the High-Performance Time Series Forecasting Course</a>

</p>
