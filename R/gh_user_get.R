#' Get files in a repo
#'
#' @param user Character vector with Github username (called author in their objs)
#' @param ... Pass down options to \code{gh::gh()}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#'
gh_user_get <- function(
  user,
  ...
) {

  # start progress bar
  pb <- progress::progress_bar$new(
    format = "  getting users [:bar] :percent eta: :eta",
    clear = FALSE, width= 60,
    total = length(user)
    )

  output <- tibble::tibble(
    username = character(),
    avatar = character(),
    name = character(),
    blog = character(),
    joined = character(),
    last_active = character(),
    location = character(),
    company = character(),
    email = character(),
    bio = character()
  )

  for(i_user in user){
    if (interactive()) pb$tick()

    i_returned <- gh::gh(
      "/users/:user",
      user = i_user,
      .limit = Inf,
      .progress = FALSE,
      ...
    )

    output <- dplyr::bind_rows(
      tibble::tibble(
        username = null_to_na(i_returned$login),
        avatar = null_to_na(i_returned$avatar_url),
        name = null_to_na(i_returned$name),
        blog = null_to_na(i_returned$blog),
        joined = null_to_na(i_returned$created_at),
        last_active = null_to_na(i_returned$updated_at),
        location = null_to_na(i_returned$location),
        company = null_to_na(i_returned$company),
        email = null_to_na(i_returned$email),
        bio = null_to_na(i_returned$bio)
      ),
      output
    )
  }


  output %>%
    dplyr::mutate(
      joined = as.Date(joined),
      last_active = as.Date(last_active)
    )
}

null_to_na <- function(x){
  ifelse(!is.null(x),x,NA)
}
