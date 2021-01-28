
<!-- README.md is generated from README.Rmd. Please edit that file -->

# GithubMetrics

<!-- badges: start -->
[![R build status](https://github.com/openpharma/GithubMetrics/workflows/R-CMD-check/badge.svg){target='_blank'}](https://github.com/openpharma/GithubMetrics/actions)
<!-- badges: end -->

The aim of this package is to provide a wrapper on `gh` to quickly get
you key Github repo information you need.The code here is used within
Roche to quickly let me pull answer simple questions like:

  - How many studies have more than 1 data scientist (and roughly what’s
    the commit split)
  - What are the common languages being used (proxied through file type
    distribution within repos)
  - Pull commit metadata to enrich other study info held in other
    systems

## Installation

You can install the released version of GithubMetrics from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("GithubMetrics")
```

## Setup

``` r
library(GithubMetrics)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────────────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.3     ✓ purrr   0.3.4
#> ✓ tibble  3.0.5     ✓ dplyr   1.0.3
#> ✓ tidyr   1.1.2     ✓ stringr 1.4.0
#> ✓ readr   1.4.0     ✓ forcats 0.5.0
#> ── Conflicts ────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()

organisation <- "openpharma"
```

## Repos in an org

Pull all the repos present within an org (that I can see).

``` r
repos_raw <- gh_repos_get(
  org = organisation
  )

repos_clean <- gh_repos_clean(repos_raw)

glimpse(repos_clean) 
#> Rows: 13
#> Columns: 7
#> $ name           <chr> "GithubMetrics", "facetsr", "visR-docs", "sas7bdat", "…
#> $ full_name      <chr> "openpharma/GithubMetrics", "openpharma/facetsr", "ope…
#> $ size           <int> 0, 2163, 5435, 87, 939, 1817, 79487, 329, 0, 482, 2863…
#> $ updated_at     <chr> "2021-01-27T22:25:48Z", "2020-11-30T12:37:13Z", "2020-…
#> $ default_branch <chr> "master", "master", "master", "master", "master", "mas…
#> $ language       <chr> "R", "R", "Unsure", "Python", "R", "C", "R", "R", "Uns…
#> $ MB             <dbl> 0.0, 2.1, 5.3, 0.1, 0.9, 1.8, 77.6, 0.3, 0.0, 0.5, 28.…
```

Realistically, research code is likely to be on Github Enterprise, so
the `.api_url` and `.token` parameters can be passed through to `gh()`.
Commented code below shows how you can use an on-premise Github server.

``` r
# repos_raw <- gh_repos_get(
#   org = organisation,
#   .api_url = "https://github.roche.com/api/v3",
#   .token = Sys.getenv("GITHUB_PAT_ROCHE")
#   )
```

## Commits

Get every commit for all the repos in this organisation.

``` r
repo_all_commits <- gh_commits_get(
  repos_clean %>% filter(size > 0) %>% pull(full_name), 
  days_back = 365*10
)
#> ℹ Running gh query[K ℹ Running gh query, got 100 records of about 200[K [K ℹ
#> Running gh query[K ℹ Running gh query, got 100 records of about 1000[K ℹ Running
#> gh query, got 300 records of about 1500[K ℹ Running gh query, got 600 records
#> of about 2000[K ℹ Running gh query, got 1000 records of about 2500[K ℹ Running
#> gh query, got 1500 records of about 3000[K ℹ Running gh query, got 2100 records
#> of about 3500[K ℹ Running gh query, got 2800 records of about 4000[K ℹ Running
#> gh query, got 3600 records of about 4500[K ℹ Running gh query, got 4500 records
#> of about 5000[K [K ℹ Running gh query[K ℹ Running gh query, got 100 records of
#> about 200[K [K ℹ Running gh query[K ℹ Running gh query, got 100 records of about
#> 500[K ℹ Running gh query, got 300 records of about 750[K ℹ Running gh query, got
#> 600 records of about 1000[K ℹ Running gh query, got 1000 records of about 1250[K
#> [K

glimpse(repo_all_commits)
#> Rows: 1,739
#> Columns: 5
#> $ full_name      <chr> "openpharma/facetsr", "openpharma/visR-docs", "openpha…
#> $ author         <chr> "galachad", "Jonnie-Bevan", "actions-user", "actions-u…
#> $ datetime       <chr> "2020-11-30T11:40:03Z", "2020-09-21T09:45:33Z", "2020-…
#> $ sha            <chr> "cef40b2227f169d4caa8b8936f0ae25b76f2b53f", "5b35fdbc3…
#> $ commit_message <chr> "Opensource init relese", "Update README.md", "Publish…
```

## Files

Get all of the files present in the last commit of all the repos.

``` r
repo_files <- gh_repo_files_get(
  repo_commits = repo_all_commits,
  only_last_commit = TRUE
)
#> Pulling files in latest commit from 11 repos
#>   downloading [====>-------------------------]  18% eta:  2s  downloading [=======>----------------------]  27% eta:  2s  downloading [==========>-------------------]  36% eta:  2s  downloading [=============>----------------]  45% eta:  2s  downloading [===============>--------------]  55% eta:  2s  downloading [==================>-----------]  64% eta:  1s  downloading [=====================>--------]  73% eta:  1s  downloading [========================>-----]  82% eta:  1s  downloading [==========================>---]  91% eta:  0s  downloading [==============================] 100% eta:  0s

glimpse(repo_files)
#> Rows: 1,264
#> Columns: 6
#> $ repo       <chr> "openpharma/visR-docs", "openpharma/visR-docs", "openpharm…
#> $ file       <chr> "readme.md", "docs", "docs/404.html", "docs/code_of_conduc…
#> $ sha_repo   <chr> "5b35fdbc39b87a154c9426e363c8f5a2c83d66b0", "5b35fdbc39b87…
#> $ sha_commit <chr> "642856728e165746076a17c6522b9264f693f37d", "642856728e165…
#> $ extension  <chr> "md", "docs", "html", "html", "html", "html", "png", "png"…
#> $ lang       <chr> "Markdown", NA, "HTML", "HTML", "HTML", "HTML", NA, NA, NA…

repo_files %>%
  group_by(repo) %>%
  summarise(
    Files = n(),
    `R files` = sum(lang %in% "R"),
    `Python files` = sum(lang %in% c("Python","Jupyter Notebook"))
  ) %>% knitr::kable(
    caption = "Types of files in the organisation"
  )
```

| repo                            | Files | R files | Python files |
| :------------------------------ | ----: | ------: | -----------: |
| openpharma/CTP                  |   100 |      30 |            0 |
| openpharma/facetsr              |    63 |      13 |            0 |
| openpharma/openpharma.github.io |    76 |       1 |            0 |
| openpharma/pypharma\_nlp        |   131 |       0 |           49 |
| openpharma/RDO                  |   105 |      11 |            0 |
| openpharma/ReadStat             |   207 |       0 |            0 |
| openpharma/sas7bdat             |     8 |       0 |            2 |
| openpharma/simaerep             |   145 |      32 |            0 |
| openpharma/syntrial             |    67 |      24 |            0 |
| openpharma/visR                 |   177 |      81 |            0 |
| openpharma/visR-docs            |   185 |       0 |            0 |

Types of files in the organisation

``` r
results <- gh_repo_search(
  code = "tidyverse",
  organisation = organisation
)

glimpse(results)
#> Rows: 10
#> Columns: 7
#> $ full_name <chr> "openpharma/GithubMetrics", "openpharma/GithubMetrics", "op…
#> $ name      <chr> "GithubMetrics", "GithubMetrics", "facetsr", "facetsr", "vi…
#> $ file_name <chr> "README.md", "README.Rmd", "README.md", "README.Rmd", "READ…
#> $ path      <chr> "README.md", "README.Rmd", "README.md", "README.Rmd", "READ…
#> $ url       <chr> "https://github.com/openpharma/GithubMetrics/blob/5ff1d4aaf…
#> $ score     <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
#> $ lang      <chr> "Markdown", "R", "Markdown", "R", "Markdown", "R", "R", "R"…
```

``` r
helper_gh_repo_search <- function(x, org = "openpharma"){
  
  ## Slow it down! as search has 30 calls a minute rate limit.
  ## If you prem the search rate limit is higher, so usually not needed
  if(interactive()){message("Wait 5 seconds")}
  Sys.sleep(5)
  ## End slow down
  
  
   results <- gh_repo_search(
      code = x,
      organisation = org
    ) 
   
  if(is.na(results)) {
    results <- return()
  }
  results %>% 
    mutate(Package = x, Organisation = org) %>%
    group_by(Organisation,Package) %>%
    summarise(
      Repos = n_distinct(full_name), .groups = "drop"
    )
}

packages <- c(
  "tidyverse","pkgdown","dplyr","data.table"
  )

package_use <- bind_rows(
  packages %>%
    map_df(
      helper_gh_repo_search, org = "openpharma"
    ),
  packages %>%
    map_df(
      helper_gh_repo_search, org = "AstraZeneca"
    ),
  packages %>%
    map_df(
      helper_gh_repo_search, org = "Roche"
    ),
  packages %>%
    map_df(
      helper_gh_repo_search, org = "Genentech"
    ),
  packages %>%
    map_df(
      helper_gh_repo_search, org = "Novartis"
    )
)
#> tidyverse does not appear in AstraZeneca.
#> query = 'tidyverse in:file  user:AstraZeneca'
#> pkgdown does not appear in AstraZeneca.
#> query = 'pkgdown in:file  user:AstraZeneca'
#> data.table does not appear in AstraZeneca.
#> query = 'data.table in:file  user:AstraZeneca'
#> ℹ Running gh query[K ℹ Running gh query, got 3 records of about 6[K [K ℹ Running
#> gh query[K ℹ Running gh query, got 3 records of about 6[K [K ℹ Running gh
#> query[K ℹ Running gh query, got 3 records of about 6[K [K


package_use %>%
  pivot_wider(names_from = "Package", values_from = "Repos") %>%
  mutate(Total = rowSums(.[,-1], na.rm = TRUE)) %>%
  arrange(-Total) %>%
  knitr::kable(
    caption = "Package use detected within repositaries in Pharma orgs"
  )
```

| Organisation | tidyverse | pkgdown | dplyr | data.table | Total |
| :----------- | --------: | ------: | ----: | ---------: | ----: |
| Novartis     |         4 |       5 |    10 |         12 |    31 |
| openpharma   |         4 |       6 |     5 |          2 |    17 |
| Roche        |         3 |       3 |     2 |          3 |    11 |
| Genentech    |         3 |       2 |     3 |          3 |    11 |
| AstraZeneca  |        NA |      NA |     1 |         NA |     1 |

Package use detected within repositaries in Pharma orgs
