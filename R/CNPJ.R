#' @export
CNPJ <- function(x) {
  if ( is.character(x) ) {
    x <- stringr::str_replace_all(x, '-', '')
    x <- stringr::str_replace_all(x, '\\.', '')
    x <- stringr::str_replace_all(x, '/', '')
    x <- stringr::str_pad(x, 14, pad="0")
  } else if ( is.numeric(x) ) {
    x <- as.character(x)
    x <- stringr::str_pad(x, 14, pad="0")
  } else {
    stop('Unsupported type ', class(x))
  }

  structure(x, class='CNPJ')
}

#' @export
format.CNPJ <- function(x, format = c("strict", "stripped"), ...) {
  format = match.arg(format)
  x = unclass(x)
  if (format == "strict")
    sprintf("%s.%s.%s/%s-%s",
            stringr::str_sub(x, 1, 2),
            stringr::str_sub(x, 3, 5),
            stringr::str_sub(x, 6, 8),
            stringr::str_sub(x, 9, 12),
            stringr::str_sub(x, 13, 14))
  else
    as.character(x)
}

#' @export
as.character.CNPJ <- function(x, ...) {
  format(x)
}

#' @export
as.numeric.CNPJ <- function(x, ...) {
  x <- unclass(x)
  as.numeric(x)
}

#' @export
is.valid.CNPJ <- function(x) {
  x <- unclass(x)
  x1 <- as.numeric(stringr::str_sub(x, 1, 12))
  v1 <- as.integer(stringr::str_sub(x, 13, 13))
  v2 <- as.integer(stringr::str_sub(x, 14, 14))

  a <- 5*extract_digit(x1, 12)
  a <- a + 4*extract_digit(x1, 11)
  a <- a + 3*extract_digit(x1, 10)
  a <- a + 2*extract_digit(x1, 9)
  a <- a + 9*extract_digit(x1, 8)
  a <- a + 8*extract_digit(x1, 7)
  a <- a + 7*extract_digit(x1, 6)
  a <- a + 6*extract_digit(x1, 5)
  a <- a + 5*extract_digit(x1, 4)
  a <- a + 4*extract_digit(x1, 3)
  a <- a + 3*extract_digit(x1, 2)
  a <- a + 2*extract_digit(x1, 1)
  a <- 11 - a %% 11
  a[a >= 10] <- 0

  b <- 6*extract_digit(x1, 12)
  b <- b + 5*extract_digit(x1, 11)
  b <- b + 4*extract_digit(x1, 10)
  b <- b + 3*extract_digit(x1, 9)
  b <- b + 2*extract_digit(x1, 8)
  b <- b + 9*extract_digit(x1, 7)
  b <- b + 8*extract_digit(x1, 6)
  b <- b + 7*extract_digit(x1, 5)
  b <- b + 6*extract_digit(x1, 4)
  b <- b + 5*extract_digit(x1, 3)
  b <- b + 4*extract_digit(x1, 2)
  b <- b + 3*extract_digit(x1, 1)
  b <- b + 2*v1
  b <- 11 - b %% 11
  b[b >= 10] <- 0

  a == v1 & b == v2
}

#' @export
`==.CNPJ` <- function(e1, e2) {
  unclass(e1) == unclass(CNPJ(e2))
}

#' @export
`!=.CNPJ` <- function(e1, e2) {
  !(e1 == e2)
}

#' @export
print.CNPJ <- function(x, ...) {
  x <- format(x)
  cat(x, '\n')
  invisible(x)
}
