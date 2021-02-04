library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  filter_sensitive_data = list("<<<my_api_key>>>" = Sys.getenv('GITHUB_PAT')),
  dir = vcr::vcr_test_path("fixtures")
))

if (!nzchar(Sys.getenv("GITHUB_PAT"))) {
  # BELOW IS NOT A REAL TOKEN
  # It required one of the right length - so took an old canceled one.
  Sys.setenv("GITHUB_PAT" = "c55635697d6f3a4b3adccaf2ef1a0918e3f14adf")
}

vcr::check_cassette_names()
