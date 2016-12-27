# Autoinst
[![Build Status](https://travis-ci.org/jimhester/autoinst.svg?branch=master)](https://travis-ci.org/jimhester/autoinst)

Automatically install CRAN or GitHub packages when they are missing.

Simply add the following to your `.Rprofile` and packages will be automatically installed if they are missing.

```r
options(error = autoinst::autoinst)
```

Then missing packages will be automatically installed, so you can then simply re-run the call.

```r
options(error = autoinst::autoinst)
remove.packages("ggplot2");unloadNamespace("ggplot2")
print(ggplot2::qplot(mtcars$mpg, mtcars$wt))
```
