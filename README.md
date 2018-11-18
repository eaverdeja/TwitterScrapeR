## TwitterScrapeR

Academic project for exercising concepts and techniques related to data mining using R as a tool

---

### Prerequisite

You should have R installed (version 3.5.1^) or you could
use [docker](https://github.com/rocker-org/rocker)

### How to use

1. Clone this repo with `$ git clone git@github.com:eaverdeja/TwitterScrapeR.git`
2. Sign up for a Twitter developer account and get your credentials - tokens included. That's an easy Google search so I won't cover it here
3. Copy or rename the `.env.example` file to `.env` and fill in the values with your twitter credentials
4. `$ Rscript index.R`

    The script should install necessary dependencies and 
    generate the **output.txt** and **Rplots.pdf** files. The example files in the repository where generated at 21:47, 17th of November, 2018. The remaining parameters for the query are specified at `index.R`

