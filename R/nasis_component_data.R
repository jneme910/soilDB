##
## 13 March, 2012
## D.E. Beaudette
## 
## prototype functions for extracting component data from local NASIS
##

get_component_data_from_NASIS_db <- function() {
	q <- "SELECT dmudesc, coiid, compname, comppct_r, ck.ChoiceName as compkind, majcompflag, localphase, slope_l, slope_r, slope_h, tfact, wei, weg, dc.ChoiceName as drainage_class, elev_l, elev_r, elev_h, aspectccwise, aspectrep, aspectcwise, map_l, map_r, map_h, reannualprecip_l, reannualprecip_r, reannualprecip_h, ffd_l, ffd_r, ffd_h, nirrcapcl, nirrcapscl, irrcapcl, irrcapscl, fa.ChoiceName as frost_action, hydgrp, crc.ChoiceName as corcon, crs.ChoiceName as corsteel, taxclname, txo.ChoiceName as taxorder, txs.ChoiceName as taxsuborder, txgg.ChoiceName as  taxgrtgroup, txsg.ChoiceName as taxsubgrp, txps.ChoiceName as taxpartsize, txpsm.ChoiceName as taxpartsizemod, txact.ChoiceName as taxceactcl, txr.ChoiceName as taxreaction, txtc.ChoiceName as taxtempcl, txmc.ChoiceName as taxmoistscl, txtr.ChoiceName as taxtempregime, txed.ChoiceName as soiltaxedition
FROM (((((((((((((((((datamapunit 
	INNER JOIN component ON datamapunit.dmuiid = component.dmuiidref
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 148) AS dc ON drainagecl = dc.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 120) AS fa ON frostact = fa.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 103) AS crc ON corcon = crc.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 104) AS crs ON corsteel = crs.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 102) AS ck ON compkind = ck.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 132) AS txo ON taxorder = txo.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 134) AS txs ON taxsuborder = txs.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 130) AS txgg ON taxgrtgroup = txgg.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 187) AS txsg ON taxsubgrp = txsg.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 127) AS txps ON taxpartsize = txps.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 521) AS txpsm ON taxpartsizemod = txpsm.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 520) AS txact ON taxceactcl = txact.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 128) AS txr ON taxreaction = txr.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 185) AS txtc ON taxtempcl = txtc.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 131) AS txmc ON taxmoistscl = txmc.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 188) AS txtr ON taxtempregime = txtr.ChoiceValue)
LEFT OUTER JOIN (SELECT * FROM dbo.MetadataDomainDetail WHERE dbo.MetadataDomainDetail.DomainID = 2030) AS txed ON soiltaxedition = txed.ChoiceValue)
ORDER BY dmudesc;"
	
	# setup connection to our pedon database
	channel <- odbcConnect('nasis_local', uid='NasisSqlRO', pwd='Re@d0n1y')
	
	# exec query
	d <- sqlQuery(channel, q, stringsAsFactors=FALSE)
	
	# close connection
	odbcClose(channel)
	
	# done
	return(d)
}


get_component_horizon_data_from_NASIS_db <- function() {
	q <- "SELECT chiid, coiidref as coiid, hzname, hzdept_r, hzdepb_r, fragvoltot_r, sandtotal_r, silttotal_r, claytotal_r, om_r, dbovendry_r, ksat_r, awc_r, lep_r, sar_r, ec_r, cec7_r, sumbases_r, ph1to1h2o_r
	FROM chorizon ORDER BY coiidref, hzdept_r ASC;"
	
	# setup connection to our pedon database
	channel <- odbcConnect('nasis_local', uid='NasisSqlRO', pwd='Re@d0n1y')
	
	# exec query
	d <- sqlQuery(channel, q, stringsAsFactors=FALSE)
	
	# close connection
	odbcClose(channel)
	
	# done
	return(d)
}


fetchNASIS_component_data <- function() {
	
	# get component table
	f.comp <- get_component_data_from_NASIS_db()
	
	# get chorizon table
	f.chorizon <- get_component_horizon_data_from_NASIS_db()
	
	# join
	f <- join(f.comp, f.chorizon, by='coiid')
	
	cat('finding horizonation errors ...\n')
	f.test <- ddply(f, .(coiid), test_hz_logic, topcol='hzdept_r', bottomcol='hzdepb_r', strict=TRUE)
	
	# which are the good (valid) ones?
	good.ids <- as.character(f.test$coiid[which(f.test$hz_logic_pass)])
	bad.ids <- as.character(f.test$coiid[which(f.test$hz_logic_pass == FALSE)])
	
	# mention bad pedons
	if(length(bad.ids) > 0)
		cat(paste('horizon errors in:', paste(bad.ids, collapse=','), '\n'))
	
	# keep the good ones
	f <- subset(f, coiid %in% good.ids)
	
	# init SPC from chorizon data
	depths(f) <- coiid ~ hzdept_r + hzdepb_r
	
	# move site data
	site(f) <- ~ dmudesc + comppct_r + compname + localphase + compkind + majcompflag
	
	# done, return SPC
	return(f)
	
}

