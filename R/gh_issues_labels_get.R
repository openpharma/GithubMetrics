#' Get issues for a repo
#'
#' @param full_names Vector of repo names (format 'org/repo')
#' @param days_back How many days back to look for commits.
#' @param state Defaults to open. Search issues based on open, closed or all.
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#' @details
#'
#' \strong{New Columns}
#'
#' \describe{
#'
#'  \item{url}{URL for the issue}
#'  \item{label_name}{Name of the label}
#'  \item{label_color}{Hex colour}
#'  \item{label_description}{Label description}
#' }
#'
gh_issues_labels_get <- function(
  full_names,
  days_back = 30,
  state = c("open","closed","all"),
  ...
) {
  since <- Sys.Date() - days_back

  # Loop through full names
  labels <- NULL
  for (i_repo in full_names) {
    i_issues <- gh::gh("GET /repos/:full_name/issues?state=:state",
                       full_name = i_repo,
                       since = since,
                       .limit = Inf,
                       state = state ,
                       .progress = FALSE,
                       ...
    )
    urls <- i_issues %>%
      purrr::map_chr(c("html_url"), .null = NA_character_)
    # Loop through issues in a repo
    for (i_issue_n in seq_along(i_issues)) {
      i_issue <- i_issues[[i_issue_n]] # not this!

      i_labels <- tibble::tibble(
        url = urls[i_issue_n],
        label_name = i_issue$labels %>%
          purrr::map_chr(c("name"), .null = NA_character_),
        label_color = i_issue$labels %>%
          purrr::map_chr(c("color"), .null = NA_character_),
        label_description = i_issue$labels %>%
          purrr::map_chr(c("description"), .null = NA_character_)
      )

      labels <- dplyr::bind_rows(
        i_labels, labels
      )
    }
  }
  labels
}


