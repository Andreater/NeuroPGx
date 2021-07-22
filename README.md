<p align="center">
  <img src="https://github.com/Andreater/FSL-PHARM/blob/main/docs/header.png" width="800" />
</p>

---

**NeuroPGx** is a software for the identification of diplotypes compatible with genotypes at selected SNPs involved in neuropsychiatric drug metabolisms. It helps in pharmacogenomics evaluation of samples, providing information about: (I) the genotypes at evaluated SNPs, (II) the main diplotypes at CYP genes and corresponding metabolization phenotypes, (III) the list of neuropsychiatric drugs with recommended dosage adjustment, (IV) the list of
possible (rare) diyplotypes and corresponding metabolization phenotypes.

NeuroPGx was developed using [R](https://www.r-project.org/) and [Shiny](https://shiny.rstudio.com/), see [papers section](#papers) for details and citations. Developed by the <a href="https://www.hsantalucia.it/en/molecular-genetics-laboratory-uildm" target="_blank">Genomic Medicine Laboratory</a> at <a href="https://www.hsantalucia.it/en" target="_blank">I.R.C.C.S. Santa Lucia Foundation</a>. You can reach us at **a.termine@hsantalucia.it**.

<p align="center">
  <img src="https://github.com/Andreater/FSL-PHARM/blob/main/www/Workflow image.svg" width="300" />
</p>

## Diplotype assignation
The automatic identification of diplotypes based on genotypes at selected SNPs is based on CYP genes following [CPIC](https://cpicpgx.org/) allele definition. All possible diplotypes are evaluated for their enzymatic phenotype based on [PharmVar data](https://www.pharmvar.org/) and the frequency in the [reference population](https://cpicpgx.org/).

## Key features
- Explore: Quickly and easily summarize, visualize, and analyze your data
- Cross-platform: It runs in a browser on every operating system
- Reproducible: Recreate results and share work with others
- Programming: Integrate NeuroPGx's analysis functions with your own R-code

## How to use 
NeuroPGx is an open-source platform-independent browser-based interface for pharmacogenomics in R. The application is based on the Shiny package and can be run locally or on a server. If you want to run NeuroPGx locally you should install the latest version of [R](https://www.r-project.org/) and [Rstudio](https://www.rstudio.com/), download the entire repository and then run <i>app.R</i>. Please use the [issue tracker](https://github.com/Andreater/NeuroPGx/issues) on GitHub to suggest enhancements or report problems.

## License

NeuroPGx is licensed under the <a href="https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0)" target="\_blank">AGPLv3 license</a>. As a summary, the AGPLv3 license requires attribution, including copyright and license information in copies of the software, stating changes if the code is modified, and disclosure of all source code. Details are in the LICENSE file. See our [papers](#citations) for details and citations.

## Papers

**We're working on it**
