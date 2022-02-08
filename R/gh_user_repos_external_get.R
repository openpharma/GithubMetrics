#' Get repos interacted with outside user org
#'
#' It will return a vector or repos. It ONLY pulls first 100 currently
#' as no pagination in place.
#'
#' @param user The github username
#' @param token Github token
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#'
gh_user_repos_external_get <- function(
  user,
  token =  Sys.getenv("GITHUB_PAT")
) {

  con <- ghql::GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("Bearer ", token))
  )

  con$load_schema()
  qry <- ghql::Query$new()

  qry$query('mydata', '{
  user(login:"epijim") {
    repositoriesContributedTo(first: 100, contributionTypes: [COMMIT, ISSUE, PULL_REQUEST]) {
      nodes {
        nameWithOwner
      }
    }
  }

  }')
  other_repos <- con$exec(qry$queries$mydata)

  other_repos <- jsonlite::fromJSON(other_repos)

  other_repos <- other_repos$data$user$repositoriesContributedTo$nodes$nameWithOwner

  if(length(other_repos) > 99) warning("Paginition not implemented - some repos may")

  other_repos

}







