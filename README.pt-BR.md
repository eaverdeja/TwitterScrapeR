## TwitterScrapeR

Projeto acadêmico para exercitar conceitos e técnicas de data mining utilizando
o R como ferramenta

---

### Prerequisitos

Você deve ter o R instalado na sua máquina (versão 3.5.1^), você pode usar o [docker](https://github.com/rocker-org/rocker)

### Como usar

1. Clone esse repositório com `$ git clone git@github.com:eaverdeja/TwitterScrapeR.git`
2. Cria uma conta de desenvolvedor no Twitter e obtenha suas credenciais - tokens incluídos. Essa é uma pesquisa rápida no Google, então não vou cobrir isso aqui
3. Copie ou renomeie o arquivo `.env.example` para `.env` e preencha os valores com as suas credencias do Twitter
4. `$ Rscript index.R`

    O script deve instalar as dependências necessárias e gerar os arquivos **output.txt** e **Rplots.pdf**. Os arquivos de exemplo no repositório foram
    gerados as 21:47 do dia 17 de Novembro de 2018. Os demais parâmetros da pesquisa
    estão especificados em `index.R`
