#' Calculate changes in domestic and foreign cropland and emissions
#' for a given percentage change in domestic agricultural TFP.
#'
#' This function Can be used with either the point-estimates or the
#' bootstrapped elasticities. The point estimates are documented in
#' \link[LUEandAGTFP]{elasticities}. The bootstrapped elasticities
#' (10,000 replicates) are calculated by the function
#' \link[LUEandAGTFP]{bootstrap.elasticities}. The elasticities are
#' combined with data on agricultural land and emission factors,
#' documented in \link[LUEandAGTFP]{emission_data.ave}.
#'
#' @param ctry Country experiencing a change in TFP.
#' @param tfp.shock % change in agricultural TFP.
#' @param boot Set boot = TRUE for using bootstrapped elasticities,
#'     otherwise the point estimates are used.
#' @return A dataframe with the domestic and foreign change in crop
#'     area (in % and in ha) as well as emissions (in gigatons of CO2
#'     equivalent) from changes in cropland in countries indexed by k
#'     driven by a given percentage change in agricultural TFP in
#'     country i. If boot = "yes", a field 'boot' is included for
#'     identifying the bootstrap replicates.
#' @import dplyr
#' @export

get.responses <- function(ctry, tfp.shock = 1,
                          boot=NULL){
    ## Load data with elasticities:
    if( isTRUE(boot) ) {
        elasticities <- bootstrap.elasticities()
    }else{
        data( list = "elasticities", envir=environment())
        ## assign("elasticities",get(elasticities.df))
    }

    e <- elasticities[elasticities$i == ctry,]
    ## By the definition of the elasticity, ## % change in cropland_k
    ## = % change in TFP_i X elasticity_ik
    e$perc.change.crop.area <- with( e, tfp.shock*e.ik )
    ## Load emission factors
    data( list = "emission_data.ave", envir=environment())
    physicaldata <- emission_data.ave
    e <- left_join( e, physicaldata, by = c( "k" = "iso") )
    ## Translate the perc. change to ha using the average cropland:
    e$change.crops_ha <- with( e, perc.change.crop.area*crops_ha/100)
    ## convert area changes to emissions
    e$emissions_GtCO2  <- with( e, (change.crops_ha)*EF )
    if( isTRUE(boot) ){
        e <- e[,c("i","k","boot",
                  "perc.change.crop.area","change.crops_ha",
                  "emissions_GtCO2")]
    }else{
                e <- e[,c("i","k","perc.change.crop.area","change.crops_ha",
                  "emissions_GtCO2")]

    }
    return(e)
    }


#' Calculate 10,000 replicates of the entire set of bilateral elasticities
#'
#' This function is necessary because the dataframe storing the 10,000
#' elasticities is too large (~700 MB) to be stored in GitHUB (max 100
#' MB). The function takes no argument. It uses the bootstrap
#' regression parameters from wild cluster bootstrap using the
#' function 'clusterSEs::cluster.wild.plm' (see
#' ./programs/AJAE_replication//do.rev2.R). The bootstrapped parameters
#' and the competition indices needed by the function are in the
#' ./data folder.
#'
#' @return A dataframe with 10,000 replicates of the 86^2 = 7,396
#'     domestic and bilateral elasticities. There are four columns: i
#'     (origin of TFP change), k (trading partner or domestic market
#'     when i = k), the elasticity e.ik---all with identical
#'     descriptions to those in
#'     \link[LUEandAGTFP]{emission_data.ave}---and 'boot', that
#'     indexes the bootstrap replicates.
#' @importFrom data.table rbindlist
#' @export
bootstrap.elasticities <- function(){

    ## Load bootstrapped parameters:
    data( list = "boot.wild.cluster", envir=environment())
    boots <- boot.wild.cluster$replicates

    ## Load competition indices:
    data( list = "Omega_tik.2001.10", envir=environment())

    ## Country specific competition indices:
    Omega_i.2001.10 <- Omega_tik.2001.10 %>%
        group_by( i, t) %>%
        summarise( A = sum( omega_tik, na.rm = TRUE ))

    boot.own <- lapply( 1:nrow(boots), function(.i){
        ##.i <- 1
        Omega_i.2001.10$e.ik <- boots[.i,"decadal.z"] -
            boots[.i,"pc.Z_it"]*Omega_i.2001.10$A
        Omega_i.2001.10$k <- Omega_i.2001.10$i
        Omega_i.2001.10$boot <- .i
        Omega_i.2001.10[,  c("t", "i", "k", "e.ik", "boot")]
    })

    boot.bilateral <- lapply( 1:nrow(boots), function(.i){
        Omega_tik.2001.10$e.ik <- Omega_tik.2001.10$omega_tki*boots[.i,"pc.Z_it"]
        Omega_tik.2001.10$boot <- .i
        Omega_tik.2001.10[,  c("t", "i", "k", "e.ik", "boot")]
    })

    boot.own <- rbindlist(boot.own)
    boot.bilateral <- rbindlist(boot.bilateral)
    boot.elasticities <- rbindlist(l=list(boot.own , boot.bilateral) )
    return(boot.elasticities)
    }
