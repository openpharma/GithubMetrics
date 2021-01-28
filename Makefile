# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME = `sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
PKGVERS = `sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`

.PHONY: all build deploy

all: build deploy

build:
	R CMD INSTALL --no-multiarch --with-keep.source ../GithubMetrics
	Rscript  -e "devtools::document()"
	Rscript  -e "rmarkdown::render('README.Rmd', output_format = 'github_document')"

deploy:
	Rscript -e "pkgdown::deploy_to_branch()"
