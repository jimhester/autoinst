# Autoinst
[![Travis-CI Build Status](https://travis-ci.org/.svg?branch=master)](https://travis-ci.org/)

Automatically install CRAN packages when they are missing.

Simply add the following to your `.Rprofile` and CRAN packages will be automatically installed if they are missing.

```r
options(error = autoinst::autoinst)
```

Then missing packages will be automatically installed and the failed call re-run.

```r
options(error = autoinst::autoinst)
remove.packages("ggplot2");unloadNamespace("ggplot2")
print(ggplot2::qplot(mtcars$mpg, mtcars$wt))
```
