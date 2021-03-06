
library(combinat)
library(stringr)
library(ggplot2)
library(reshape)

#calculating function, comments in 'game24' R file
num_sign=function(a,b,sign){
  if(sign==1){
    return(a+b)
  }
  else if(sign==2){
    return(a-b)
  }
  else if(sign==3){
    return(a*b)
  }
  else if(sign==4){
    return(a/b)
  }
  else if(sign==5){
    return(b-a)
  }
  else if(sign==6){
    return(b/a)
  }
}


#Print strings, comments in 'game24' R file
trans=function(b,c,a){
  stopifnot(a==1 | a==2 | a==3 | a==4 | a==5 | a==6)
  if(a==1){
    k1=paste("(",b,"+",c,")")
    return(k1)
  }
  else if(a==2){
    k2=paste("(",b,"-",c,")")
    return(k2)
  }
  else if(a==3){
    k3=paste(b,"*",c)
    return(k3)
  }
  else if(a==4){
    k4=paste(b,"/",c)
    return(k4)
  }
  else if(a==5){
    k5=paste("(",c,"-",b,")")
    return(k5)
  }
  else{
    k6=paste(c,"/",b)
    return(k6)
  }
}


#Main function, comments in 'game24' R file
game24_table=function(A,b){
  len=length(A)
  B=combinat::permn(A)
  stopifnot(len==4)
  stopifnot(A[1]%%1==0 & A[2]%%1==0 & A[3]%%1==0 & A[4]%%1==0)
  method=vector(mode="character",length=0)
  operation_1=vector(mode="character",length=0)
  operation_2=vector(mode="character",length=0)
  operation_3=vector(mode="character",length=0)
  rep=vector(mode="integer",length=0)
  result1=vector(mode="integer",length=0)
  result2=vector(mode="integer",length=0)
  for(s in 1:factorial(len)){
    for(i in 1:6){
      result1_temp=num_sign(B[[s]][1],B[[s]][2],i)
      for(j in 1:6){
        result2_temp=num_sign(result1_temp,B[[s]][3],j)
        for(k in 1:6){
          result3=num_sign(result2_temp,B[[s]][4],k)
          if(result3==b){
            operation_1=c(operation_1,trans(B[[s]][1],B[[s]][2],i))
            operation_2=c(operation_2,trans(result1_temp,B[[s]][3],j))
            operation_3=c(operation_3,trans(result2_temp,B[[s]][4],k))
            result1=c(result1,result1_temp)
            result2=c(result2,result2_temp)
          }
        }
      }
    }
  }

  if(length(result1) == 0) {
    return(FALSE)
  }

  for(q in 1:(length(result1)-1)){
    s=q+1
    for(p in s:length(result1)){
      if(result1[q]==result1[p]){
        if(result2[q]==result2[p]){
          rep=c(rep,p)
        }
      }
    }
  }
  operation_1=operation_1[-rep]
  operation_2=operation_2[-rep]
  operation_3=operation_3[-rep]
  result1=result1[-rep]
  result2=result2[-rep]

  for(f in 1:length(operation_1)){
    method=c(method,str_c(operation_1[f]," = ", result1[f], " then ",
                          operation_2[f]," = ", result2[f], " then ",
                          operation_3[f],  " = ", b))
  }

  return(length(method))
}



#Generate frequency of methods table. game24table gives users the table of all the combinations of the number the user input as well as the counts of different method to get 24. 
game24table = function(x, b) {
  # x is the input by user
  x = as.integer(x)

  #Generate first three card
  sample = combn(1:13, 3)
  sample = t(sample)
  n = nrow(sample)
  sample = cbind(sample, rep(x, n)) #Construct frame with 4 cards
  counts = vector(mode = "integer", length = 0)

  #Use the for loop to get the counts of the number of the methods for each combination
  for (i in 1:n) {
    count = game24_table(sample[i,], b)
    counts = c(counts, count)
  }

  result = cbind(sample, counts)
  result = as.data.frame(result)
  colnames(result) = c('Card1', 'Card2', 'Card3', 'Card4', 'Count')

  return(result)
}



#Test for frequency
#count = game_table()


#Calculate the probability of combinations can do 24
game24prob = function(x, b) {
  count = game24table(x, b)
  probability = length(count[count == 0])/nrow(count)
  #print(paste("Given that at least one card is the number you input, the probability of being able to calculate 24 is "))
  return(1-probability)

}

#Test for probability
#probability = game24prob(7)


##ggplot

plot_comparison = function(b) {
  #We pre ran the probability of each cards can do 24 to save running time
  probs_24 = c(0.7272727, 0.8951049, 0.8706294, 0.8741259, 0.7902098, 0.8601399, 0.6958042,
               0.8461538, 0.7587413, 0.7587413, 0.6713287, 0.8496503, 0.6398601)
  cards = 1:13

  #Calculate the probability for user interested number
  probs_other = vector(mode = "numeric", length = length(cards))
  for (i in 1:length(cards)) {
    probs_other[i] = game24prob(cards[i],b)
  }

  #Combine the probability of game24 and game other
  df_24 = cbind(cards, probs_24, probs_other)
  df_24 = as.data.frame(df_24)
  colnames(df_24) = c("cards","probability 24", "probability of user interest")

  df <- reshape::melt(df_24, id = c("cards")) #This steps is doing to help visulisation
  #Plot the comparison ggplot
  ggplot = ggplot2::ggplot(df, aes(x=cards, y = value, fill = variable))+
    geom_bar(stat='identity', position='dodge') +
    labs(x = "cards", y = "probability", title = "Why game24? Probability of each cards getting 24 vs getting other number")

  return(ggplot)
}

#Test for plot
#plot_comparison(27)
