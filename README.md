<p align="center">
  <img src="https://github.com/Andreater/FSL-PHARM/blob/main/docs/header.png" width="800" />
</p>

---
<p align="justify">
**NeuroPGx** is a software for the identification of diplotypes compatible with genotypes at selected SNPs involved in neuropsychiatric drug metabolisms. It helps in pharmacogenomics evaluation of samples, providing information about: (I) the genotypes at evaluated SNPs, (II) the main diplotypes at CYP genes and corresponding metabolization phenotypes, (III) the list of neuropsychiatric drugs with recommended dosage adjustment, (IV) the list of
possible (rare) diyplotypes and corresponding metabolization phenotypes.

NeuroPGx is an open-source platform-independent browser-based interface for pharmacogenomics in R. The application is based on the Shiny package and can be run locally or on a server. NeuroPGx was developed using [R](https://www.r-project.org/) and [Shiny](https://shiny.rstudio.com/), see [papers section](#papers) for details and citations. Developed by the <a href="https://www.hsantalucia.it/en/molecular-genetics-laboratory-uildm" target="_blank">Genomic Medicine Laboratory</a> at <a href="https://www.hsantalucia.it/en" target="_blank">I.R.C.C.S. Santa Lucia Foundation</a>. You can reach us at **a.termine@hsantalucia.it**. Please use the [issue tracker](https://github.com/Andreater/NeuroPGx/issues) on GitHub to suggest enhancements or report problems.
</p>
<p align="center">
  <img src="https://github.com/Andreater/FSL-PHARM/blob/main/www/Workflow image.svg" width="300" />
</p>

## Diplotype assignation
<p align="justify">
 The automatic identification of diplotypes based on genotypes at selected SNPs is based on CYP genes following [CPIC](https://cpicpgx.org/) allele definition. All possible diplotypes are evaluated for their enzymatic phenotype based on [PharmVar data](https://www.pharmvar.org/) and the frequency in the [reference population](https://cpicpgx.org/).</p>

## Key features
- Explore: Quickly and easily summarize, visualize, and analyze your data
- Cross-platform: It runs in a browser on every operating system
- Reproducible: Recreate results and share work with others
- Programming: Integrate NeuroPGx's analysis functions with your own R-code

## How to install and use

- To set the environment for NeuroPGx local use, R and RStudio must be installed.
- 1. Download [R](https://cran.r-project.org/) for your operating system (Windows, Linux or macOS) and install using the default settings.
- 2. Download [RStudio](https://www.rstudio.com/products/rstudio/download/) Free Desktop version and install using the default settings.

- To use the NeuroPGx software, download this repository from [here](https://github.com/Andreater/NeuroPGx/archive/refs/heads/main.zip) or by clicking the green `Code` button and selecting `Download ZIP`.
- Unpack the downloaded ZIP file to your preferred path.
- Open the `app.R` file using RStudio, then click on the green `run app` button at the top-right corner of the central panel window, as shown in the image below.

<p align="center">
  <img src="https://github.com/Andreater/FSL-PHARM/blob/main/docs/Run app example.png" width="800" />
</p>

### Input file preparation

<p align="justify">
Your input file can be simply prepared with an Excel spreadsheet. It should have 4 columns: Sample, Gene, rsID, Genotype. Put your samples' ID in the Sample column and fill the Gene and rsID columns with Gene Symbols and dbSNP ids. Please note that you can find the complete list of SNPs in the [paper](#Papers). Genotype column should be filled with genotype information for each sample. A `/` should be used as separator. Deletions in a SNP can be coded as `-/-`  or ` A/-` while more complex configurations, such as `CTT/CTT` can be easily reported and are well managed by the NeuroPGx software. NeuroPGx accepts `.tsv`, `.csv` and `.xlsx` files. If you need a more detailed example, we **strongly suggest** you to check the `.xlsx` example files provided in the [samples](https://github.com/Andreater/NeuroPGx/tree/main/data/samples) folder to simplify your data preparation. Your input file should have the following structure: </p>

Sample  |Gene   |rsID      |Genotype|
--------|------ |----------|--------|
Sample1 |CYP2B6 |rs28399499|T/T     |
Sample1 |CYP2C19|rs12248560|C/C     |
Sample1 |CYP2C9 |rs1057910 |A/A     |
Sample1 |CYP2D6 |rs1065852 |G/G     |
Sample1 |CYP3A5 |rs10264272|C/C     |
Sample2 |CYP2B6 |rs28399499|T/T     |
Sample2 |CYP2C19|rs12248560|C/C     |
Sample2 |CYP2C9 |rs1057910 |A/A     |
Sample2 |CYP2D6 |rs1065852 |G/G     |
Sample2 |CYP3A5 |rs10264272|C/T     |

Please note that we used only one SNP for each Gene to simplify the provided example. You can find a complete set of examples in the [samples](https://github.com/Andreater/NeuroPGx/tree/main/data/samples) folder.

## License
<p align="justify">
NeuroPGx is licensed under the <a href="https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0)" target="\_blank">AGPLv3 license</a>. As a summary, the AGPLv3 license requires attribution, including copyright and license information in copies of the software, stating changes if the code is modified, and disclosure of all source code. Details are in the LICENSE file. See our [papers](#Papers) section for details and citations.</p>

## Papers

**We're working on it**
