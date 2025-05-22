# beprepared

A frozen version of the [`viral-predped` repository](https://github.com/ndpvh/viral-predped). It provides a simulation function that combines the Minds for Mobile Agents pedestrian model (through the package `predped`) with a Quantifying Viruses in Environments viral disease spread model (through the package `QVEmod`).

## Installation

To install the package, you can use the `remotes` package:

```{r, eval = FALSE}
remotes::install_github("ndpvh/beprepared")
```

To use the package, use `library` 

```{r, eval = FALSE}
library(beprepared)
```

## Functionality

This package allows users to simulate realistic viral disease spread patterns in realistic situations such as the supermarket, a bar, or a train station. For a detailed explanation on how to use the package, we refer the reader to the [Documentation](https://github.com/ndpvh/beprepared-viral-predped/reference/index.html). In the documentation, one can find the [background of the two models](https://github.com/ndpvh/beprepared-viral-predped/articles/background.html) that make up the package and [a detailed example](https://github.com/ndpvh/beprepared-viral-predped/articles/example.html). Additionally, one can find a detailed step-by-step guide on [how to create environments](https://github.com/ndpvh/beprepared-viral-predped/articles/environments.html) and [how to run simulations](https://github.com/ndpvh/beprepared-viral-predped/articles/simulations.html).

## Getting help

If you encounter a bug or need help getting a function to run, please file an issue with a minimal reproducible example on [Github](https://github.com/ndpvh/beprepared-viral-predped/-/issues).

## License

This project is distributed under a GNU GPL-3 license. For details, please see the [License](https://github.com/ndpvh/beprepared-viral-predped/-/blob/main/LICENSE.md)
