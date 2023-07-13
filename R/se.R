#' Standard Error
#'
#' @param x a numeric vector or an R object
#' @param ... ellipses that refers to the na.rm of the sd function
#'
#' @return a value corresponding to the standard error of the vector
#' @export
#'
#' @examples
#' x <- c(2,3,2,3,4,5,1)
#' se(x)
#' data(iris)
#' se(iris$Sepal.Length)
se <- function(x, ...) {
  n <- length(x[!is.na(x)]) # calculate the length of the vector
  if (n > 2) { # <- only compute standard error for vector >= 2


    out <- sd(x, ...) / sqrt(n)
  } else {
    out <- NA
  }
  return(out)
}
