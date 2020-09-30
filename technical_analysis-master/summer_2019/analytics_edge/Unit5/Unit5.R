# very important to use ' stringsAsFactors= F ' for text analytics problem
tweets <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit5/tweets.csv", stringsAsFactors = F)

str(tweets)

# create new variable for negative tweets
tweets$Negative = as.factor(tweets$Avg <= -1)
table(tweets$Negative)

# Install new packages
library(tm)
library(SnowballC)

# create corpus 
corpus= VCorpus(VectorSource(tweets$Tweet))
# view content of corpus
corpus[[1]]$content

# Start to clean the corpus by lowering all cases
corpus= tm_map(corpus, content_transformer(tolower))

# remove punctuation
corpus = tm_map(corpus, removePunctuation)

# Look at 'stop words'
stopwords("english")[1:10]

# Remove cd. stopwords and word "apple"
corpus = tm_map(corpus, removeWords, c("apple", stopwords("english")))

# Stem document, ie take off the word suffixes due to conjugation etc 
corpus = tm_map(corpus, stemDocument)
