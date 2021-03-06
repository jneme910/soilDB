\name{uncode}
\alias{metadata}
\alias{uncode}
\alias{code}
\title{Convert coded values returned from NASIS and SDA queries to factors}
\description{These functions convert the coded values returned from NASIS or SDA to factors (e.g. 1 = Alfisols) using the metadata tables from NASIS. For SDA the metadata is pulled from a static snapshot in the soilDB package (/data/metadata.rda).}
\usage{
uncode(df, invert = FALSE, NASIS = TRUE)
code(df, invert = TRUE, NASIS = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{df}{data.frame}
  \item{invert}{converts the code labels back to their coded values()}
  \item{NASIS}{a logical argument indicating whether or not to query metadata from NASIS or use soilDB-local snapshot}
  }
\details{These functions convert the coded values returned from NASIS into plaintext representation. The converted values from NASIS, or sourced from SDA, are upgraded to spefically-leveled factors using the metadata tables from NASIS. For SDA the metadata is pulled from a static snapshot in the soilDB package.
}
\value{A dataframe with the results.}
\author{Stephen Roecker}
\examples{
\dontrun{
# query component by nationalmusym
comp = fetchSDA_component(WHERE = "nationalmusym = '2vzcp'")
s = site(comp$spc)
s = uncode(s, NASIS = FALSE)
levels(s$taxorder)
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{manip}% use one of  RShowDoc("KEYWORDS")
