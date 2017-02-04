#' @export
RENAVAN <- function(x) {
  if ( is.character(x) ) {
    x <- stringr::str_pad(x, 11, pad="0")
  } else if ( is.numeric(x) ) {
    x <- as.character(x)
    x <- stringr::str_pad(x, 11, pad="0")
  } else {
    stop('Unsupported type ', class(x))
  }

  structure(x, class='RENAVAN')
}

#' @export
format.RENAVAN <- function(x, ...) {
  x <- unclass(x)
  as.character(x)
}

#' @export
as.character.RENAVAN <- function(x, ...) {
  format(x)
}

#' @export
as.numeric.RENAVAN <- function(x, ...) {
  x <- unclass(x)
  as.numeric(x)
}

#' @export
is.valid.RENAVAN <- function(x) {
  check_renavan <- function(renavan) {
    renavan <- strip_numeric(renavan)
    control <- strip_numeric(3298765432)

    sum_ <- Reduce(sum, Map(function(x, y) x * y, renavan[-length(renavan)], control))

    digit_ <- 11L - sum_ %% 11L
    digit_ <- if (digit_ < 10L) digit_ else 0L

    renavan[length(renavan)] == digit_
  }
  renavan <- as.numeric(x)
  unlist( Map(check_renavan, renavan) )
}

#' @export
`==.RENAVAN` <- function(e1, e2) {
  unclass(e1) == unclass(RENAVAN(e2))
}

#' @export
`!=.RENAVAN` <- function(e1, e2) {
  !(e1 == e2)
}

#' @export
print.RENAVAN <- function(x, ...) {
  x <- format(x)
  cat(x, '\n')
  invisible(x)
}
