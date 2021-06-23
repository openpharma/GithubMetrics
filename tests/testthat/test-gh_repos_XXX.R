library(GithubMetrics)
library(tidyverse)
library(testthat)

organisation <- "openpharma"

vcr::use_cassette("gh_repos_get", {
  gh_repos_get <- gh_repos_get(org = organisation)
})

test_that("Can connect and see repos in org", {


  x <- length(gh_repos_get) > 3

  expect_true(x)
})

test_that("Clean the repos has write vars", {

  x <- gh_repos_clean(gh_repos_get)

  expect_equal(
    names(x),
    c("name","full_name","description","size","updated_at","default_branch","language","MB")
  )

})

test_that("Clean the repos has some data", {

  x <- gh_repos_clean(gh_repos_get)

  expect_true(nrow(x) > 0)
})



