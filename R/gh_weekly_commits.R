#' @export
#'
#' @title Prepare table for Github weekly number of commits
#'
#' @importFrom magrittr %>%
#'
#' @name gh_weekly_commits_dt
#'
#' @param full_names A character vector containing names of repositories (format
#'   'org/repo').
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @examples
#' \dontrun{
#'  repos_openpharma <- gh_repos_get(org = "openpharma") %>%
#'   gh_repos_clean()
#'
#'  gh_weekly_stats <- gh_weekly_commits_dt(full_names = repos_openpharma$full_name)
#' }
#'
#' @returns A dataframe with number of commits per week for last 52 weeks.

gh_weekly_commits_dt <- function(
    fullnames,
    ...
) {

  gh_weekly_commits_stats <- gh_weekly_commits_get(fullnames,
                                                   ...)

  commits_weekly_df <- purrr::map(gh_weekly_commits_stats, function(x){
    x <- x[["all"]]
  }) %>%
    purrr::discard(function(x){
      all(purrr::map_lgl(x, ~length(.) == 0))
    }) %>%
    purrr::map(function(x){
      x <- unlist(x)
      names(x) <- as.character(c(1:52))
      data.table::data.table(x) %>%
        data.table::transpose()
    }) %>%
    data.table::rbindlist() %>%
    purrr::map_dfc(function(x){
      sum(x, na.rm = TRUE)
    }) %>% data.table::transpose()

  names(commits_weekly_df) <- "commits_number"

  commits_weekly_df$week_index <- as.numeric(rownames(commits_weekly_df))

  commits_weekly_df

}

#' @export
#'
#' @title Get number of commits per week from a Github account
#'
#' @name gh_weekly_commits_get
#'
#' @param full_names A character vector containing names of repositories (format 'org/repo').
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @description This function captures number of commits from all repos of a
#'   given Github account from last 52 weeks
#'
#' @details This function is a handy wrapper to iterate requests for all repos
#'   of a given Github account to the Github endpoint
#'   \code{https://api.github.com/repos/OWNER/REPO/stats/participation} For more
#'   information on the endpoint you can visit:\cr\cr
#'   \link{https://docs.github.com/en/rest/metrics/statistics?apiVersion=2022-11-28#get-the-weekly-commit-count}
#'
#' @returns A list of repo stats, with every slot (repo) containing number of
#'   commits per week.

gh_weekly_commits_get <- function(
    full_names,
    ...
) {

  commits_weekly <- purrr::map(full_names, function(x){
    gh::gh("GET /repos/:repo_name/stats/participation",
           repo_name = x,
           ...
    )
  })

  commits_weekly

}
