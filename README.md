
<!-- README.md is generated from README.Rmd. Please edit that file -->

# modeltime.resample

<!-- badges: start -->

<!-- badges: end -->

> Resampling Tools for Time Series Forecasting with Modeltime

A `modeltime` extension that implements ***time series resampling
tools*** for making iterative predictions and evaluating resample
results.

## Benefits: What Modeltime Resample Does

Resampling time series is an important strategy to evaluate models
across multiple time series windows. However, it’s a pain to do this
because it requires multiple for-loops to generate the predictions.
**Modeltime Resample simplifies the iterative forecasting process taking
the pain away.**

Modeltime Resample makes it easy to:

1.  Iteratively generate predictions from resample objects
    (e.g. `timetk::time_series_cv()`) cross-validation plans.
2.  Evaluate the resample predictions to compare many time series models
    across multiple time-series windows.

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
2.  [Getting Started with Modeltime
    Resample](https://business-science.github.io/modeltime.resample/articles/getting-started-with-modeltime-resample.html):
    Learn the basics of time series resample evaluation.

## Make Your First Resample in Minutes

Load the Following Libraries.

``` r
library(modeltime)
library(modeltime.resample)
library(timetk)
```

### Step 1 - Make a Cross-Validation Training Plan

Use functions from `rsample` or `timetk` to produce an `rset`. The
`m750_training_resamples` was made with `timetk::time_series_cv()`.

``` r
# Begin with a Cross Validation Strategy
m750_training_resamples %>%
    tk_time_series_cv_plan() %>%
    plot_time_series_cv_plan(date, value, .facet_ncol = 2, .interactive = FALSE)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

### Step 2 - Make a Modeltime Table

Create models and add them to a *Modeltime Table* with
[**Modeltime.**](https://business-science.github.io/modeltime/articles/getting-started-with-modeltime.html)

``` r
m750_models
#> # Modeltime Table
#> # A tibble: 3 x 3
#>   .model_id .model     .model_desc            
#>       <int> <list>     <chr>                  
#> 1         1 <workflow> ARIMA(0,1,1)(0,1,1)[12]
#> 2         2 <workflow> PROPHET                
#> 3         3 <workflow> GLMNET
```

### Step 3 - Generate Resample Predictions

Generate resample predictions using `modeltime_fit_resamples()`.

``` r
m750_training_resamples_fitted <- m750_models %>%
    modeltime_fit_resamples(
        resamples = m750_training_resamples,
        control   = control_resamples(verbose = T)
    )
```

### Step 4 - Evaluate the Results

Evaluate the results with `modeltime_resample_accuracy()`.

``` r
m750_training_resamples_fitted %>%
    modeltime_resample_accuracy(summary_fns = mean) %>%
    table_modeltime_accuracy(.interactive = FALSE)
```

<!--html_preserve-->

<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#zmgjapcgul .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#zmgjapcgul .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zmgjapcgul .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#zmgjapcgul .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#zmgjapcgul .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zmgjapcgul .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zmgjapcgul .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#zmgjapcgul .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#zmgjapcgul .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#zmgjapcgul .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#zmgjapcgul .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#zmgjapcgul .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#zmgjapcgul .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#zmgjapcgul .gt_from_md > :first-child {
  margin-top: 0;
}

#zmgjapcgul .gt_from_md > :last-child {
  margin-bottom: 0;
}

#zmgjapcgul .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#zmgjapcgul .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#zmgjapcgul .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zmgjapcgul .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#zmgjapcgul .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zmgjapcgul .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#zmgjapcgul .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#zmgjapcgul .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zmgjapcgul .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zmgjapcgul .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#zmgjapcgul .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zmgjapcgul .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#zmgjapcgul .gt_left {
  text-align: left;
}

#zmgjapcgul .gt_center {
  text-align: center;
}

#zmgjapcgul .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#zmgjapcgul .gt_font_normal {
  font-weight: normal;
}

#zmgjapcgul .gt_font_bold {
  font-weight: bold;
}

#zmgjapcgul .gt_font_italic {
  font-style: italic;
}

#zmgjapcgul .gt_super {
  font-size: 65%;
}

#zmgjapcgul .gt_footnote_marks {
  font-style: italic;
  font-size: 65%;
}
</style>

<div id="zmgjapcgul" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">

<table class="gt_table">

<thead class="gt_header">

<tr>

<th colspan="10" class="gt_heading gt_title gt_font_normal" style>

Accuracy Table

</th>

</tr>

<tr>

<th colspan="10" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>

</th>

</tr>

</thead>

<thead class="gt_col_headings">

<tr>

<th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">

.model\_id

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">

.model\_desc

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">

.type

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">

n

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

mae

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

mape

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

mase

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

smape

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

rmse

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">

rsq

</th>

</tr>

</thead>

<tbody class="gt_table_body">

<tr>

<td class="gt_row gt_center">

1

</td>

<td class="gt_row gt_left">

ARIMA(0,1,1)(0,1,1)\[12\]

</td>

<td class="gt_row gt_left">

Resamples

</td>

<td class="gt_row gt_center">

6

</td>

<td class="gt_row gt_right">

294.51

</td>

<td class="gt_row gt_right">

2.95

</td>

<td class="gt_row gt_right">

1.18

</td>

<td class="gt_row gt_right">

2.94

</td>

<td class="gt_row gt_right">

355.49

</td>

<td class="gt_row gt_right">

0.80

</td>

</tr>

<tr>

<td class="gt_row gt_center">

2

</td>

<td class="gt_row gt_left">

PROPHET

</td>

<td class="gt_row gt_left">

Resamples

</td>

<td class="gt_row gt_center">

6

</td>

<td class="gt_row gt_right">

458.05

</td>

<td class="gt_row gt_right">

4.59

</td>

<td class="gt_row gt_right">

1.85

</td>

<td class="gt_row gt_right">

4.55

</td>

<td class="gt_row gt_right">

515.49

</td>

<td class="gt_row gt_right">

0.78

</td>

</tr>

<tr>

<td class="gt_row gt_center">

3

</td>

<td class="gt_row gt_left">

GLMNET

</td>

<td class="gt_row gt_left">

Resamples

</td>

<td class="gt_row gt_center">

6

</td>

<td class="gt_row gt_right">

706.10

</td>

<td class="gt_row gt_right">

7.16

</td>

<td class="gt_row gt_right">

2.80

</td>

<td class="gt_row gt_right">

6.92

</td>

<td class="gt_row gt_right">

753.04

</td>

<td class="gt_row gt_right">

0.77

</td>

</tr>

</tbody>

</table>

</div>

<!--/html_preserve-->

## Learning More

<a href="https://www.youtube.com/embed/elQb4VzRINg" target="_blank"><img src="http://img.youtube.com/vi/elQb4VzRINg/0.jpg" alt="Anomalize" width="100%" height="450"/></a>

[*My Talk on High-Performance Time Series
Forecasting*](https://youtu.be/elQb4VzRINg)

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
