#' Get issues for a repo
#'
#' @param full_names Vector of repo names (format 'org/repo')
#' @param days_back How many days back to look for commits.
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
#'  \item{title}{Issue title}
#'  \item{url}{Link to issue}
#'  \item{state}{State of the issue (e.g. open or closed)}
#'  \item{created, updated, closed}{Unique hash - can be joined on repo_sha from \code{gh_repo_files_get()}}
#'  \item{comments}{The commit message}
#'  \item{body}{The commit message}
#'  \item{author}{The commit message}
#' }
#'
gh_issues_get <- function(
  full_names,
  days_back,
  ...
) {

  from_date <- (Sys.Date() - days_back)

  # extract commits
  if(interactive()) message(
    glue::glue("Pulling issues looking back to {from_date}")
    )

  pb <- dplyr::progress_estimated(length(full_names))
  # pb <- progress::progress_bar$new(
  #   format = "  downloading [:bar] :percent eta: :eta",
  #   clear = FALSE, width= 60,
  #   total = length(full_names)
  # )

  commits <- full_names %>%
    purrr::map(
      repo_issues, since = from_date,
      .pb = pb,
      ... = ...
      ) %>% purrr::compact() %>% dplyr::bind_rows()

  # IF MISSING - haven't set up email
  commits <- commits %>%
    dplyr::mutate(
      author = ifelse(is.na(author),".gitconfig missing email",author)
    )

  commits
}


repo_issues <- function(
  full_name,
  since,
  .pb = NULL,
  ...
  ) {

  #message("Requesting commits for ", full_name)
  #if(interactive()) message("Requesting commits for ", full_name)
  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i < .pb$n)) .pb$tick()$print()

  issues <- gh::gh("GET /repos/:full_name/issues?state=all",
                    full_name = full_name,
                    since = since,
                    .limit = Inf,
                    .progress = FALSE,
                    ...
  )

  if (length(issues) == 0) {
    return(NULL)
  }

  tibble::tibble(
    full_name = issues %>%
      purrr::map_chr(c("repository_url"), .null = NA_character_) %>%
      gsub("https://api.github.com/repos/","",x = .),
    issue_number = issues %>%
      purrr::map_chr(c("html_url"), .null = NA_character_) %>%
      basename(),
    title = issues %>%
      purrr::map_chr(c("title"), .null = NA_character_),
    url = issues %>%
      purrr::map_chr(c("html_url"), .null = NA_character_),
    state = issues %>%
      purrr::map_chr(c("state"), .null = NA_character_),
    created = issues %>%
      purrr::map_chr(c("created_at"), .null = NA_character_),
    updated = issues %>%
      purrr::map_chr(c("updated_at"), .null = NA_character_),
    closed = issues %>%
      purrr::map_chr(c("closed_at"), .null = NA_character_),
    comments = issues %>%
      purrr::map_chr(c("comments"), .null = NA_character_),
    body = issues %>%
      purrr::map_chr(c("body"), .null = NA_character_),
    author = issues %>%
      purrr::map_chr(c("user","login"), .null = NA_character_),
    author_status = issues %>%
      purrr::map_chr(c("author_association"), .null = NA_character_)

  )
}
