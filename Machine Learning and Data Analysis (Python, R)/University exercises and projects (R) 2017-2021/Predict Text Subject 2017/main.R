library("Matrix")

####Reading File #######
S       <- readLines("BaseReuters-29")

#####Splitting up the syntax of file #######
List_of_Lists_of_Class_and_Tripels <- strsplit(S," ")  # Tripel of the form Form integer:integer
classes <- as.integer(sapply(List_of_Lists_of_Class_and_Tripels,function(x)x[1]))
List_of_Matrices <- lapply(List_of_Lists_of_Class_and_Tripels,function(linie) vapply(linie[-1],function(tripel) as.integer(strsplit(tripel,":")[[1]]),FUN.VALUE=c("Wort_index"=0,"Anzahl"=0)))   #This Step Takes Long!!!

######Preparing sparse matrix  ################
### Matrix gets for every document one line and for every word one column
help_list               <- lapply(List_of_Matrices,function(x)x[1,])
vector_of_word_indices  <- as.integer( c(help_list,recursive=TRUE) )
vector_of_amounts       <- c(lapply(List_of_Matrices,function(x)x[2,]),recursive=TRUE) 
n_documents             <- length(List_of_Matrices)
amount_of_words_per_doc <- sapply(List_of_Matrices,function(x)dim(x)[2])
vector_of_doc_ind       <- c( lapply( 1:n_documents,function(x) rep(x,amount_of_words_per_doc[x]) ),recursive=TRUE )
Matrix                  <- sparseMatrix(i=vector_of_doc_ind,j=vector_of_word_indices,x=vector_of_amounts,giveCsparse = FALSE) # dim = n_documents x n_vocabulary
Matrix_Bernoulli        <- Matrix>0

##### Function for Estimating Parameters ##############
estimate <- function(data_matrix,classes_vector,all_possible_classes,way)
  # data_matrix:           each line represents one document, each column represents one word     dim = n_docs_train x n_vocabulary
  # classes_vector:        each entry for the given class of one document                         length = n_docs_train
  # all_possible_classes: for the case that the training set does not contain for every class one example of a document
  # way:                   "bernoulli" or "multi" (for multinomial
{
  classes_as_factor <- factor(classes_vector,levels=all_possible_classes)       # factor the classes by including all classes, also those who have no representant in the training set
  n_classes <- length(all_possible_classes)                                     # number of different classes
  n_vocabulary <- dim(data_matrix)[2]                                           # number of different words
  n_docs_train <- dim(data_matrix)[1]                                           # number of training documents
  times_classes <- as.matrix(table(classes_as_factor))                          # amount of documents in each class
  times_word_in_class <- Matrix(0,nrow=n_vocabulary,ncol=n_classes,sparse=TRUE) # dim = n_voc x n_classes
  for (k in all_possible_classes)                                               # fill the latest matrix
  {
    times_word_in_class[,k] <- colSums(data_matrix[classes_vector==k,,drop=FALSE]) # dim = n_voc x 1
  }
  if (way=="bernoulli")                                                         # calculate estimator for theta for "bernoulli"
  {
    #stuff_of_the_denominator <- colSums(times_word_in_class) + n_vocabulary
    denominator <- times_classes+2
    theta_estimate <- t(apply(as.matrix(times_word_in_class)+1,1,function(x){x/denominator} )) #dim = n_voc x n_classes
  }
  if (way=="multi")                                                             # calculate estimator for theta for "multi"
  {
    denominator <- colSums(times_word_in_class)+n_vocabulary  # dim =  1 x n_classes
    theta_estimate <- t(apply(as.matrix(times_word_in_class)+1,1,function(x) x/(denominator))) #dim = n_voc x n_classes
  }
  pi_estimate    <- times_classes/n_docs_train                                  # calculate estimator for pi
  return(list("theta_estimate"=theta_estimate,"pi_estimate"=pi_estimate,"n_classes"=n_classes,"n_voc"=n_vocabulary,"n_docs_train"=n_docs_train,"times_classes"=times_classes,"times_word_in_class"=times_word_in_class))
}



predict_bernoulli <- function(Theta,Pi,list_non_zero) #documents shall be a sparse matrix (n_doc x n_voc)
  #Theta     : parameter of probability distribution of size n_vocabulary x n_classses
  #Pi        : parameter of probability distribution of size n_classes
  #list_non_zero       : list whose kth element is a vector containing all index numbers of nonzero entries in the kth line
{
  n_docs_pred <- length(list_non_zero)
  ln_Theta <- log(Theta)              # n_voc x n_class
  ln_one_minus_Theta <- log(1-Theta)  # n_voc x n_class
  ln_Pi <- log(Pi)                
  
  #precalculate colsums
  col_sum_ln_one_minus_Theta <- colSums(ln_one_minus_Theta)
  #calculating
  d <- lapply( 1:n_docs_pred, function(n){ 
    which.max(ln_Pi + colSums(ln_Theta[ list_non_zero[[n]], ]) +col_sum_ln_one_minus_Theta - colSums(ln_one_minus_Theta[ list_non_zero[[n]], ]))}   
  )
}

predict_multi <- function(documents,Theta,Pi) #documents shall be a sparse matrix (n_doc x n_voc)
  #documents: each line represents one document, each column represents one word     dim = n_docs_pred x n_vocabulary
  #Theta     : parameter of probability distribution of size n_vocabulary x n_classses
  #Pi        : parameter of probability distribution of size n_classes
{
  n_docs_pred <- dim(documents)[1]
  #n_vocabulary <- dim(documents)[2]
  ln_Theta <- log(Theta)              # n_voc x n_class
  ln_Pi <- log(Pi)  
  
  scalar_products <- documents%*%ln_Theta  # ndoc x n_class
  d <- lapply( 1:n_docs_pred,function(n) which.max(ln_Pi + scalar_products[n,]))
  return(d)
}

##### Repeating a lot of steps #########
n_rounds <- 1
n_train <- 52500
n_pred <- 18203
#non-zero list
cords <- cbind(Matrix@i,Matrix@j)+1
list_non_zero_entries <- help_list
#prediction errors
error_bernoulli <- rep(NaN,n_rounds)
error_multi <- rep(NaN,n_rounds)

for (round in 1:n_rounds)
{
  print(paste0("---------Start Round ",round, " of ",n_rounds," --------"))
  
  set <- sample(c(rep(1,n_train),rep(2,n_pred)))
  
  print("estimate bernoulli...")
  A <- estimate(Matrix_Bernoulli[set==1,,drop=FALSE],classes[set==1],1:29,way="bernoulli")
  print("estimate multi...")
  B <- estimate(Matrix[set==1,,drop=FALSE],classes[set==1],1:29,way="multi")
  
  print("predict bernoulli...")
  a <- predict_bernoulli(A$theta_estimate,A$pi_estimate,list_non_zero_entries[set==2])
  print("predict multi...")
  b <- predict_multi(Matrix[set==2,,drop=FALSE],B$theta_estimate,B$pi_estimate)
  
  error_bernoulli[round] <- 1-sum(a==classes[set==2])/n_pred
  error_multi[round]     <- 1-sum(b==classes[set==2])/n_pred
}
print (error_bernoulli)
print (error_multi)