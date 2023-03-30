# TFPtoCO2:  Land Use Greenhouse Gas Emissions from Changes in Agricultural Total Factor Productivity
 
R package used for the results in Lobell and Villoria (2023) "Accounting for land use spillovers can greatly reduce the benefits of some climate-smart agricultural policies." 

## Installation
Install the R package from GitHub:
```r
devtools::install_github("nvilloria/TFPtoCO2",build_vignettes = TRUE)
```

## Data
All the data used in the publication above is distributed with this package. The data is documented in the help pages:
```r
?elasticities
?emission_data.ave
```

## Usage
Run the following command for a quick guide to to obtaining domestic and foreign land use emissions from changes in TFP in a given country:
```r
vignette("brief_tutorial")
```

Please direct questions about this R package to [Nelson Villoria](mailto:nvilloria@ksu.edu).
