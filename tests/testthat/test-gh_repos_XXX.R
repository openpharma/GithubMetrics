library(GithubMetrics)
library(tidyverse)
library(testthat)

organisation <- "openpharma"

test_that("Can connect and see repos in org", {
  vcr::use_cassette("gh_repos_get", {
    x <- gh_repos_get(org = organisation)
  })

  x <- length(x) > 3

  expect_equal(x)
})

test_that("Clean the repos", {
  vcr::use_cassette("gh_repos_get", {
    x <- gh_repos_get(org = organisation)
  })

  x <- gh_repos_clean(x)

  expect_equal(
    names(x),
    c("name","full_name","size","updated_at","default_branch","language","MB")
  )

  expect_true(nrow(x) > 0)
})



