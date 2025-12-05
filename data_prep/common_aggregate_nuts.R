#!/usr/bin/Rscript
#
# This includes helper functions that help aggregate smaller geographical
# regions into bigger ones

# Function that aggregates NUTS2 data to NUTS1
aggregate_nuts2_to_nuts1 <- function(data, geo, year) {
  data |>
    filter(str_length(geo) == 4) |> # only keep NUTS2
    mutate(NUTS1 = substr({{geo}}, 1, 3)) |>
    group_by({{year}}, NUTS1) |>
    summarise(across(where(is.numeric), sum, na.rm = TRUE),
              .groups = "drop") |>
    rename({{geo}} := NUTS1) |>
    relocate({{geo}}, .before=everything())
}

# Function that aggregates NUTS3 data to NUTS2
aggregate_nuts3_to_nuts2 <- function(data, geo, year) {
  data |>
    filter(str_length(geo) == 5) |> # only keep NUTS3
    mutate(NUTS2 = substr({{geo}}, 1, 4)) |>
    group_by({{year}}, NUTS2) |>
    summarise(across(where(is.numeric), sum, na.rm = TRUE),
              .groups = "drop") |>
    rename({{geo}} := NUTS2) |>
    relocate({{geo}}, .before=everything())
}

# Function that aggregates regional units data to NUTS3
aggregate_regional_to_nuts3 <- function(data, geo, year) {
  data |>
    filter(str_length(geo) == 6) |> # only keep regional units
    mutate(NUTS3 = substr({{geo}}, 1, 5)) |>
    group_by({{year}}, NUTS3) |>
    summarise(across(where(is.numeric), sum, na.rm = TRUE),
              .groups = "drop") |>
    rename({{geo}} := NUTS3) |>
    relocate({{geo}}, .before=everything())
}
