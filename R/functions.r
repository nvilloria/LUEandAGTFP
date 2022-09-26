#' Calculate percentage changes in domestic and foreign cropland for a
#' given percentage change in agricultural TFP.
#'
#' This function can be used to get percentage changes in domestic and
#' foreign cropland for bootstrapped elasticities.
#'
#' @param ctry Country experiencing a change in TFP.
#' @param tfp.shock % change in agricultural TFP.
#' @param elasticities Dataframe with bilateral elasticities.
#' @return A dataframe with the percentage in domestic and foreign
#'     cropland for a given percentage change in agricultural TFP.
#' @export

get.perc.changes.in.cropland <- function(ctry, tfp.shock, elasticities){
    e <- elasticities[elasticities$i == ctry,]
    ## By the definition of the elasticity, ## % change in cropland_k
    ## = % change in TFP_i X elasticity_ik
    e$perc.change.crop.area <- with( e, tfp.shock*e.ik )
    return(e)
}

#' Calculate changes in domestic and foreign cropland and emissions
#' for a given percentage change in agricultural TFP.
#'
#' @param perc.changes.in.cropland Dataframe obtained from
#'     \link[TFPANDCO2]{get.perc.changes.in.cropland}
#' @param physicaldata Dataframe with cropland ha and emissions.
#' @return A dataframe with the change in domestic and foreign
#'     cropland and emissions for a given percentage change in
#'     agricultural TFP.
#' @export

 get.changes.in.cropland.and.emissions <- function(perc.changes.in.cropland, physicaldata){
    e <- left_join( perc.changes.in.cropland, physicaldata, by = c( "k" = "iso") )
    ## Translate the perc. change to ha using the average cropland:
    e$change.crops_ha <- with( e, perc.change.crop.area*crops_ha/100)
    ## convert area changes to emissions
    e$emissions  <- with( e, (change.crops_ha)*EF )
    return(e)
    }

#' Wrap the two functions above for a more concise use in scripts:
#'
#' @export

get.resp <- function(ctry, tfp.shock, elasticities,physicaldata){
    a <- get.perc.changes.in.cropland( ctry, tfp.shock, elasticities)
    b <-  get.changes.in.cropland.and.emissions(perc.changes.in.cropland = a,
                                                physicaldata)
}

