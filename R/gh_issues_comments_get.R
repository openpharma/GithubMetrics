#' Get comments on issues in a repo
#'
#' @param full_names Vector of repo names (format 'org/repo')
#' @param days_back How many days back to look for commits.
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#'
gh_issues_comments_get <- function(
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

  comments <- full_names %>%
    purrr::map(
      repo_issues_comments, since = from_date,
      .pb = pb,
      ... = ...
      ) %>% purrr::compact() %>% dplyr::bind_rows()

  # IF MISSING - haven't set up email
  comments <- comments %>%
    dplyr::mutate(
      author = ifelse(is.na(author),".gitconfig missing email",author)
    )

  comments
}


repo_issues_comments <- function(
  full_name,
  since,
  .pb = NULL,
  ...
  ) {

  #message("Requesting commits for ", full_name)
  #if(interactive()) message("Requesting commits for ", full_name)
  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i < .pb$n)) .pb$tick()$print()

  comments <- gh::gh("GET /repos/:full_name/issues/comments?per_page=100",
                    full_name = full_name,
                    since = since,
                    .limit = Inf,
                    .progress = FALSE,
                    ...
  )

  if (length(comments) == 0) {
    return(NULL)
  }

  tibble::tibble(
    full_name = full_name,
    issue_url = comments %>%
      purrr::map_chr(c("issue_url"), .null = NA_character_) %>%
      gsub("https://api.github.com/repos/","https://github.com/",x = .),
    issue_number = comments %>%
      purrr::map_chr(c("issue_url"), .null = NA_character_) %>%
      gsub("https://api.github.com/repos/","https://github.com/",x = .) %>%
      basename(),
    url = comments %>%
      purrr::map_chr(c("html_url"), .null = NA_character_),
    created = comments %>%
      purrr::map_chr(c("created_at"), .null = NA_character_),
    updated = comments %>%
      purrr::map_chr(c("updated_at"), .null = NA_character_),
    body = comments %>%
      purrr::map_chr(c("body"), .null = NA_character_),
    author = comments %>%
      purrr::map_chr(c("user","login"), .null = NA_character_),
    author_status = comments %>%
      purrr::map_chr(c("author_association"), .null = NA_character_)

  )
}
