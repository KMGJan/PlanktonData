
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PlanktonData

<!-- badges: start -->
<!-- badges: end -->

The goal of PlanktonData is to gather a suit of data for meaningful data
manipulation.

All the raw data come from
[SHARKweb](https://sharkweb.smhi.se/hamta-data/)

## Installation

You can install the development version of PlanktonData from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("KMGJan/PlanktonData")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(PlanktonData)
## data(zooplankton)
```

This package includes 2 datasets for now.

- A dataset containing monthly average of zooplankton biomass between
  2007 and 2021

``` r
head(zooplankton)
#>   Month_abb Year Station       Coordinates    Group        Taxa   Biomass
#> 1       Jan 2009    BY15 20.05000/57.33333 Copepoda     Acartia  6.650319
#> 2       Jan 2009    BY31 18.23333/58.58812 Copepoda     Acartia  1.816994
#> 3       Jan 2009     BY5 15.98333/55.25000 Copepoda     Acartia  5.562097
#> 4       Jan 2009    BY15 20.05000/57.33333 Copepoda Centropages  5.738561
#> 5       Jan 2009    BY31 18.23333/58.58812 Copepoda Centropages  1.228759
#> 6       Jan 2009     BY5 15.98333/55.25000 Copepoda Centropages 14.405224
```

- A dataset containing monthly average of phytoplankton biomass between
  2007 and 2021

``` r
head(phytoplankton)
#>   Month_abb Year Station       Coordinates            Taxa   Biomass
#> 1       Jan 2007    BY15 20.05000/57.33333   Cyanobacteria 1.4170670
#> 2       Jan 2007    BY15 20.05000/57.33333         Diatoms 1.7625112
#> 3       Jan 2007    BY31 18.23333/58.58812         Diatoms 0.1557741
#> 4       Jan 2007     BY5 15.98333/55.25000         Diatoms 1.6393078
#> 5       Jan 2007    BY15 20.05000/57.33333 Dinoflagellates 0.6395350
#> 6       Jan 2007    BY31 18.23333/58.58812 Dinoflagellates 0.0588896
```
