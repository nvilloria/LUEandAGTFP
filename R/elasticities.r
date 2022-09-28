#' Elasticity of cropland to changes in agricultural Total Factor
#' Productivity (TFP)
#'
#' A dataset containing the domestic and bilateral elasticities of
#' cropland to changes in agricultural TFP for 86 countries.  These
#' elasticities are from Villoria (2019).  The elasticities were
#' estimated using average rates of change in cropland area and TFP
#' (Fuglie, 2017) for the two periods of 1991-2000 and 2001-2010,
#' along with data on trade flows and costs, to identify country-level
#' responses of cropland area to TFP in each country. Estimates were
#' made using a sample of 70 countries with sufficient data,
#' comprising 74% of global cropland and 91% of global production and
#' exports.  Here we utilize the OLS values to provide conservative
#' estimates of the area responses to TFP (see Villoria 2019).  We
#' extend the country coverage of the elasticities in Villoria (2019)
#' by bringing 16 additional countries with enough data on production
#' and trade that can be combined with original parameter
#' estimates. The final 86 countries comprise 87% of global cropland,
#' 96% of global production, 93% of global imports, and 97% of global
#' exports. We include the elasticities for 2001-2010 only. The
#' variables are as follows:
#'
#' @docType data
#'
#' @usage data(elasticities)
#'
#' @format A data frame with 7,396 rows and 3 variables:
#' \describe{
#'   \item{i}{Country of origin of a change in agricultural TFP}
#'   \item{k}{Country experiencing a change in cropland because of a change in agricultural TFP}
#'   \item{e.ik}{% change in cropland_k / % change in TFP_i. For
#' domestic elasticities, i = k.}  }
#'
#' @references Villoria, Nelson B. 2019. "Technology Spillovers and
#'     Land Use Change: Empirical Evidence from Global Agriculture."
#'     American Journal of Agricultural Economics 101 (3):
#'     870–93. https://doi.org/10.1093/ajae/aay088.
#' (\href{https://onlinelibrary.wiley.com/doi/full/10.1093/ajae/aay088
#' }{link})
#'
#' @references Fuglie, Keith O. 2017. "USDA ERS - International
#'     Agricultural Productivity."
#'     2017. \href{https://www.ers.usda.gov/data-products/international-agricultural-productivity}{Online
#'     database}. Accessed: 02-28-2017.
#'
#' @examples
#' data(elasticities)
#' head(elasticities)
#'
#' ## Percentage change in Mexico's cropland when TFP in the US grows by 1% (bilateral elasticity):
#'
#' with( elasticities, elasticities[i == "usa" & k == "mex",])
#'
#' ## Percentage change in US cropland when TFP in Mexico grows by 1% (bilateral elasticity)
#'
#' with( elasticities, elasticities[i == "mex" & k == "usa",])
#'
#' ## Percentage change in Argentina's cropland following a domestic increase of TFP of 1% (domestic elasticity):
#'
#' with( elasticities, elasticities[i == "arg" & k == "arg",])
#'
#' ## Argentina is an example of Jevons' Paradox. India is an example of the so called Borlaug's hypothesys:
#'
#' with( elasticities, elasticities[i == "ind" & k == "ind",])
"elasticities"
