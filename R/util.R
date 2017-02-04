
extract_digit <- function(x, n) x %/% 10^(n-1) %% 10

strip_numeric <- function(x) {
  x <- as.character(x)
  lx <- Map(function(ix) substr(x, ix, ix), seq_len(nchar(x)))
  as.integer(unlist(lx))
}


#' @export
is.valid <- function(x) UseMethod('is.valid', x)

