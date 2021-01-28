#' Get files in a repo
#'
#' @param repo_commits Output from \code{gh_commits_get()}
#' @param only_last_commit Only pull files in the most recent commit
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
#'  \item{repo}{Maximum VisitDate observed in the VISIT table}
#'  \item{file}{Maximum AdministeredDate observed in the MEDICATIONADMINISTRATION table}
#'  \item{sha_repo}{Can join back onto commit hash}
#'  \item{sha_commit}{hash}
#'  \item{extension}{The filetype}
#'  \item{lang}{Estimate of language from extension using \code{GithubMetrics:::gh_filetype()}}
#' }
#'
gh_repo_files_get <- function(
  repo_commits,
  only_last_commit = TRUE,
  ...
) {
  if (only_last_commit){
    d_input <- repo_commits %>%
      dplyr::group_by(full_name) %>%
      dplyr::arrange(dplyr::desc(datetime)) %>%
      dplyr::slice(1) %>%
      dplyr::ungroup()
    message(glue::glue('Pulling files in latest commit from {nrow(d_input)} repos'))
  } else {
    d_input <- repo_commits
    message(glue::glue(
      'Pulling files from {nrow(d_input)} commits ',
      '({dplyr::n_distinct(d_input$full_name)} repos)'
      ))
  }


  # Look inside the repos
  d_files <- NULL
  d_sha <- NULL

  # start progress bar
  pb <- progress::progress_bar$new(
    format = "  downloading [:bar] :percent eta: :eta",
    clear = FALSE, width= 60,
    total = nrow(d_input)
    )

  for(i in 1:nrow(d_input)){
    if (interactive()) pb$tick()
    i_data <- d_input[i,]

    i <- i_data$full_name
    sha_repo <- i_data$sha

    sha <- gh::gh(
      "/repos/:full_name/git/commits/:sha",
      full_name = i,
      sha = sha_repo,
      .limit = Inf,
      .progress = FALSE,
      ...
    )$tree$sha

    files <- gh::gh(
      "/repos/:full_name/git/trees/:sha?recursive=1",
      full_name = i,
      sha = sha,
      .limit = Inf,
      .progress = FALSE,
      ...
      )$tree %>%
      purrr::map_chr("path") %>%
      tolower()

    d_files <- rbind(
      tibble::tibble(
        repo = i,
        file = files,
        sha_repo = sha_repo,
        sha_commit = sha,
        extension = sub('.*\\.', "", files)
      ),
      d_files
    )
  }

  # tidy up files
  d_files <- d_files %>%
    dplyr::mutate(
      extension = tolower(extension),
      lang = gh_filetype(extension)
    )

  d_files
}
