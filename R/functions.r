#' Calculate changes in domestic and foreign cropland and emissions
#' for a given percentage change in domestic agricultural TFP.
#'
#' This function can be used with either the point-estimates or the
#' bootstrapped elasticities. The point estimates are documented in
#' \link[TFPtoCO2]{elasticities}. The bootstrapped elasticities
#' (10,000 replicates) are calculated by the function
#' \link[TFPtoCO2]{bootstrap.elasticities}. The elasticities are
#' combined with data on agricultural land and emission factors,
#' documented in \link[TFPtoCO2]{emission_data.ave}.
#'
#' @param ctry Country experiencing a change in TFP.
#' @param tfp.shock % change in agricultural TFP.
#' @param boot Set boot = TRUE for using bootstrapped elasticities,
#'     otherwise the point estimates are used.
#' @param which.boot The dafault uses an optimized function for
#'     estimating the bootstrap replicates of changes in land use and
#'     emissions. If the default is changed, a slower version of
#'     'bootstrap.elasticities()' is used which is not recommended.
#' @return A dataframe with the domestic and foreign change in crop
#'     area (in % and in ha) as well as emissions (in gigatons of CO2
#'     equivalent) from changes in cropland in countries indexed by k
#'     driven by a given percentage change in agricultural TFP in
#'     country i. If boot = "yes", a field 'boot' is included for
#'     identifying the bootstrap replicates.
#' @import dplyr
#' @export

get.responses <- function(ctry, tfp.shock = 1,
                          boot=NULL, which.boot = "new"){
    ## Load data with elasticities:
    if( isTRUE(boot) ) {
        if( which.boot == "new" ){
            elasticities <- bootstrap.elasticities(ctry)
        }else{
            elasticities <- bootstrap.elasticities.old(ctry)
            }
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


#' (OLD) Calculate 10,000 replicates of the entire set of bilateral elasticities
#'
#' This function is not used because it is very slow, but I am keeping
#' it for future reference and, if necessary, ensuring that the
#' function 'bootstrap.elasticities()' is working well.
#'
#' This function is necessary because the dataframe storing the 10,000
#' elasticities is too large (~700 MB) to be stored in GitHUB (max 100
#' MB). The function calculates the bilateral elasticities for the
#' country passed by the function \link[TFPtoCO2]{get.responses}. It
#' uses the bootstrap regression parameters from wild cluster
#' bootstrap using the function 'clusterSEs::cluster.wild.plm' (see
#' ./programs/AJAE_replication//do.rev2.R). The bootstrapped
#' parameters and the competition indices needed by the function are
#' in the ./data folder.
#'
#' @param ctry Country experiencing a change in TFP.
#' @return A dataframe with 10,000 replicates of the 86^2 = 7,396
#'     domestic and bilateral elasticities. There are four columns: i
#'     (origin of TFP change), k (trading partner or domestic market
#'     when i = k), the elasticity e.ik---all with identical
#'     descriptions to those in
#'     \link[TFPtoCO2]{emission_data.ave}---and 'boot', that
#'     indexes the bootstrap replicates.
#' @importFrom data.table rbindlist
bootstrap.elasticities.old <- function(ctry){

    ## Load bootstrapped parameters:
    data( list = "boot.wild.cluster", envir=environment())
    boots <- boot.wild.cluster$replicates

    ## Load competition indices:
    data( list = "Omega_tik.2001.10", envir=environment())

    Omega_tik.2001.10 <- Omega_tik.2001.10[Omega_tik.2001.10$i == ctry,]

    ## Country specific competition indices:
    Omega_i.2001.10 <- Omega_tik.2001.10 %>%
        group_by( i ) %>%
        summarise( A = sum( omega_tik, na.rm = TRUE ))

    boot.own <- lapply( 1:nrow(boots), function(.i){
        ##.i <- 1
        Omega_i.2001.10$e.ik <- boots[.i,"decadal.z"] -
            boots[.i,"pc.Z_it"]*Omega_i.2001.10$A
        Omega_i.2001.10$k <- Omega_i.2001.10$i
        Omega_i.2001.10$boot <- .i
        Omega_i.2001.10[,  c("i", "k", "e.ik", "boot")]
    })

    boot.bilateral <- lapply( 1:nrow(boots), function(.i){
        Omega_tik.2001.10$e.ik <- Omega_tik.2001.10$omega_tki*boots[.i,"pc.Z_it"]
        Omega_tik.2001.10$boot <- .i
        Omega_tik.2001.10[,  c("i", "k", "e.ik", "boot")]
    })

    boot.own <- rbindlist(boot.own)
    boot.bilateral <- rbindlist(boot.bilateral)
    boot.elasticities <- rbindlist(l=list(boot.own , boot.bilateral) )
    return(boot.elasticities)
    }


#' Calculate 10,000 replicates of the entire set of bilateral elasticities
#'
#' This function is necessary because the dataframe storing the 10,000
#' elasticities is too large (~700 MB) to be stored in GitHUB (max 100
#' MB). The function calculates the bilateral elasticities for the
#' country passed by the function \link[TFPtoCO2]{get.responses}. It
#' uses the bootstrap regression parameters from wild cluster
#' bootstrap using the function 'clusterSEs::cluster.wild.plm' (see
#' ./programs/AJAE_replication//do.rev2.R). The bootstrapped
#' parameters and the competition indices needed by the function are
#' in the ./data folder.
#'
#' @param ctry Country experiencing a change in TFP.
#' @return A dataframe with 10,000 replicates of the 86^2 = 7,396
#'     domestic and bilateral elasticities. There are four columns: i
#'     (origin of TFP change), k (trading partner or domestic market
#'     when i = k), the elasticity e.ik---all with identical
#'     descriptions to those in
#'     \link[TFPtoCO2]{emission_data.ave}---and 'boot', that
#'     indexes the bootstrap replicates.
#' @importFrom data.table rbindlist
#' @export
bootstrap.elasticities <- function(ctry){

    ## Load bootstrapped parameters:
    data( list = "boot.wild.cluster", envir=environment())
    boots <- boot.wild.cluster$replicates

    ## Load competition indices:
    data( list = "Omega_tik.2001.10", envir=environment())

    Omega_tik.2001.10 <- Omega_tik.2001.10[Omega_tik.2001.10$i == ctry,]

    ## Country specific competition index:
    Omega_i.2001.10 <-  sum( Omega_tik.2001.10$omega_tik, na.rm = TRUE )

    e.ii <- boots[,"decadal.z"] - boots[,"pc.Z_it"]*Omega_i.2001.10

    boot.own <- data.frame(i = ctry, k = ctry, e.ik = e.ii, boot=1:nrow(boots))

    m <- data.matrix(Omega_tik.2001.10$omega_tki)
    n <- data.matrix(boots[,"pc.Z_it"])

    boot.bilateral <- data.frame(
        i = ctry,
        k = unique(Omega_tik.2001.10$k),
        e.ik = c(m%*%t(n)),
        boot =sort(
            rep(
                c(1:dim(n)[1]),
                dim(m)[1]))
    )
    boot.elasticities <- rbindlist(l=list(boot.own , boot.bilateral) )
    return(boot.elasticities)
    }
