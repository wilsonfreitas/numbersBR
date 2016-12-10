#' @export
CPF <- function(x) {
  if ( is.character(x) ) {
    x <- stringr::str_replace_all(x, '-', '')
    x <- stringr::str_replace_all(x, '\\.', '')
    x <- stringr::str_pad(x, 11, pad="0")
  } else if ( is.numeric(x) ) {
    x <- as.character(x)
    x <- stringr::str_pad(x, 11, pad="0")
  } else {
    stop('Unsupported type ', class(x))
  }

  structure(x, class='CPF')
}

#' @export
format.CPF <- function(x, ...) {
  x <- unclass(x)
  sprintf("%s.%s.%s-%s",
          stringr::str_sub(x, 1, 3),
          stringr::str_sub(x, 4, 6),
          stringr::str_sub(x, 7, 9),
          stringr::str_sub(x, 10, 11))
}

#' @export
as.character.CPF <- function(x, ...) {
  format(x)
}

#' @export
as.numeric.CPF <- function(x, ...) {
  x <- unclass(x)
  as.numeric(x)
}

#' @export
is.valid.CPF <- function(x) {
  x1 <- as.numeric(x)

  a <-     1*extract_digit(x1, 11)
  a <- a + 2*extract_digit(x1, 10)
  a <- a + 3*extract_digit(x1, 9)
  a <- a + 4*extract_digit(x1, 8)
  a <- a + 5*extract_digit(x1, 7)
  a <- a + 6*extract_digit(x1, 6)
  a <- a + 7*extract_digit(x1, 5)
  a <- a + 8*extract_digit(x1, 4)
  a <- a + 9*extract_digit(x1, 3)
  a <- (a %% 11) %% 10

  b <-     1*extract_digit(x1, 10)
  b <- b + 2*extract_digit(x1, 9)
  b <- b + 3*extract_digit(x1, 8)
  b <- b + 4*extract_digit(x1, 7)
  b <- b + 5*extract_digit(x1, 6)
  b <- b + 6*extract_digit(x1, 5)
  b <- b + 7*extract_digit(x1, 4)
  b <- b + 8*extract_digit(x1, 3)
  b <- b + 9*extract_digit(x1, 2)
  b <- (b %% 11) %% 10

  a == extract_digit(x1, 2) & b == extract_digit(x1, 1)
}

#' @export
`==.CPF` <- function(e1, e2) {
  unclass(e1) == unclass(CPF(e2))
}

#' @export
`!=.CPF` <- function(e1, e2) {
  !(e1 == e2)
}

#' @export
print.CPF <- function(x, ...) {
  x <- format(x)
  cat(x, '\n')
  invisible(x)
}
