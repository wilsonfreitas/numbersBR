# numbersBR

[![Travis build status](https://travis-ci.org/wilsonfreitas/numbersBR.svg?branch=master)](https://travis-ci.org/wilsonfreitas/numbersBR) [![Coverage status](https://codecov.io/gh/wilsonfreitas/numbersBR/branch/master/graph/badge.svg)](https://codecov.io/github/wilsonfreitas/numbersBR?branch=master)


The numbersBR package aims to help with brazilian numbers used to identify companies, individuals and cars (CNPJ, CPF and RENAVAN, for example).

The package provides functions to validate, format and execute comparisons of these numbers when they come in different formats.
For example, compare a numeric CPF against a character CPF.
The functions are implemented in a vectorized way in order to speed up validations and comparison in large datasets.

## Install

From CRAN

```{r}
install.packages('numbersBR')
```

The package also can be installed directly from github using devtools.

```{r}
devtools::install_github('wilsonfreitas/numbersBR')
```

## Using

The numbers can be created with numeric or character vectors:

```{r}
> x <- CNPJ(13515463000138)
> x
13.515.463/0001-38 
> is.valid(x)
[1] TRUE
> x == 13515463000138
[1] TRUE
> x <- CPF(c("681.943.594-06", "012.391.576-73", "520.082.755-82"))
> x
681.943.594-06 012.391.576-73 520.082.755-82 
> is.valid(x)
[1] TRUE TRUE TRUE
> x == 68194359406
[1]  TRUE FALSE FALSE
> x <- RENAVAN(c(75320797785, 91671999129))
> is.valid(x)
[1] TRUE TRUE
```

## Contribute

For now we have CPF, CNPJ and RENAVAN implemented, so if you need another number or, even better, if you have it implemented, get in touch so we can add new numbers to the package.
