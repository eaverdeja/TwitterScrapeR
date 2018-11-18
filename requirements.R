list.of.packages <-
  c('rtweet',
    'tm',
    'SnowballC',
    'wordcloud',
    'cluster',
    'fpc',
    'slam',
    'cli')

new.packages <-
  list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]

if (length(new.packages))
  install.packages(new.packages)

devtools::install_github("gaborcsardi/dotenv")
