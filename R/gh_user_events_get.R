#' Get a users activity in last 90 days
#'
#' If Authenticated, and you ask for yourself (the authenticated user) you will
#' also get private activity. Otherwise it's just public.
#'
#' @param user The github username
#' @param ... Pass down to \code{gh}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'
#'
gh_user_event_get <- function(
  user,
  ...
) {

  events <- gh::gh("/users/:user/events",
                    user = user,
                    .limit = Inf,
                    .progress = FALSE,
                    ...
  )

  tibble::tibble(
    type = events %>% purrr::map_chr("type"),
    date = events %>% purrr::map_chr("created_at") %>% lubridate::as_date(),
    date_time = events %>% purrr::map_chr("created_at") %>% lubridate::as_datetime(),
    repo = events %>% purrr::map("repo") %>% purrr::map_chr("name")
  )

}







