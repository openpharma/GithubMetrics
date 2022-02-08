#' Calculate metrics for the issues
#'
#' Calculates metrics of interest for open source health based on the issue
#' metadata using the
#' columns `fullname`, `state`, `days_open`, `days_no_activity`.
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `open_issues`: total open issues
#' * `median_age_open_issue`: median time open issues have been open
#' * `median_inactivity_open_issue`: median time an open issue has been inactive
#'
#' @param issues A dataframe of issues
#'
#' @export
#' @md
gh_metric_issues <- function(
  issues
){
  issues %>%
    dplyr::group_by(full_name) %>%
    dplyr::filter(state == "open") %>%
    dplyr::summarise(
      # open issues
      open_issues = n(),
      # median age issue is open
      median_age_open_issue = median(days_open),
      # median inactivity on open issues
      median_inactivity_open_issue = median(days_no_activity)
    ) %>%
    dplyr::select(
      full_name,
      open_issues,
      median_age_open_issue,
      median_inactivity_open_issue
    )
}

#' Days since update
#'
#' Days since last commit on master
#'
#' Uses columns `fullname`, `date`.
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `days_since_update`: Date last commit - today's date
#'
#' @param commits A dataframe of commits
#'
#' @export
#' @md
gh_metric_commits_days_since_commit <- function(
  commits
){
  commits %>%
    dplyr::group_by(full_name) %>%
    dplyr::arrange(dplyr::desc(date)) %>%
    dplyr::slice(1) %>%
    dplyr::mutate(days_since_update = as.numeric(Sys.Date() - date)) %>%
    dplyr::select(full_name, days_since_update)
}


#' Trend in quantity of commits
#'
#' Calculates the difference in commits between first and last half of a projects
#' calendar life
#'
#' Uses columns `fullname`, `date`.
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `commits`: total commits
#' * `commits_prepost_midpoint`: Using time from first to last commit as the time scale, what is total commits in first half - commit in second half.
#'
#' @param commits A dataframe of commits
#'
#' @export
#' @md
gh_metric_commits_prepost_midpoint <- function(
  commits
){
  commits %>%
    dplyr::group_by(full_name) %>%
    dplyr::mutate(
      # flag if comment in first or second half of project's life
      date_numeric = as.numeric(date),
      midpoint = quantile(date_numeric, 0.5),
      firsthalf = ifelse(date_numeric >= midpoint,FALSE,TRUE)
    ) %>%
    dplyr::select(
      full_name,
      date_numeric, midpoint, firsthalf
    )  %>%
    dplyr::summarise(
      commits = n(),
      secondhalf = sum(ifelse(!firsthalf,1,0)),
      firsthalf = sum(ifelse(firsthalf,1,0))
    ) %>%
    dplyr::mutate(
      abs = secondhalf-firsthalf
    ) %>%
    dplyr::select(
      full_name, commits_prepost_midpoint = abs,commits
    )
}

#' Total number of commit authors for a repo
#'
#' Uses the
#' columns `fullname`, `author`.
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `authors_ever`: authors of the commits
#'
#' @param commits A dataframe of commits
#'
#' @export
#' @md
gh_metric_commits_authors_ever <- function(
  commits
){
  commits %>%
    dplyr::group_by(full_name) %>%
    dplyr::summarise(
      authors_ever = dplyr::n_distinct(author)
    )
}

#' Trend in author engagement
#'
#' Uses the
#' columns `fullname`, `author`.
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `authors_prepost_midpoint`: Using time from first to last commit as the time scale, what is total authors in second half - authors in first half.
#'
#' @param commits A dataframe of commits
#'
#' @export
#' @md
gh_metric_commits_authors_prepost_midpoint <- function(
  commits
){
  commits %>%
    dplyr::group_by(full_name) %>%
    dplyr::mutate(
      date_numeric = as.numeric(date),
      midpoint = quantile(date_numeric, 0.5),
      timing = ifelse(date_numeric >= midpoint,"firsthalf","secondhalf")
    ) %>%
    dplyr::group_by(full_name,timing) %>%
    dplyr::summarise(
      active_people = dplyr::n_distinct(author)
    ) %>% ungroup %>%
    tidyr::pivot_wider(
      names_from = timing, values_from = active_people, values_fill = 0
    ) %>%
    dplyr::mutate(
      ratio = secondhalf/firsthalf,
      authors_prepost_midpoint = secondhalf-firsthalf
    ) %>%
    dplyr::select(full_name,authors_prepost_midpoint)
}
