library(GithubMetrics)
library(tidyverse)
library(testthat)

organisation <- "openpharma"

test_that("Can connect and see repos in org", {
  vcr::use_cassette("gh_repos_get", {
    x <- length(gh_repos_get(org = organisation)) > 3
  })
  expect_true(x)
})


