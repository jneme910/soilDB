get_projectmapunit_from_NASIS <- function() {
  # must have RODBC installed
  if(!requireNamespace('RODBC'))
    stop('please install the `RODBC` package', call.=FALSE)
  
  q <- paste("SELECT p.projectiid, p.uprojectid, p.projectname, a2.areasymbol, lmu.musym, lmu.lmapunitiid AS mukey, mu.nationalmusym, mutype, muname, muacres
             
             FROM 
             project_View_1 p LEFT OUTER JOIN
             projectmapunit pmu ON pmu.projectiidref = p.projectiid LEFT OUTER JOIN 
             mapunit mu ON mu.muiid = pmu.muiidref LEFT OUTER JOIN
             lmapunit lmu ON lmu.muiidref = mu.muiid LEFT OUTER JOIN
             legend l ON l.liid = lmu.liidref
             
             INNER JOIN 
             area a ON a.areaiid = p.mlrassoareaiidref
             LEFT OUTER JOIN
             area a2 ON a2.areaiid = l.areaiidref
             
             WHERE l.legendsuituse != 1 OR l.legendsuituse IS NULL
             
             ORDER BY p.projectname, a.areasymbol, lmu.musym;"
  )
  
  
  # setup connection local NASIS
  channel <- RODBC::odbcDriverConnect(connection="DSN=nasis_local;UID=NasisSqlRO;PWD=nasisRe@d0n1y")
  
  
  # exec query
  d.project <- RODBC::sqlQuery(channel, q, stringsAsFactors=FALSE)
  
  # test is selected set is empty
  if (nrow(d.project) == 0) message("your selected set is missing the project table, please load it and try again")
  
  # uncode metadata domains
  d.project <- uncode(d.project)
  
  
  # close connection
  RODBC::odbcClose(channel)
  
  
  # done
  return(d.project)
  }