#' Dataset with cropland and land use emission factors
#'
#' Dataset containing the net changes in cropland and land use and
#' emission factors for 1998-2017.
#'
#' @docType data
#'
#' @usage data(emission_data.ave)
#'
#' @format A data frame with 86 rows and 6 variables:
#' \describe{
#'   \item{iso}{country code.}
#'
#'   \item{crops_ha}{sum of area under crops, from Hong et al. (2021) based on FAO (2021).}
#'
#'   \item{Gt_CO2}{committed emissions from land expansion, from Hong et al. (2021).}
#'
#'   \item{delcrops_ha}{net change cropland area (1988-2017), from Hong et al. (2021) based on FAO (2021).}
#'
#'   \item{EF}{a country-level emission factor defined as the ratio of
#'   total committed emissions ('Gt_CO2') for the 20-year period
#'   starting in 1988 and ending in 2017 (the final year in Hong et
#'   al.'s study period) and the total net change in cropland area
#'   over the same period ('delcrops_ha'). Net changes in cropland
#'   over 20 could underestimate gross expansion due to land
#'   abandonment. This would inflate the emission factors by failing
#'   to impute them to areas that were converted to agriculture in
#'   some point but abandoned before 2017. To help alleviating this
#'   concern, for countries where total land abandonment during
#'   2003-2019 was larger than total land expansion (see 'gainratio'
#'   below, we impute a minimum value of 200 t CO2 ha-1, the average
#'   emissions for unit of land for conversion in temperate countries
#'   (West et al. 2020). Furthermore, all EF are constrained to be
#'   between 200 – 800 t CO2 ha-1 to avoid outliers.}
#'
#' \item{gainratio}{the ratio of expansion to abandonment over 2003-2019 from Potapov et al. 2022}.
#' }
#'
#' @references FAO. (2021). Food and Agriculture Organization of the United Nations (FAO), FAO Statistical Databases. Retrieved from http://faostat.fao.org
#' @references Hong, Chaopeng, Jennifer A. Burney, Julia Pongratz, Julia E. M. S. Nabel, Nathaniel D. Mueller, Robert B. Jackson, and Steven J. Davis. 2021. "Global and Regional Drivers of Land-Use Emissions in 1961-2017." Nature 589 (7843): 554-61. https://doi.org/10.1038/s41586-020-03138-y
#' @references Potapov, P., Turubanova, S., Hansen, M. C., Tyukavina, A., Zalles, V., Khan, A., … Cortez, J. (2022). "Global maps of cropland extent and change show accelerated cropland expansion in the twenty-first century". Nature Food, 3(1), 19-28. https://doi.org/10.1038/s43016-021-00429-z
#' @references West, P. C., Gibbs, H. K., Monfreda, C., Wagner, J., Barford, C. C., Carpenter, S. R., & Foley, J. A. (2010). "Trading carbon for food: Global comparison of carbon stocks vs. crop yields on agricultural land". Proceedings of the National Academy of Sciences, 107(46), 19645-19648.
"emission_data.ave"
