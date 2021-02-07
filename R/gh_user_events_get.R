#' Get a users activity in last 90 days (if authenticated also get private for yourself)
#'
#' @param user The github username (if authenticated will see private as well).
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







