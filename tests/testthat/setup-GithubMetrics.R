library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  filter_sensitive_data = list("<<<my_api_key>>>" = Sys.getenv('GITHUB_PAT')),
  dir = vcr::vcr_test_path("fixtures")
))

if (!nzchar(Sys.getenv("GITHUB_PAT"))) {
  Sys.setenv("GITHUB_PAT" = "foobar")
}

vcr::check_cassette_names()
