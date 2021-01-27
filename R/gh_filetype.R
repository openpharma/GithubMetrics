#' Take a file extension and recode it.
#'
#' @param x Thing to be recoded
#' @param extract_extension Do you first need to extract bit after period?
#'
#' @importFrom magrittr "%>%"
#'
#'
gh_filetype <- function(
  x,
  extract_extension = FALSE
) {
  if (extract_extension){
    x <- sub('.*\\.', "", x)
  }

  x <- tolower(x)

  dplyr::case_when(
    x %in% c("rd","r","rmd","rproj") ~ "R",
    x %in% c("html") ~ "HTML",
    x %in% c("md") ~ "Markdown",
    x %in% c("cmake") ~ "CMake",
    x %in% c("cpp") ~ "C++",
    x %in% c("css") ~ "CSS",
    x %in% c("m") ~ "Matlab",
    x %in% c("py") ~ "Python",
    x %in% c("ipynb") ~ "Jupyter Notebook",
    x %in% c("jar") ~ "Java",
    x %in% c("yml") ~ "YAML",
    x %in% c("sql") ~ "SQL",
    x %in% c("sh","cfg") ~ "Shell",
    x %in% c("sas") ~ "SAS",
    x %in% c("slurm") ~ "SLURM",
    x %in% c("h2o") ~ "H2O",
    x %in% c("keras") ~ "Keras",
    x %in% c("tensorflow") ~ "Tensorflow",
    x %in% c("sas") ~ "SAS",
    x %in% c("dxp") ~ "Spotfire",
    x %in% c(
      "twb","twbx"
    ) ~ "Tableau"
  )
}
