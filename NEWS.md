# modeltime.resample (0.3.0.9000, development version)


# modeltime.resample (0.3.0)

Here’s a clean **Markdown release notes draft** based on the changes you provided:

---

# modeltime.resample 0.3.0

### 🚀 New Features & Improvements

* **Compatibility with tune 2.0.0**

  * Updated internals to support new `tune::fit_resamples()` behavior.
  * Improved handling of `.predictions` column reconstruction when missing.
  * Added robust fallback logic to normalize truth/prediction columns across versions.

* **Improved Resampling Functions**

  * `modeltime_fit_resamples()` now ensures predictions are always saved.
  * Added deterministic seeding (`withr::with_seed()`) for reproducible resample fits.
  * Better error handling: failed resample fits now produce `.notes` with clear error messages.

* **Plotting Enhancements**

  * `plot_modeltime_resamples()` now standardizes truth/estimate detection.
  * Improved facetting and summary-line consistency.
  * More graceful error messages if truth/pred columns cannot be identified.
  * Optional interactive output improved with Plotly checks.

* **Utility Upgrades**

  * `unnest_modeltime_resamples()` more robust:

    * Ensures `.predictions` column exists (reconstructed if missing).
    * Clear actionable errors when predictions are unavailable.
    * Guarantees `.row_id` assignment for comparing models across resamples.

### 🛠 Dependency Updates

* `tune (>= 2.0.0)` is now required.
* Added `withr` to `Imports`.
* Retained compatibility with older `tune` versions (<2.0.0) via conditional handling.

### ⚡ Internal Improvements

* Standardized use of `rlang::abort(message=...)` for consistent error messages.
* Reduced reliance on `tictoc`/`progressr` in favor of clearer progress reporting.
* Expanded `utils::globalVariables()` for safer NSE handling across `dplyr`/`tidyr`.



# modeltime.resample (0.2.4)

- Update for better compatibility with dplyr 1.1.0 and ggplot2 3.4.4 (@olivroy, #16)

- Remove dependency on tidyverse (@olivroy, #16)

- Update for the next version of tune (@hfrik, #18)

# modeltime.resample 0.2.3

- Resubmit to CRAN (timetk issue)

# modeltime.resample 0.2.2

- Fix for `workflows` mode = "regression"

# modeltime.resample 0.2.1

### Fixes

- Updates for `hardhat 1.0.0` #11

# modeltime.resample 0.2.0

- `modeltime_resample_accuracy()` (#1): When user specifies `summary_fns = NULL`, returns unsummarized resample metrics with ".resample_id"

# modeltime.resample 0.1.0

* Initial `modeltime.resample` Package Release
