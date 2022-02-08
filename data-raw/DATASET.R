library(GithubMetrics)

# repos
  repos <- c(
    "Roche/crmPack" ,
    "Roche/rtables",
    "openpharma/visR",
    "openpharma/GithubMetrics"
  )

# commits
  commits <- gh_commits_get(
    repos,
    days_back = 365*10
  )


  usethis::use_data(commits, overwrite = TRUE)

# issues
  issues <- gh_issues_get(repos, days_back =  365*10)

  usethis::use_data(issues, overwrite = TRUE)
