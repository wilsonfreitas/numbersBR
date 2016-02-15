
extract_digit <- function(x, n) x %/% 10^(n-1) %% 10

#' @export
is.valid <- function(x) UseMethod('is.valid', x)

