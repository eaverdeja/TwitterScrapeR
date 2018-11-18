"
Referências:
https://eight2late.wordpress.com/2015/05/27/a-gentle-introduction-to-text-mining-using-r/
https://rpubs.com/pjmurphy/265713
https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/clusplot.default.html
"
source('./requirements.R')
library(rtweet)
library(ggplot2)
library(httpuv)
library(tm)
library(SnowballC)
library(wordcloud)
library(cluster)
library(fpc)
library(slam)
library(cli)
library(dotenv)

#Abrimos um arquivo para guardar o output do programa
sink('output.txt')
writeLines('\n')
rule(center = "Preparação", line = "~")

#Criamos o token de autenticação com as credencias da API do Twitter
token <- create_token(
  app = "R_Exercises",
  consumer_key = Sys.getenv('CONSUMER_KEY'),
  consumer_secret = Sys.getenv('CONSUMER_SECRET'),
  access_token = Sys.getenv('ACCESS_TOKEN'),
  access_secret = Sys.getenv('ACCESS_SECRET')
)

#Criamos uma lista própria de stopwords, recuperadas de 2 githubs diferentes
stop1 <-
  readLines(
    'https://gist.githubusercontent.com/alopes/5358189/raw/2107d809cca6b83ce3d8e04dbd9463283025284f/stopwords.txt'
  )
stop2 <-
  readLines(
    'https://raw.githubusercontent.com/stopwords-iso/stopwords-pt/master/stopwords-pt.txt'
  )
myStopwords <- append(stop1, stop2)

#Definimos uma constante para o número de tweets a serem recuperados
num_tweets <- 1000

writeLines('\n')
rule(center = "LETRA A", line = "~")
boxx(
  c(
    "Leia do Twitter mensagens que contenham a ",
    "palavra Política a partir da data 27/09/2018 ",
    "e que estejam em um raio de 60Km",
    "da latitude -22° 54' 10'' (-22.90278) e ",
    "longitude -43° 12' 27''(-43.2075).",
    "Deverá ser criado um",
    "dataframe com as mensagens lidas;"
  )
)

#Recuperamos um 'tibble' com os tweets com os parâmetros especificados no enunciado
rt <- search_tweets("política",
                    geocode = "-22.90278,-43.2075,60km",
                    n = num_tweets,
                    #Retiramos os retweets
                    include_rts = FALSE)

#Convertemos o tibble para um dataframe e removemos
#os stopwords dos tweets
tweets.data.frame <- as.data.frame(rt)

writeLines('\n')
rule(center = "LETRA B", line = "~")
boxx(
  c(
    "A partir dos textos lidos no item a: realizar a limpeza removendo ",
    "caracteres como “.-‘´:”, pontuação, números e URLs; converter os ",
    "caracteres de todas as palavras para minúsculo; remover stopwords;",
    "remover espaços;"
  )
)
tweets.data.frame$text <-
  removeWords(tweets.data.frame$text, myStopwords)
#Removemos a palavra utilizada na pesquisa
tweets.data.frame$text <-
  removeWords(tweets.data.frame$text,
              c('política', 'Política', 'politica', 'Politica'))


#Criamos um 'corpus' - uma coleção de documentos (tweets no nosso caso)
tweets <- VCorpus(VectorSource(tweets.data.frame$text))

#Função utilitária para transformação do conteúdo
remove <- content_transformer(function(x, pattern) {
  return (gsub(pattern, "", x))
})

#A seguir utilizamos o tm para transformação do conteúdo
#Retiramos links
writeLines('Retirando links...')
tweets <- tm_map(tweets, remove, 'http[^ ]*')
writeLines('Retirando menções a outros usuários (ex. @ChoqueDeCultura)...')
#Retiramos menções a outros usuários (ex. @ChoqueDeCultura)
writeLines('Retirando menções a outros usuários (ex. @ChoqueDeCultura)...')
tweets <- tm_map(tweets, remove, '@[^ ]*')
writeLines('Retirando caracteres de pontuação...')
#Utilizamos o removePunctuation do tm
tweets <- tm_map(tweets, removePunctuation)
#Removemos quebras de linha
tweets <- tm_map(tweets, remove, '\n')
writeLines('Retirando hashtags...')
#Removemos hashtags, muito comuns no twitter
#Como faltam espaços nas hashtags (ex. #brigadepolitica),
#outras transformações seriam necessárias para a "correção"
#do conteúdo (no nosso caso, a inserção dos espaços corretamente)
#Portanto, removemos a hashtag por completo
writeLines('Retirando hashtags...')
tweets <- tm_map(tweets, remove, '#[^ ]*')
#Removemos demais caracteres indesejados
writeLines('Retirando [“”-:]...')
tweets <- tm_map(tweets, remove, "“")
tweets <- tm_map(tweets, remove, "”")
tweets <- tm_map(tweets, remove, '-')
tweets <- tm_map(tweets, remove, ':')

#Transformamos o conteúdo para caixa baixa
tweets <- tm_map(tweets, content_transformer(tolower))

#Removemos números
tweets <- tm_map(tweets, removeNumbers)

#Aplicamos mais um filtro de stopwords
#tweets <- tm_map(tweets, stopwords('portuguese'))

#Retiramos espaços em branco nas extremidades dos textos
tweets <- tm_map(tweets, stripWhitespace)

writeLines('\n')
rule(center = "LETRA C", line = "~")
boxx("Realizar o stemming dos textos;")
#Realizamos o stemming
tweets <- tm_map(tweets, stemDocument)

#Visualizamos exemplos aleatórios do conteúdo transformado
writeLines('\n')
print("Visualizamos exemplos aleatórios do conteúdo transformado")
random.tweet.indexes <- sample(1:num_tweets, 5)
for(i in random.tweet.indexes) {
  writeLines(paste('Conteúdo do tweet [', i, ']'))
  writeLines(as.character(tweets[[i]]))
}

writeLines('\n')
rule(center = "LETRA D", line = "~")
boxx(
  c(
    "Criar e exibir a DTM. Apresentar os termos mais encontrados ",
    "e as respectivas freqüências;"
  )
)
#Criamos a DTM
dtm <- DocumentTermMatrix(tweets)
writeLines('\n')
rule(left = "DTM dos tweets")
inspect(dtm)

#Convertemos a DTM para uma matriz e somamos nas linhas
#Como resultado, temos a frequência de cada um dos termos,
#contabilizando todos os tweets encontrados
freq <- colSums(as.matrix(dtm))

#Ordenamos as frequência de forma decrescente
ord <- order(freq, decreasing = TRUE)
#Listamos os termos mais frequentes
writeLines('\n')
rule(left = "Termos mais frequentes da DTM")
freq[head(ord)]

#Reduzimos a DTM criando duas restrições:
# - As palavras devem ter entre 4 a 20 caracteres
# - As palavras devem ser encontradas em pelo menos 1%
#   dos tweets e até no máximo em 95% dos tweets
#   (palavras extremamente comuns ou extremamente raras
#   normalmente não são de grande ajuda)
dtmr <- DocumentTermMatrix(tweets,
                           control = list(
                             wordLengths = c(4, 20),
                             bounds = list(global = c(num_tweets * 0.01, num_tweets * 0.95)),
                             weighting = weightTf
                           ))

#Inspecionamos a DTM reduzida, observando a redução
#no número de termos
writeLines('\n')
rule(left = "DTM dos tweets reduzida")
inspect(dtmr)

#Computamos o somatório da frequência dos termos novamente,
#dessa vez com a DTM reduzida
freqr <- colSums(as.matrix(dtmr))

writeLines('\n')
rule(left = "Comparativos entre a DTM e a DTM reduzida")
#Comparação do número de termos
writeLines('\n')
print("Número de termos da DTM")
print(length(freq))
writeLines('\n')
print("Número de termos da DTM reduzida")
print(length(freqr))

#Comparação dos termos mais comuns
writeLines('\n')
print('Termos mais comuns da DTM:')
ord <- order(freq, decreasing = TRUE)
freq[head(ord)]
writeLines('\n')
print('Termos mais comuns da DTM reduzida:')
ord <- order(freqr, decreasing = TRUE)
freqr[head(ord)]

#O tm tem funções prontas para procurar termos frequentes
#OBS: os resultados abaixo estão ordenados alfabeticamente - não por frequência
writeLines('\n')
print('Termos DTM reduzida que aparecem em pelos menos 5% dos documentos (ordenados alfabeticamente)')
findFreqTerms(dtmr, lowfreq = num_tweets * 0.05)
writeLines('\n')
print('Termos DTM reduzida que aparecem em pelos menos 4% dos documentos (ordenados alfabeticamente)')
findFreqTerms(dtmr, lowfreq = num_tweets * 0.04)

#Transformamos a DTM reduzida para aplicar a função colSums()
#Dessa forma, visualizamos a frequência total de cada um dos termos
freqs <- colSums(as.matrix(dtmr))
#Ordenados alfabeticamente
writeLines('\n')
print("Termos da DTM reduzida e suas respectivas frequências (ordenados alfabeticamente)")
freqs
#Ordenados por frequência
writeLines('\n')
print("Termos da DTM reduzida e suas respectivas frequências (orenados por frequência)")
freqs[order(-unlist(freqs))]

writeLines('\n')
rule(center = "LETRA E", line = "~")
boxx(
  c(
    "Apresentar um histograma (termo x freqüência) para os temos que ",
    "apareceram pelo menos 40 vezes;"
  )
)
#Criamos um dataframe para construção do histograma
wf = data.frame(term = names(freqr), occurrences = freqr)

#Definimos a ordenação do eixo X e as labels do eixo Y
aesthetic <- aes(x = reorder(term, -occurrences), occurrences)
#Definimos uma frequência miníma para que a palavra apareça
#no dataframe a partir do número total de tweets pesquisados
#(ex. 4% do total - 1000 tweets -> mínimo de 40 ocorrências)
min_freq <- num_tweets * 0.025
set <- subset(wf, freqr > min_freq)
#Usamos o ggplot para construir o histograma
p <- ggplot(set, aesthetic)
p <- p + geom_bar(stat = 'identity')
#Giramos os labels do eixo X em 45º
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = 1))
p

writeLines('\n')
rule(center = "LETRA F", line = "~")
boxx(c(
  "Apresentar os termos associados com o termo ouro",
  "segundo uma correlação de 60%;"
))
#Listando as correlações de diferentes palavras na DTM reduzida
findAssocs(dtmr, "ministério", 0.1)
findAssocs(dtmr, "médico", 0.6)
findAssocs(dtmr, "lula", 0.2)
findAssocs(dtmr, "bolsonaro", 0.1)
findAssocs(dtmr, "esquerda", 0.05)
findAssocs(dtmr, "ouro", 0.6)

writeLines('\n')
rule(center = "LETRA G", line = "~")
boxx(c(
  "Apresentar um wordcloud com termos cuja ",
  "freqüência seja de pelo menos 20;"
))
#Criando o wordcloud
#OBS:
#Com o uso do set.seed() podemos forçar que o wordcloud tenha sempre
#a mesma disposição de palavras
#set.seed(42)

#Criamos um wordcloud preto e branco
min_wc_freq <- num_tweets * 0.02
wordcloud(names(freqs), freqs, min.freq = min_wc_freq)

writeLines('\n')
rule(center = "LETRA H", line = "~")
boxx("Apresentar um wordcloud com cores;")
#Criamos um wordcloud colorido
wordcloud(names(freqs),
          freqs,
          min.freq = min_wc_freq,
          colors = brewer.pal(6, "Dark2"))

writeLines('\n')
rule(center = "LETRA I", line = "~")
boxx(c(
  "Apresentar o dendogram do cluster hierárquico ",
  "identificando os clusters;"
))
#Dendrogram
#Preparamos o cluster hierárquico utilizando nossa DTM reduzida
#Para não poluir a visualização, mantemos apenas os termos
#com frequência acima do mínimo estabelecido
colTotals <-  col_sums(dtmr)
dtm2 <- dtmr[, which(colTotals > min_freq)]
d <- dist(t(dtm2))
hc <- hclust(d)
#Plotamos o dendrogram
plot(hc, hang = -1)

#Definimos o número de clusters desejados
num_clusters <- 6

#Plotamos o dendrogram novamente
plot(hc, hang = -1)
#Computamos os grupos utilizando a função cutree()
groups <- cutree(hc, k = num_clusters)
# Usamos bordas vermelhas para ilustrar os clusters
rect.hclust(hc, k = num_clusters, border = "red")

writeLines('\n')
rule(center = "LETRA J", line = "~")
boxx("Usando o método k-means apresentar o cluster de termos;")
#K-means
num_grupos <- 6
kfit <- kmeans(d, num_grupos)
clusplot(
  as.matrix(d),
  kfit$cluster,
  color = T,
  shade = T,
  labels = 2,
  lines = 0
)

#Fechamos o sink
sink()
