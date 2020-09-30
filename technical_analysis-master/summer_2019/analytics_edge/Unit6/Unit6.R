movies= read.table("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit6/movielens.txt", header= F, sep="|", quote="\"")
str(movies)

############ SOME DATA CLEANING

# add column names
colnames(movies)= c("ID", "Title","Release Date", "VideoReleaseDate","IMDB","Unknown", "Action", "Adventure", "Animation", "Children", "Comedy", "Crime", "Documentary", "Drama", "Fantasy", "FilmNoir","Horror", "Musical", "Mystery", "Romance","SciFi", "Thriller","War", "Western")

# remove variables we won't need
movies$ID =NULL
movies$`Release Date`=NULL
movies$VideoReleaseDate=NULL
movies$IMDB=NULL

# remove duplicates
movies= unique(movies)

###############################
## CLUSTERING

# 1. compute distances

distances= dist(movies[2:20], method="euclidean")
# "ward.D" cares about distances between clusters using centroid distance. Is a minimum variance method
# "hclust" is for hierarchical clustering

clusterMovies = hclust(distances, method = "ward.D")
# to get an idea of how many clusters
##  plot(clusterMovies)

# 2. create k=10 clusters
clusterGroups= cutree(clusterMovies, k=10)
# divide datapoints into the ten clusters and then the mean for every cluster for Action== True
tapply(movies$Action, clusterGroups, mean)
tapply(movies$Romance, clusterGroups, mean)

# find to what cluster MIB belongs
subset(movies, Title=="Men in Black (1997)")
clusterGroups[257]

# select all movies in cluster 2
cluster2= subset(movies, clusterGroups==2)
# get the first few titles in cluster 2
cluster2$Title[1:10]

##################################################
############ ALTERNATIVE APPROACH  to Finding Cluster Centroids

# The following command will split the data into subsets based on the clusters:
spl = split(movies[2:20], clusterGroups)
# you can use spl to access the different clusters, because " spl[[1]] "
# is the same as " subset(movies[2:20], clusterGroups == 1) "

# The following command will output the cluster centroids for all clusters:
  
lapply(spl, colMeans)

# The lapply function runs the second argument (colMeans) on 
# each element of the first argument (each cluster subset in spl). 
# So instead of using 19 tapply commands, or 10 colMeans commands, we can output our 
# centroids with just two commands: one to define spl, and then the lapply command.


# WITH k=2, turns out that in the second cluster there are only Drama movies, whereas the first cluster has 
# a bit of everything
clusterGroups2= cutree(clusterMovies, k=2)
spl2 = split(movies[2:20], clusterGroups2)
lapply(spl2, colMeans)

###############################################################################################

flower= read.csv("flower.csv", header=F )
str(flowerMatrix)
# turn these observation into a matirx
flowerMatrix= as.matrix(flower)
flowerVector= as.vector(flowerMatrix)

#### CLUSTERING
# there are n*(n-1)/2 distance elements, where n is the lenght of the VECTOR (n=2500)
distance= dist(flowerVector, method= "euclidean")

# "ward.D" cares about distances between clusters using centroid distance. Is a minimum variance method
clusterIntensity= hclust(distance, method="ward.D")
###  plot(clusterIntensity)  
# plot rectagles around clusters
rect.hclust(clusterIntensity, k=3, border="red")
# vector assigning eah observation to a cluster
flowerClusters= cutree(clusterIntensity, k=3)
tapply( flowerVector, flowerClusters, mean)

###### PLOT THE IMAGE
# turn the vector into a matrix
dim(flowerClusters)= c(50,50)
image(flowerClusters, axes=F)

# compare plot above with plot from original data
image(flowerMatrix, axes=F, col=grey(seq(0,1,length=256 )))

#########################################################################
healthy= read.csv("healthy.csv", header=F)
healthyMatrix= as.matrix(healthy)
str(healthyMatrix)

# to see the MRI image, use ' image()'
image(healthyMatrix, axes= F, col= grey(seq(0,1, length= 256)))

## HIERARCICAL CLUSTERING
# 1. create a vector
healthyVector= as.vector(healthyMatrix)
# 2. compute the distance matrix
distance=  dist(healthyVector, method= "euclidean")
# Warning: vector size too large!

## TRY K-MEANS CLUSTERING INSTEAD
# Specify number of clusters k
k=5
set.seed(1)
# k-means cluster algorithm
KMC= kmeans(healthyVector, centers=k , iter.max=1000)
str(KMC)
healthyClustres= KMC$cluster

# mean intensity value of cluster[x]
KMC$centers[2]

# size of clusters
KMC$size

dim(healthyClustres)= c(nrow(healthyMatrix), ncol(healthyMatrix))
image(healthyClustres, axes= F, col= rainbow(k))

#########################################
tumor= read.csv("tumor.csv", header=F)
tumorMatrix= as.matrix(tumor)
tumorVector= as.vector(tumorMatrix)

# Basically we the data from 'healthy' as a training set,
# and data from 'tumor' as a testing set 

# install.packages("flexclust")
library(flexclust)

# KCCA= k-centroids cluster analysis
KMC.kcca= as.kcca(KMC,healthyVector)
tumorClusters= predict(KMC.kcca, newdata= tumorVector)
dim(tumorClusters) = c(nrow(tumorMatrix), ncol(tumorMatrix))
image(tumorClusters, axes=F, col= rainbow(k))

#####################################################################################################
##################### RECITATION ######################################

dailykos= read.csv("dailykos.csv", header = T)

###############################
## HIERARCICAL CLUSTERING

distances= dist(dailykos[1:1545], method="euclidean")

# "ward.D" cares about distances between clusters using centroid distance. Is a minimum variance method
# "hclust" is for hierarchical clustering
cluster.dailykos = hclust(distances, method = "ward.D")

# to get an idea of how many clusters it would be appropriate to have, plot the dendogram
plot(cluster.dailykos)

# create k clusters
cluster.groups= cutree(cluster.dailykos, k=7)
str(cluster.groups)
table(cluster.groups)
# Then, you can use the subset function k times to split the data into the k clusters
hCluster1= subset(dailykos, cluster.groups == 1)
hCluster2= subset(dailykos, cluster.groups == 2)
hCluster3= subset(dailykos, cluster.groups == 3)
hCluster4= subset(dailykos, cluster.groups == 4)
hCluster5= subset(dailykos, cluster.groups == 5)
hCluster6= subset(dailykos, cluster.groups == 6)
hCluster7= subset(dailykos, cluster.groups == 7)

# OR Equivalently
HierCluster = split(dailykos, hierGroups)
# Then cluster 1 can be accessed by typing HierCluster[[1]], etc.


# This computes the mean frequency values of each of the words in cluster 1, and then outputs the 6 words that occur the most frequently
# colMeans() function computes the column (word) means
# sort() function orders the words in increasing order of the mean values
# tail() function outputs the last 6 words listed
tail(sort(colMeans(hCluster1)))
tail(sort(colMeans(hCluster2)))
tail(sort(colMeans(hCluster3)))
tail(sort(colMeans(hCluster4)))
tail(sort(colMeans(hCluster5)))
tail(sort(colMeans(hCluster6)))
tail(sort(colMeans(hCluster7)))

######################################
###  K-Means Clustering


dailykos.matrix= as.matrix(dailykos)
dailykos.vector= as.vector(dailykos.matrix)
# Specify number of clusters k
k=7
set.seed(1000)
# k-means cluster algorithm
KmeansCluster = kmeans(dailykos.vector, centers=k )

#  Given a vector assigning groups like KmeansCluster$cluster, you could split dailykos into the clusters by typing:
KmeansCluster = split(dailykos, KmeansCluster$cluster)
# no. of obs of cluster 3
KmeansCluster[[3]] 


###### OR Equivalently
KmeansCluster1 = subset(dailykos, KmeansCluster$cluster == 1)

KmeansCluster2 = subset(dailykos, KmeansCluster$cluster == 2)

KmeansCluster3 = subset(dailykos, KmeansCluster$cluster == 3)

KmeansCluster4 = subset(dailykos, KmeansCluster$cluster == 4)

KmeansCluster5 = subset(dailykos, KmeansCluster$cluster == 5)

KmeansCluster6 = subset(dailykos, KmeansCluster$cluster == 6)

KmeansCluster7 = subset(dailykos, KmeansCluster$cluster == 7)


# This computes the mean frequency values of each of the words in cluster 1, and then outputs the 6 words that occur the most frequently
# colMeans() function computes the column (word) means
# sort() function orders the words in increasing order of the mean values
# tail() function outputs the last 6 words listed
tail(sort(colMeans(KmeansCluster1)))
tail(sort(colMeans(KmeansCluster2)))
tail(sort(colMeans(KmeansCluster3)))
tail(sort(colMeans(KmeansCluster4)))
tail(sort(colMeans(KmeansCluster5)))
tail(sort(colMeans(KmeansCluster6)))
tail(sort(colMeans(KmeansCluster7)))

## Q: Which Hierarchical Cluster best corresponds to K-Means Cluster 2?
table(hierGroups, KmeansCluster$cluster)

##########################################################################
################################################################################
airline= read.csv("AirlineCluster.csv", header=T)