# GitHub Copilot Instructions — numbersBR

## Priority Guidelines

When generating code for this repository:

1. **Version Compatibility**: This is an R package requiring R >= 3.2.2. Never use R features introduced after that baseline.
2. **Codebase Patterns First**: Strictly follow the patterns in the existing source files (`R/CPF.R`, `R/CNPJ.R`, `R/RENAVAN.R`, `R/util.R`). Every new number type must mirror those patterns exactly.
3. **S3 Only**: This package uses R's S3 object system exclusively. Never introduce S4, R5/Reference Classes, or R6.
4. **Vectorized by Default**: All constructor, format, validation, and comparison functions must operate on vectors, not scalars.
5. **Consistency Over Innovation**: Prioritize consistency with existing code over external best practices or newer language/package features.

---

## Technology Stack

| Item | Version / Detail |
|---|---|
| Language | R >= 3.2.2 |
| Package version | 0.0.2 (Semantic Versioning) |
| String manipulation | `stringr` (only imported dependency) |
| Documentation | `roxygen2` 6.0.1 — NAMESPACE is auto-generated, never edit by hand |
| Testing | `testthat` |
| Coverage | `covr` |

---

## Architecture

The package follows a flat, single-layer architecture. Each Brazilian identification number type lives in its own file (`R/<TYPE>.R`) and implements a fixed set of S3 methods. Shared utilities are in `R/util.R`. Generic documentation stubs reside in `R/numbersBR.R`.

### File Collation Order (defined in DESCRIPTION)

```
util.R → CNPJ.R → CPF.R → RENAVAN.R → numbersBR.R
```

Always add new number-type files before `numbersBR.R` in the `Collate:` field of `DESCRIPTION`.

---

## Code Patterns

### Constructor Function

Every number type must have a constructor that:
- Accepts `character` or `numeric` input (vectorized).
- Strips formatting separators with `stringr::str_replace_all`.
- Zero-pads to the canonical width with `stringr::str_pad(x, <WIDTH>, pad="0")`.
- Errors with `stop('Unsupported type ', class(x))` for any other type.
- Returns a character vector with the S3 class set via `structure(x, class='<TYPE>')`.

```r
NEWTYPE <- function(x) {
  if ( is.character(x) ) {
    x <- stringr::str_replace_all(x, '-', '')
    x <- stringr::str_replace_all(x, '\\.', '')
    # add other separators specific to this number type
    x <- stringr::str_pad(x, <WIDTH>, pad="0")
  } else if ( is.numeric(x) ) {
    x <- as.character(x)
    x <- stringr::str_pad(x, <WIDTH>, pad="0")
  } else {
    stop('Unsupported type ', class(x))
  }
  structure(x, class='NEWTYPE')
}
```

### format Method

- Signature: `format.TYPE <- function(x, format = c("strict", "stripped"), ...)`
- Always call `format = match.arg(format)` first.
- Call `x <- unclass(x)` before any string operations.
- `"strict"`: format with canonical separators using `sprintf` + `stringr::str_sub`.
- `"stripped"`: return `as.character(x)` (the zero-padded raw digits).

```r
format.NEWTYPE <- function(x, format = c("strict", "stripped"), ...) {
  format = match.arg(format)
  x = unclass(x)
  if (format == "strict")
    sprintf("<pattern>", stringr::str_sub(x, s1, e1), ...)
  else
    as.character(x)
}
```

### Coercion Methods

Both must delegate and have no additional logic:

```r
as.character.NEWTYPE <- function(x, ...) {
  format(x)
}

as.numeric.NEWTYPE <- function(x, ...) {
  x <- unclass(x)
  as.numeric(x)
}
```

### Comparison Operators

```r
`==.NEWTYPE` <- function(e1, e2) {
  unclass(e1) == unclass(NEWTYPE(e2))
}

`!=.NEWTYPE` <- function(e1, e2) {
  !(e1 == e2)
}
```

### print Method

```r
print.NEWTYPE <- function(x, ...) {
  x <- format(x)
  cat(x, '\n')
  invisible(x)
}
```

### Validation (is.valid)

- Dispatch is handled by the generic in `util.R`: `is.valid <- function(x) UseMethod('is.valid', x)`.
- Implement `is.valid.TYPE` using vectorized arithmetic on digits extracted with `extract_digit()`.
- For algorithms that cannot be trivially vectorized, use `Map` + `Reduce` + an inner helper function (see `is.valid.RENAVAN` as the reference).
- Always return a logical vector of the same length as the input.

---

## Utility Functions (`R/util.R`)

Two internal (non-exported) utilities are available:

| Function | Signature | Purpose |
|---|---|---|
| `extract_digit` | `extract_digit(x, n)` | Extracts the nth digit from the right of integer `x` using `x %/% 10^(n-1) %% 10`. Vectorized. |
| `strip_numeric` | `strip_numeric(x)` | Converts a number/string to an integer vector of its individual digits. Used in non-vectorizable validation loops. |

Do not add new utilities to `util.R` without a clear need. Prefer inline expressions when only one function uses a helper.

---

## Documentation (roxygen2)

### Generic stubs in `R/numbersBR.R`

Each publicly documented generic group has a stub with `@name <group>` and ends with `NULL`:

```r
#' <Title>
#'
#' <Description>
#'
#' @param x ...
#'
#' @return ...
#'
#' @name <group>
NULL
```

Existing groups: `numbers`, `format`, `is.valid`, `comparison-methods`.

### Method documentation

Each exported S3 method uses `@export` and `@rdname <group>` to attach to the appropriate group page, followed immediately by `@examples`:

```r
#' @export
#' @rdname numbers
#' @examples
#' NEWTYPE(c(12345678901, 98765432100))
NEWTYPE <- function(x) { ... }
```

- Never use `@param` or `@return` in individual method blocks — place those only in the generic stub.
- Every exported function must have at least one `@examples` block.

---

## Testing Patterns

Tests live in `tests/testthat/test-<TYPE>.R`. Follow this structure exactly:

```r
context('<TYPE>')

test_that('it should instanciate a <TYPE>', { ... })

test_that('it should not instanciate a <TYPE>', {
  expect_error(<TYPE>(NULL), 'Unsupported type')
})

test_that('it should check how <TYPE> is stored internally', { ... })

test_that('it should format <TYPE>', { ... })

test_that('it should convert <TYPE> into numeric', { ... })

test_that('it should convert <TYPE> into character', { ... })

test_that('it should <TYPE>`s equality', { ... })

test_that('it should validate <TYPE>', { ... })
```

### Naming rules
- `context()` value = the class name (e.g., `'CNPJ'`).
- `test_that` descriptions start with `'it should ...'`.

### Assertion style

| Scenario | Assertion |
|---|---|
| Class check | `expect_is(x, '<TYPE>')` |
| Internal storage | `expect_equal(unclass(x), ...)` |
| Formatted output | `expect_equal(format(x), ...)` or `expect_equal(format(x, "stripped"), ...)` |
| Validity TRUE | `expect_true(is.valid(x))` or `expect_true(all(is.valid(x)))` for vectors |
| Validity FALSE | `expect_false(is.valid(x))` |
| Mixed validity | `expect_equal(is.valid(x), c(T, F))` |
| Error | `expect_error(<call>, '<message substring>')` |
| Equality operator | `expect_true(x == ...)` / `expect_false(x != ...)` |

---

## DESCRIPTION Updates

When adding a new number type, update `DESCRIPTION`:
1. Add the new `'<TYPE>.R'` to `Collate:` before `'numbersBR.R'`.
2. Bump `Version:` following Semantic Versioning (MAJOR.MINOR.PATCH).
3. Update `Description:` to mention the new type.

---

## NAMESPACE

Never edit `NAMESPACE` manually. It is generated by `roxygen2::roxygenise()`. Ensure every exported function has `#' @export`.

---

## Versioning

This package uses **Semantic Versioning** (`MAJOR.MINOR.PATCH`):
- **PATCH**: bug fixes, internal refactoring.
- **MINOR**: new number types or new exported functions with backward compatibility.
- **MAJOR**: breaking API changes.

Changes are recorded in `NEWS.md` under `Changes in Version X.Y.Z`.

---

## General Best Practices

- All class names and file names use ALL-CAPS (e.g., `CPF`, `CNPJ`, `RENAVAN`).
- Internal functions are never exported and have no roxygen documentation.
- `stringr` is the only allowed string-manipulation library; do not introduce additional dependencies without updating `Imports:` in `DESCRIPTION`.
- Never use `library()` or `require()` inside package code; use `stringr::` namespace-qualified calls.
- Indentation in `R/CPF.R` and `R/CNPJ.R` uses tabs; `R/RENAVAN.R` uses spaces. Match the indentation of the file being edited.
