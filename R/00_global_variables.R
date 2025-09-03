utils::globalVariables(c(
    # modeltime columns
    ".model", ".model_desc", ".model_id",
    ".resample_results", ".resample_id", ".row_id",

    # prediction & truth naming variants we normalize
    ".pred", ".prediction", ".preds", ".fitted", ".estimate", ".actual",

    # metric/plot helpers
    ".metric", "..summary_fn",

    # common NSE column names created by tidyr/dplyr
    "id", ".id", "data",

    # notes/metrics tibbles from tune
    ".notes", ".metrics", ".type", "n"
))

