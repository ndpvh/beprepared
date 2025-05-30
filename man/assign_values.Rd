% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assign_values.R
\name{assign_values}
\alias{assign_values}
\title{Assign values for QVEmod's parameters}
\usage{
assign_values(id, parameters)
}
\arguments{
\item{id}{Vector containing the different id's to assign the values to.}

\item{parameters}{Data.frame containing several columns that denote the parameters 
to assign to the QVEmod classes. Should at least contain a column \code{prob} 
which contains the probability with which to assign the parameters in that row 
to a random \code{id}.}
}
\value{
Data.frame containing the \code{id}s and their assigned values for 
the \code{QVEmod} classes.
}
\description{
Assign values for QVEmod's parameters
}
