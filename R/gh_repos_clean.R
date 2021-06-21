#' Flatten repo list into a tibble
#'
#' @param orgs Returned object from \code{gh_repos_get()}
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
#'  \item{name}{Name of the repo}
#'  \item{full_name}{Org and name of repo}
#'  \item{size}{Raw size of the repo}
#'  \item{updated_at}{When it was last updated}
#'  \item{default_branch}{Name of the default branch}
#'  \item{language}{Github estimate of main language}
#'  \item{MB}{Size converted to MB}
#' }
#'
gh_repos_clean <- function(
  orgs
) {
  # If null, NA
  helper_null2na <- function(x){
    ifelse(is.null(x),NA,x)
  }

  # Loop through getting repo info from returned object
  d_orgs <- NULL
  for (i in 1:length(orgs)) {
    last_push <- orgs[[i]]$pushed_at
    # if never commited
    if (is.null(last_push)) {
      i_org <- tibble::tibble(
        name = orgs[[i]]$name
        ,full_name = orgs[[i]]$full_name
        #,description = orgs[[i]]$description
        ,size = orgs[[i]]$size
        ,updated_at = NA
        ,default_branch = orgs[[i]]$default_branch
        ,language = NA
      )
    } else {
      # otherwise get more info
      i_org <- tibble::tibble(
        name = orgs[[i]]$name
        ,full_name = orgs[[i]]$full_name
        ,description = helper_null2na(orgs[[i]]$description)
        ,size = orgs[[i]]$size
        ,updated_at = orgs[[i]]$pushed_at
        ,default_branch = orgs[[i]]$default_branch
        ,language = ifelse(
          is.null(orgs[[i]]$language),
          "Unsure",orgs[[i]]$language
        )
      )
    }
    d_orgs <- rbind(
      i_org,
      d_orgs
    )
  }
  # switch to MB for size
  d_orgs <- d_orgs %>%
    dplyr::mutate(
      MB = round(size/1024,1)
    )

  d_orgs
}
