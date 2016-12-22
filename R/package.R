#' Automatically install missing packages when they are not found
#'
#' This function is intended to be used as an error option. It can be set using
#' \code{options(error = autoinst)}.
#' @export
autoinst <- function() {
  msg <- paste(lapply(sys.frame(-1)$args, as.character), collapse = "")
  m <- rematch2::re_match(msg, "there is no package called .([[:alnum:].]+).")
  if (m != -1) {
    pkg <- m[[1]]
    pkgs <- available_packages()
    if (!is.na(pkgs[, "Package"][pkg])) {
      message("Installing ", pkg)
      utils::install.packages(pkg, quiet = TRUE)
    } else {
      if (is.null(tryCatch(utils::packageVersion("devtools"), error = function(e) NULL))) {
        return()
      }
      gh_pkgs <- gh_pkgs()
      matches <- which(pkg == gh_pkgs$pkg_name)
      i <-
        if (length(matches) == 1) {
          if (get_answer(sprintf("Install '%s'? (Y/N): ", gh_pkgs$pkg_location[matches]), c("Y", "N")) == "Y") { 1 } else { "N" }
        } else if (length(matches) > 1) {
          nums <- as.character(seq_along(matches))
          width_nums <- max(nchar(nums))
          cat(multicol(paste0(sprintf(paste0("%", width_nums, "s"), nums), "| ", gh_pkgs$pkg_location[matches])), sep = "")
          get_answer(sprintf("Which package would you like to install? (1-%d, N): ", length(matches)), c(as.character(seq(1, length(matches))), "N"), "N")
        } else {
          "N"
        }
      if (i != "N") {
        devtools::install_github(gh_pkgs$pkg_location[matches[as.integer(i)]])
      }
    }
  }
}
options(error = autoinst)

available_packages <- memoise::memoise(utils::available.packages)

gh_pkgs <- memoise::memoise(function() {
  res <- jsonlite::fromJSON("http://rpkg.gepuro.net/download")
  res <- res$pkg_list
  res$pkg_location <- res$pkg_name
  res$pkg_org <- vapply(strsplit(res$pkg_location, "/"), `[[`, character(1), 1)
  res$pkg_name <- vapply(strsplit(res$pkg_location, "/"), `[[`, character(1), 2)
  res[!(res$pkg_org == "cran" | res$pkg_org == "Bioconductor-mirror" | res$pkg_name %in% available_packages()[, "Package"]), ]
})

get_answer <- function(msg, allowed, default) {
  if (!interactive()) {
    return(default)
  }
  repeat {
    cat(msg)
    answer <- readLines(n = 1)
    if (answer %in% allowed)
      return(answer)
  }
}

# From gaborcsardi/crayon/R/utils.r
multicol <- function(x) {
  xs <- x
  max_len <- max(nchar(xs))
  to_add <- max_len - nchar(xs) + 1
  x <- paste0(x, substring(paste0(collapse = "", rep(" ", max_len + 2)), 1, to_add))
  screen_width <- getOption("width")
  num_cols <- trunc(screen_width / max_len)
  num_rows <- ceiling(length(x) / num_cols)
  x <- c(x, rep("", num_cols * num_rows - length(x)))
  xm <- matrix(x, ncol = num_cols, byrow = TRUE)
  paste0(apply(xm, 1, paste, collapse = ""), "\n")
}
