\name{fetchSCAN}
\alias{fetchSCAN}
\title{Fetch SCAN Data}
\description{Query soil/climate data from USDA-NRCS SCAN Stations (experimental)}
\usage{fetchSCAN(req)}

\arguments{
  \item{req}{a vector of named characters, e.g. 
  c(intervalType=' View Historic ', report='STO', timeseries='Daily', 
format='copy', sitenum='2072', interval='YEAR', year='2011', month='CY')}
}
\details{See examples, details pending.}
\value{a data.frame}
\references{http://www.wcc.nrcs.usda.gov/scan/}
\author{D.E. Beaudette}
\note{this is still an experimental function}

\examples{
\dontrun{
# soil / air temps
req <- c(intervalType=' View Historic ', report='STO', timeseries='Daily', 
format='copy', sitenum='2072', interval='YEAR', year='2011', month='CY')

# standard SCAN report
req <- c(intervalType=' View Historic ', report='SCAN', timeseries='Daily', 
format='copy', sitenum='2072', interval='YEAR', year='2011', month='CY')

# soil moisture
req <- c(intervalType=' View Historic ', report='27', timeseries='Daily', 
format='copy', sitenum='2072', interval='YEAR', year='2011', month='CY')

# soil moisture, hourly
req <- c(intervalType=' View Historic ', report='27', timeseries='Hourly', 
format='copy', sitenum='2072', interval='YEAR', year='2011', month='CY')

# get data, format into DF
x <- fetchSCAN(req)
}
}
\keyword{manip}
