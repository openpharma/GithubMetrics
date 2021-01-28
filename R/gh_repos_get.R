#' Get org access
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

  author_name

  # user orgs
  user_orgs <-
    gh::gh("/user/orgs",
           .limit = Inf,
           .progress = FALSE,
           ...
    )

  if (!org %in% (user_orgs %>% purrr::map_chr("login"))) {

    pander::pander(paste0(
      "> <strong style = 'color: red;'>WARNING!</strong> User `",
      author_name,
      "` DOES NOT have access to `", org, "` GitHub organization.\n"
    ))

  }

  # what repos are in that org
  org_repos <-
    gh::gh("/orgs/:org/repos",
           org = org,
           .limit = Inf,
           .progress = FALSE,
           ...)


  org_repos
}
