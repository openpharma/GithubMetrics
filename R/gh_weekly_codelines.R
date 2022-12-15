#' @export
#'
#' @title Weekly number of added and removed code lines from Github repos
#'
#' @description This function prepares table for weekly number of lines of code
#'   added and removed per week from all repositories from a Github account.
#'
#' @importFrom magrittr %>%
#'
#' @name gh_weekly_codelines_dt
#'
#' @param full_names A character vector containing names of repositories (format
#'   'org/repo').
#' @param year_for_stats A character year to filter statistics.
#' @param unit A unit to show values for added and removed lines.
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @examples
#' \dontrun{
#' repos_openpharma <- gh_repos_get(org = "openpharma") %>%
#'   gh_repos_clean()
#'
#' gh_weekly_stats_dt <- gh_weekly_codelines_dt(full_names = repos_openpharma$full_name,
#'                                              year_of_stats = "2022",
#'                                              unit = "thous")
#' }
#'
#' @returns A tibble with columns of added and removed lines numbers per week.

gh_weekly_codelines_dt <- function(
    full_names,
    year_for_stats,
    unit = c("none", "thous", "mln", "bln"),
    ...
) {

  gh_weekly_stats <- gh_weekly_codelines_get(full_names,
                                             year_for_stats,
                                             ...)

  unit <- match.arg(unit)

  gh_weekly_df <- gh_weekly_stats %>%
    purrr::map(~dplyr::bind_rows(.)) %>%
    data.table::rbindlist() %>%
    dplyr::group_by(time) %>%
    dplyr::summarise(added = sum(added),
                     removed = sum(removed))

  units <- switch(unit,
                  "none" = 1,
                  "thous" = 1e3,
                  "mln" = 1e6,
                  "bln" = 1e9)

  gh_weekly_df <- gh_weekly_df %>%
    dplyr::mutate(week_index = lubridate::week(time),
                  days_week = paste0(time, " - ", time + lubridate::days(7)),
                  unit = unit,
                  added_n = round(added/units, 1),
                  removed_n = round(-removed/units, 1))

  gh_weekly_df

}

#' @export
#'
#' @title Get weekly number of lines of code from Github repos
#'
#' @name gh_weekly_code_lines_get
#'
#' @param full_names A character vector containing names of repositories (format 'org/repo').
#' @param year_for_stats A character year to filter statistics.
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @description This function is a handy wrapper to iterate requests for all repos
#'   of a given Github account to the Github endpoint
#'   \code{https://api.github.com/repos/OWNER/REPO/stats/code_frequency} For
#'   more information on the endpoint you can visit:\cr\cr
#'   \link{https://docs.github.com/en/rest/metrics/statistics?apiVersion=2022-11-28#get-the-weekly-commit-activity}
#'
#' @returns A list of repo stats, with every slot (repo) containing: \itemize{
#'   \item{Starting date of a week.} \item{Lines of code added in a given week.}
#'   \item{Lines of code removed in a given week.}}

gh_weekly_codelines_get <- function(
    full_names,
    year_for_stats,
    ...
) {

  if(interactive()) message(
    glue::glue("Pulling code_frequency stats for year {year_for_stats}")
  )

  # pb <- dplyr::progress_estimated(length(full_names))

  weekly_stats <- purrr::map(full_names, function(x){

    request <- gh::gh("GET /repos/:repo_name/stats/code_frequency",
                      repo_name = x,
                      # .pb = pb,
                      ...
    )

    stat <- purrr::map(request, function(x){
      unix <- x[[1]]
      x[[1]] <- as.POSIXct(unix, origin="1970-01-01")
      names(x) <- c("time", "added", "removed")
      x
    }) %>% purrr::keep(~lubridate::year(.x$time) == year_for_stats)

    stat
  })

  repo_names <- sub(".*/", "", full_names)
  names(weekly_stats) <- repo_names

  weekly_stats

}
