
<!-- README.md is generated from README.Rmd. Please edit that file -->

# GithubMetrics

<!-- badges: start -->

[![R-CMD-check](https://github.com/openpharma/GithubMetrics/workflows/R-CMD-check/badge.svg)](https://github.com/openpharma/GithubMetrics/actions)
[![Codecov test
coverage](https://codecov.io/gh/openpharma/GithubMetrics/branch/master/graph/badge.svg)](https://codecov.io/gh/openpharma/GithubMetrics?branch=master)
[![HitCount](http://hits.dwyl.com/OpenPharma/GithubMetrics.svg)](http://hits.dwyl.com/OpenPharma/GithubMetrics)
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
library(glue)

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
#> Rows: 14
#> Columns: 7
#> $ name           <chr> "BBS-causality-training", "GithubMetrics", "facetsr", …
#> $ full_name      <chr> "openpharma/BBS-causality-training", "openpharma/Githu…
#> $ size           <int> 27, 118, 2163, 5435, 87, 939, 1817, 79487, 329, 0, 482…
#> $ updated_at     <chr> "2021-01-29T18:01:35Z", "2021-02-03T07:07:43Z", "2020-…
#> $ default_branch <chr> "main", "master", "master", "master", "master", "maste…
#> $ language       <chr> "R", "R", "R", "Unsure", "Python", "R", "C", "R", "R",…
#> $ MB             <dbl> 0.0, 0.1, 2.1, 5.3, 0.1, 0.9, 1.8, 77.6, 0.3, 0.0, 0.5…
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

glimpse(repo_all_commits)
#> Rows: 1,762
#> Columns: 5
#> $ full_name      <chr> "openpharma/BBS-causality-training", "openpharma/BBS-c…
#> $ author         <chr> "heinzmann537", "heinzmann537", "heinzmann537", "epiji…
#> $ datetime       <chr> "2021-01-29T18:00:10Z", "2021-01-29T12:55:54Z", "2021-…
#> $ sha            <chr> "5ac98df2a99db3b50abae114e37c00e433903094", "059569252…
#> $ commit_message <chr> "Update variable naming ADALM", "Small change", "First…
```

## People

Pull all the people that have committed in `r`.

``` r
contributors <- repo_all_commits %>%
  group_by(author) %>%
  summarise(
    commits = n()
  ) %>%
  filter(!author %in% c(".gitconfig missing email","actions-user"))
  
contributors <- contributors %>%
  left_join(
    gh_user_get(contributors$author),
    by = c("author"="username")
  )

contributors %>%
  arrange(-commits) %>%
  mutate(
    last_active = Sys.Date() - last_active,
    contributor = glue('<img src="{avatar}" alt="" height="30"> {author}'),
    blog = case_when(
      blog == "" ~ "",
      TRUE ~ as.character(glue('<a href="{blog}">link</a>'))
      )
    ) %>%
  select(contributor,commits,name,last_active,company,location,blog) %>%
  knitr::kable(
    
  )
```

| contributor                                                                                          | commits | name                | last\_active | company                            | location                | blog                                                     |
| :--------------------------------------------------------------------------------------------------- | ------: | :------------------ | :----------- | :--------------------------------- | :---------------------- | :------------------------------------------------------- |
| <img src="https://avatars.githubusercontent.com/u/134711?v=4" alt="" height="30"> evanmiller         |     936 | Evan Miller         | 17 days      | NA                                 | Chicago, IL             | <a href="https://www.evanmiller.org/">link</a>           |
| <img src="https://avatars.githubusercontent.com/u/47894155?v=4" alt="" height="30"> SHAESEN2         |     127 | Steven Haesendonckx | 20 days      | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/4087430?v=4" alt="" height="30"> diego-s           |     122 | Diego S             | 255 days     | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/19621679?v=4" alt="" height="30"> bailliem         |     109 | Mark Baillie        | 0 days       | NA                                 | Basel, CH               | <a href="https://graphicsprinciples.github.io/">link</a> |
| <img src="https://avatars.githubusercontent.com/u/2760096?v=4" alt="" height="30"> epijim            |      89 | James Black         | 5 days       | Roche                              | Basel, Switzerland      | <a href="www.epijim.uk">link</a>                         |
| <img src="https://avatars.githubusercontent.com/u/630869?v=4" alt="" height="30"> jaredhobbs         |      70 | Jared Hobbs         | 89 days      | YearEnd, Inc.                      | Salt Lake City, UT      | <a href="pyhacker.com">link</a>                          |
| <img src="https://avatars.githubusercontent.com/u/2522236?v=4" alt="" height="30"> kalimu            |      42 | Kamil Wais          | 9 days       | 7N / Roche                         | Rzeszów                 | <a href="kalimu.github.io">link</a>                      |
| <img src="https://avatars.githubusercontent.com/u/42960410?v=4" alt="" height="30"> Jonnie-Bevan     |      28 | NA                  | 63 days      | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/3072980?v=4" alt="" height="30"> cschaerfe         |      21 | Charlotta           | 118 days     | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/1036561?v=4" alt="" height="30"> davidanthoff      |      12 | David Anthoff       | 1 days       | University of California, Berkeley | Berkeley, CA            | <a href="www.david-anthoff.com">link</a>                 |
| <img src="https://avatars.githubusercontent.com/u/1190392?v=4" alt="" height="30"> jar1karp          |      12 | Jari Karppinen      | 154 days     | NA                                 | NA                      | <a href="https://finecon.tech">link</a>                  |
| <img src="https://avatars.githubusercontent.com/u/13412395?v=4" alt="" height="30"> mikmart          |      12 | Mikko Marttila      | 2 days       | NA                                 | NA                      | <a href="https://mikmart.rbind.io">link</a>              |
| <img src="https://avatars.githubusercontent.com/u/8436725?v=4" alt="" height="30"> reikoch           |       8 | NA                  | 6 days       | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/86842?v=4" alt="" height="30"> afeld               |       6 | Aidan Feldman       | 0 days       | @GSA and personal projects         | Brooklyn, NY            | <a href="https://api.afeld.me">link</a>                  |
| <img src="https://avatars.githubusercontent.com/u/14346503?v=4" alt="" height="30"> erblast          |       6 | Björn Oettinghaus   | 22 days      | NA                                 | Switzerland             | <a href="www.datisticsblog.com">link</a>                 |
| <img src="https://avatars.githubusercontent.com/u/4465050?v=4" alt="" height="30"> lionel-           |       6 | Lionel Henry        | 70 days      | @rstudio                           | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/3423010?v=4" alt="" height="30"> bpfoley           |       5 | Brian Foley         | 94 days      | NA                                 | Seattle, Washington     |                                                          |
| <img src="https://avatars.githubusercontent.com/u/64608407?v=4" alt="" height="30"> rebecca-albrecht |       4 | NA                  | 5 days       | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/12818242?v=4" alt="" height="30"> dazim            |       3 | Tim Treis           | 23 days      | NA                                 | Heidelberg, Germany     |                                                          |
| <img src="https://avatars.githubusercontent.com/u/78169972?v=4" alt="" height="30"> heinzmann537     |       3 | NA                  | 5 days       | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/63361362?v=4" alt="" height="30"> kentm4           |       3 | Matt Kent           | 2 days       | Genesis Research                   | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/70370146?v=4" alt="" height="30"> PaulJordan57     |       3 | NA                  | 19 days      | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/4296390?v=4" alt="" height="30"> galachad          |       2 | Adam Foryś          | 20 days      | @Roche                             | Warsaw, Poland          | <a href="http://temote.pl">link</a>                      |
| <img src="https://avatars.githubusercontent.com/u/13813876?v=4" alt="" height="30"> gerph            |       2 | Charles Ferguson    | 8 days       | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/4196?v=4" alt="" height="30"> hadley               |       2 | Hadley Wickham      | 0 days       | @rstudio                           | Houston, TX             | <a href="http://hadley.nz">link</a>                      |
| <img src="https://avatars.githubusercontent.com/u/12675476?v=4" alt="" height="30"> kawap            |       2 | NA                  | 289 days     | Roche / 7N                         | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/413418?v=4" alt="" height="30"> kleschenko         |       2 | Kostya Leschenko    | 5 days       | @datarobot                         | Lviv, Ukraine           |                                                          |
| <img src="https://avatars.githubusercontent.com/u/2666691?v=4" alt="" height="30"> kshedden          |       2 | Kerby Shedden       | 1 days       | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/1206052?v=4" alt="" height="30"> kurt-vd           |       2 | Kurt Van Dijck      | 63 days      | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/306380?v=4" alt="" height="30"> mrocklin           |       2 | Matthew Rocklin     | 2 days       | @coiled                            | San Juan Capistrano, CA | <a href="https://coiled.io">link</a>                     |
| <img src="https://avatars.githubusercontent.com/u/11788080?v=4" alt="" height="30"> thomas-neitmann  |       2 | Thomas Neitmann     | 1 days       | Roche                              | Basel, Switzerland      | <a href="https://thomasadventure.blog/">link</a>         |
| <img src="https://avatars.githubusercontent.com/u/7786462?v=4" alt="" height="30"> waddella          |       2 | Adrian Waddell      | 27 days      | NA                                 | NA                      | <a href="http://adrian.waddell.ch">link</a>              |
| <img src="https://avatars.githubusercontent.com/u/6396159?v=4" alt="" height="30"> ararslan          |       1 | Alex Arslan         | 0 days       | Beacon Biosignals                  | Seattle, WA             |                                                          |
| <img src="https://avatars.githubusercontent.com/u/7089667?v=4" alt="" height="30"> ginberg           |       1 | NA                  | 14 days      | NA                                 | Remote                  | <a href="gerinberg.com">link</a>                         |
| <img src="https://avatars.githubusercontent.com/u/74075?v=4" alt="" height="30"> ivarref             |       1 | Ivar Refsdal        | 13 days      | NA                                 | Bergen, Norway          |                                                          |
| <img src="https://avatars.githubusercontent.com/u/3240247?v=4" alt="" height="30"> jonathon-love     |       1 | Jonathon Love       | 1 days       | NA                                 | NA                      | <a href="http://jona.thon.love">link</a>                 |
| <img src="https://avatars.githubusercontent.com/u/60743662?v=4" alt="" height="30"> Karissa          |       1 | NA                  | 363 days     | NA                                 | NA                      |                                                          |
| <img src="https://avatars.githubusercontent.com/u/61869726?v=4" alt="" height="30"> thanos-siadimas  |       1 | NA                  | 1 days       | NA                                 | NA                      |                                                          |

## Files

Pull a specific file using `gh_file_get()`.

``` r
desc_formatted <- gh_file_get(
  repo = "GithubMetrics",
  org = "OpenPharma",
  file = "DESCRIPTION"
) %>%
  # format the description
  desc::desc(text = .)

# Print it
desc_formatted$get(c("Package","Title","Version")) %>%
  tibble::enframe() %>%
  knitr::kable()
```

| name    | value                                          |
| :------ | :--------------------------------------------- |
| Package | GithubMetrics                                  |
| Title   | Quickly get key metrics on Github repositaries |
| Version | 0.1.0                                          |

Get all of the files present in the last commit of all the repos using
`gh_repo_files_get()`.

``` r
repo_files <- gh_repo_files_get(
  repo_commits = repo_all_commits,
  only_last_commit = TRUE
)
#> Pulling files in latest commit from 13 repos

glimpse(repo_files)
#> Rows: 1,311
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

| repo                              | Files | R files | Python files |
| :-------------------------------- | ----: | ------: | -----------: |
| openpharma/BBS-causality-training |     4 |       2 |            0 |
| openpharma/CTP                    |   100 |      30 |            0 |
| openpharma/facetsr                |    63 |      13 |            0 |
| openpharma/GithubMetrics          |    43 |      22 |            0 |
| openpharma/openpharma.github.io   |    76 |       1 |            0 |
| openpharma/pypharma\_nlp          |   131 |       0 |           49 |
| openpharma/RDO                    |   105 |      11 |            0 |
| openpharma/ReadStat               |   207 |       0 |            0 |
| openpharma/sas7bdat               |     8 |       0 |            2 |
| openpharma/simaerep               |   145 |      32 |            0 |
| openpharma/syntrial               |    67 |      24 |            0 |
| openpharma/visR                   |   177 |      81 |            0 |
| openpharma/visR-docs              |   185 |       0 |            0 |

Types of files in the organisation

``` r
results <- gh_repo_search(
  code = "tidyverse",
  organisation = organisation
)

glimpse(results)
#> Rows: 12
#> Columns: 7
#> $ full_name <chr> "openpharma/GithubMetrics", "openpharma/GithubMetrics", "op…
#> $ name      <chr> "GithubMetrics", "GithubMetrics", "GithubMetrics", "GithubM…
#> $ file_name <chr> "README.md", "README.Rmd", "DESCRIPTION", "test-gh_repos_XX…
#> $ path      <chr> "README.md", "README.Rmd", "DESCRIPTION", "tests/testthat/t…
#> $ url       <chr> "https://github.com/openpharma/GithubMetrics/blob/fa7764869…
#> $ score     <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
#> $ lang      <chr> "Markdown", "R", NA, "R", "Markdown", "R", "Markdown", "R",…
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
      helper_gh_repo_search, org = "PHCAnalytics"
    ),
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
#> pkgdown does not appear in PHCAnalytics.
#> query = 'pkgdown in:file  user:PHCAnalytics'
#> tidyverse does not appear in AstraZeneca.
#> query = 'tidyverse in:file  user:AstraZeneca'
#> pkgdown does not appear in AstraZeneca.
#> query = 'pkgdown in:file  user:AstraZeneca'
#> data.table does not appear in AstraZeneca.
#> query = 'data.table in:file  user:AstraZeneca'


package_use %>%
  pivot_wider(names_from = "Package", values_from = "Repos") %>%
  mutate(Total = rowSums(.[,-1], na.rm = TRUE)) %>%
  arrange(-Total) %>%
  knitr::kable(
    caption = "Package use detected within repositaries in Pharma orgs"
  )
```

| Organisation | tidyverse | dplyr | data.table | pkgdown | Total |
| :----------- | --------: | ----: | ---------: | ------: | ----: |
| Novartis     |         4 |    10 |         12 |       6 |    32 |
| openpharma   |         4 |     6 |          2 |       6 |    18 |
| Roche        |         3 |     2 |          3 |       3 |    11 |
| Genentech    |         3 |     3 |          3 |       2 |    11 |
| PHCAnalytics |         2 |     4 |          4 |      NA |    10 |
| AstraZeneca  |        NA |     1 |         NA |      NA |     1 |

Package use detected within repositaries in Pharma orgs
