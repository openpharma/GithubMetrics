#' Get files in a repo
#'
#' @param repo The repo name.
#' @param org The Github organisation name
#' @param file The filename (or path with filename if not in root)
#' @param return Defaults to returning file. Other option is \code{"sha"}
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
gh_file_get <- function(
  repo = "GithubMetrics",
  org = "OpenPharma",
  file = "DESCRIPTION",
  return = "file",
  ...
) {
    response <- gh::gh("/repos/:org/:repo/contents/:file",
           .limit = Inf,
           .progress = FALSE,
           org = org,
           repo = repo,
           file = file,
           return = "file",
           ...
    )

    if (return == "sha"){
      return(response$sha)
    }

    output <- response %>%
      magrittr::extract2("content") %>%
      base64enc::base64decode() %>%
      rawToChar()
}



