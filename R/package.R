#' Automatically install missing packages when they are not found
#'
#' This function is intended to be used as an error option. It can be set using
#' \code{options(error = autoinst)}.
#' @export
autoinst <- function() {
  msg <- paste(lapply(sys.frame(-1)$args, as.character), collapse = "")
  m <- rematch2::re_match(msg, "there is no package called .([[:alnum:]]+).")
  if (m != -1) {
    pkg <- m[[1]]
    pkgs <- utils::available.packages()
    if (!is.na(pkgs[, "Package"][pkg])) {
      message("Installing ", pkg)
      utils::install.packages(pkg, quiet = TRUE)
      if (as.character(sys.call(1)[[1]]) %in% c("::", ":::")) {
        print(eval(sys.call(1), envir = sys.frame(1)))
      } else {
        eval(sys.call(1), envir = sys.frame(1))
      }
    }
  }
}
