#' Get commits for a repo
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
#'  \item{full_name}{org/repo}
#'  \item{author}{Author name}
#'  \item{datetime}{Date time of commit}
#'  \item{sha}{Unique hash - can be joined on repo_sha from \code{gh_repo_files_get()}}
#'  \item{commit_message}{The commit message}
#' }
#'
gh_commits_get <- function(
  full_names,
  days_back,
  ...
) {

  from_date <- (Sys.Date() - days_back)

  # extract commits
  if(interactive()) message(
    glue::glue("Pulling commits looking back to {from_date}")
    )

  pb <- dplyr::progress_estimated(length(full_names))
  # pb <- progress::progress_bar$new(
  #   format = "  downloading [:bar] :percent eta: :eta",
  #   clear = FALSE, width= 60,
  #   total = length(full_names)
  # )

  commits <- full_names %>%
    purrr::map(
      repo_commits, since = from_date,
      .pb = pb,
      ... = ...
      ) %>% purrr::compact() %>% dplyr::bind_rows()

  # Give back empty dataframe if null
  # if (is.null(commits)){
  #   empty_table <- tibble::tibble(
  #     full_name = character(),
  #     author = character(),
  #     datetime = character(),
  #     sha = character(),
  #     commit_message = character()
  #   )
  #   return(empty_table)
  # } else {
  #   commits <- commits %>%
  #     dplyr::mutate(
  #       author = ifelse(is.na(author),".gitconfig missing email",author)
  #     )
  # }
  commits
}


repo_commits <- function(
  full_name,
  since,
  .pb = NULL,
  ...
  ) {

  #message("Requesting commits for ", full_name)
  #if(interactive()) message("Requesting commits for ", full_name)
  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i < .pb$n)) .pb$tick()$print()

  commits <- gh::gh("GET /repos/:full_name/commits",
                    full_name = full_name,
                    since = since,
                    .limit = Inf,
                    .progress = FALSE,
                    ...
  )

  if (length(commits) == 0) {
    return(NULL)
  }

  tibble::tibble(
    full_name = full_name,
    author = commits %>%
      purrr::map_chr(c("author", "login"), .null = NA_character_),
    datetime = commits %>%
      purrr::map_chr(c("commit", "author", "date"), .null = NA_character_),
    sha = commits %>%
      purrr::map_chr(c("sha"), .null = NA_character_),
    commit_message = commits %>%
      purrr::map_chr(c("commit", "message"), .null = NA_character_)
  )
}
