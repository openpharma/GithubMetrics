#' Get org repos
#'
#' @param org Which Github org are you looking for
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#' @return Returns gh::gh_response object which contains repos in the org
#'
gh_repos_get <- function(
  org,
  ...
) {

  # who am I
  author_name <-
    gh::gh_whoami(
      .send_headers = NULL,...
    )$name

  # user orgs
  user_orgs <-
    gh::gh("/user/orgs",
           .limit = Inf,
           .progress = FALSE,
           ...
    )

  # what repos are in that org
  org_repos <-
    try(
      gh::gh("/orgs/:org/repos",
           org = org,
           .limit = Inf,
           .progress = FALSE,
           ...),
      silent = TRUE
    )

  if (inherits(org_repos, "try-error")) {
    org_repos <- gh::gh("/users/:org/repos",
           org = org,
           .limit = Inf,
           .progress = FALSE,
           ...)
  }


  org_repos
}
