#' Score the open source health of the repos
#'
#'
#' @details
#' This function will apply the following scoring metric (positive answer = 1 point, negative is 0 points):
#'
#' * has the default branch had an commit in the last 6 months
#' * has the project had > 25 commits
#' * does it have more than 5 unique contributors
#' * the open issues have a median time from creation of <6 months
#' * for the open issues, there is a median time since comment of <3 months
#' * the project is more active in commits in the last half of it's existance than the first
#' * the project has more contributors active in the last half of it's existance then the first
#'
#'
#' @return
#'
#' * `full_name`: repo full name
#' * `warnings`: A list of where this scored badly
#' * `score`: The OS score
#'
#' @param x Out of joining the metrics functions
#'
#' @export
#' @md
gh_score <- function(x){
  x %>%
    dplyr::mutate(
      # updated in last 6 months
      temp = ifelse(days_since_update < 30*6,1,0),
      warnings = dplyr::case_when(
        temp == 0 ~ paste("* It has been",days_since_update,"days since last commit.\n"),
        TRUE ~ ""
      ),
      score = dplyr::case_when(
        temp == 0 ~ 0,
        temp == 1 ~ 1
      ),
      # the project has > 25 commits
      temp = ifelse(commits > 25,1,0),
      warnings = dplyr::case_when(
        temp == 0 ~ paste0(warnings,paste("* This project has",commits,"commits.\n")),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      ),
      # the project has > 5 contributors
      temp = ifelse(authors_ever > 5,1,0),
      warnings = dplyr::case_when(
        temp == 0 ~ paste0(warnings,paste("* This project has",authors_ever,"contributor(s)\n")),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      ),
      # has at least 1 open issue, and median open issue is open < 6 months old)
      temp = dplyr::case_when(
        is.na(median_age_open_issue) ~ 0.5,
        median_age_open_issue > 30*6 ~ 0,
        TRUE ~ 1
      ),
      warnings = dplyr::case_when(
        is.na(median_age_open_issue) ~ paste0(warnings,paste("* This project has no open issues\n")),
        temp == 0 ~ paste0(warnings,paste("* This project has a median age for open issues of",median_age_open_issue,"days\n")),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      ),
      # has at least 1 open issue, and median inactivity on an issue is < 3 months
      temp = dplyr::case_when(
        is.na(median_age_open_issue) ~ 0.5,
        median_inactivity_open_issue > 30*3 ~ 0,
        TRUE ~ 1
      ),
      warnings = dplyr::case_when(
        temp == 0 ~ paste0(warnings,paste("* This project has a median inactivity on open issues of",median_inactivity_open_issue,"days\n")),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      ),
      # there are more commits in the last half of the projects life than the first
      temp = dplyr::case_when(
        commits_prepost_midpoint <= 0 ~ 0,
        TRUE ~ 1
      ),
      warnings = dplyr::case_when(
        temp == 0 ~ paste0(warnings,paste0("* This project had more commits in the first half of it's life\n")),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      ),
      # there are more authors in the last half of the projects life than the first
      temp = dplyr::case_when(
        authors_prepost_midpoint <= 0 ~ 0,
        TRUE ~ 1
      ),
      warnings = dplyr::case_when(
        temp == 0 ~ paste0(warnings,paste0(
          "* This project had ",abs(authors_prepost_midpoint),
          " contributors in the last half of it's life, and ",
          authors_ever-authors_prepost_midpoint," in it's first half\n"
        )),
        TRUE ~ warnings
      ),
      score = dplyr::case_when(
        temp == 0 ~ score + 0,
        temp == 1 ~ score + 1
      )
    ) %>%
    # score
    dplyr::mutate(score = round(100*score / 7)) %>%

    dplyr::select(
      full_name, warnings, score
    )

}









