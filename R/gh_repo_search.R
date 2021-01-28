#' Get files in a repo
#'
#' @param code Output from \code{gh_commits_get()}
#' @param organisation Shortcut to add a filter onto a specific organisation
#' @param full_name Shortcut to add a filter on to a specific repo
#' @param custom Add your own query
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
#'  \item{full_name}{org/repo}
#'  \item{name}{repo name}
#'  \item{file_name}{File name}
#'  \item{path}{Path within repo to file including filename}
#'  \item{url}{URL to the file and commit on github}
#'  \item{score}{i didn't actually look this up... maybe matching score}
#'  \item{lang}{Language guessed via \code{GithubMetrics:::gh_filetype()}}
#' }
#'
gh_repo_search <- function(
  code = "RocheData",
  organisation = "PHC",
  full_name = NULL,
  custom = "in:file",
  ...
) {
  query <- code

  if (purrr::is_character(custom)) {
    query <- glue::glue("{query} {custom} ")
  }

  if (purrr::is_character(organisation)) {
    query <- glue::glue("{query} user:{organisation}")
  } else if (purrr::is_character(full_name)) {
    query <- glue::glue("{query} repo:{full_name}")
  }

  results <- gh::gh(
    "/search/code",
    q = query,
    .limit = Inf,
    .progress = FALSE,
    ...
  )

  results_items <- results[["items"]]

  if ( length(results_items) == 0) {
    message(glue::glue("{code} does not appear in {organisation}."))
    message(glue::glue("query = '{query}'"))
    return(NA)
  }

  results_items %>%
    purrr::map_dfr(extract_results) %>%
    dplyr::mutate(
      lang = gh_filetype(file_name, extract_extension = TRUE)
    )

}

extract_results <- function(x){
  tibble::tibble(
    full_name = x$repository$full_name,
    name = x$repository$name,
    file_name = x$name,
    path = x$path,
    url = x$html_url,
    score = x$score
  )
}





