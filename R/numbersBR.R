#' Validate, Compare and Format Identification Numbers From Brazil.
#'
#' This package helps handling identification numbers used in Brazil.
#' These numbers are used to identify individuals (CPF), vehicles (RENAVAN),
#' companies (CNPJ) and etc.
#' Functions to format, validate and compare these numbers have been
#' implemented in a vectorized way in order to speed up validations and
#' comparisons in big datasets.
#'
#' @author Wilson Freitas
#' @name numbersBR
#' @docType package
#'
#' @import stringr
NULL

#' Functions to create brazilian numbers objects
#'
#' The brazilian numbers used to identify individuals, vehicles, companies and
#' any other things have their own S3 classes.
#'
#' @param x the identification number as numeric or character
#'
#' @return A S3 class representing the brazilian number: CNPJ, CPF, RENAVAN
#'
#' @name numbers
NULL

#' Format numbers
#'
#' Formats the brazilian numbers according to their specific format.
#'
#' @param x the identification number class.
#' @param format can be strict which is the default format with all dots, dashes and hyphens or
#' stripped which returns only the numbers.
#' @param ... arguments to be passed to or from other methods.
#'
#' @return A character vector with the formatted number.
#'
#' @name format
NULL

#' Validate numbers
#'
#' Validates the brazilian numbers when it is necessary.
#' Not all identification numbers don't have a validation algorithm.
#'
#' @param x the identification number class.
#'
#' @return A logical vector indicating whether the number is valid or not.
#'
#' @name is.valid
NULL

#' Compare numbers among themselves, with numeric and character objects.
#'
#' Compares the brazilian numbers among themselves, with numeric and character objects.
#'
#' @param e1 the identification number class.
#' @param e2 the object to be compared with, can be of the same type of \code{e1}, a numeric or character vector
#'
#' @return A logical vector indicating that the given objects represent the same number.
#'
#' @name comparison-methods
NULL

