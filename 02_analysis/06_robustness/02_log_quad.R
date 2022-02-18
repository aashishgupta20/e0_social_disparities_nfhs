#preliminary 
rm(list = ls())
options(stringsAsFactors = FALSE)

#load packages 
library(dplyr)

#set directory 
setwd("C:\\Users\\aashi\\Dropbox\\My PC (PSCStat02)\\Desktop\\caste\\01_do\\02_analysis\\06_robustness\\")

# Source functions file
source("functions.R")

# Create labels for age vectors
ages.5x1 <- c("0","1-4",paste(seq(5,105,5),seq(9,109,5),sep="-"),"110+")
sexes <- c("Female","Male","Total")

# Import matrix of model coefficients
tmp1 <- read.csv("coefs.logquad.HMD719.csv")
tmp2 <- array(c(as.matrix(tmp1[, 3:6])), dim=c(24, 3, 4), dimnames=list(ages.5x1, sexes, c("ax", "bx", "cx", "vx")))
coefs <- aperm(tmp2, c(1,3,2))


#estimate life tables 
  #india
  
  #nfhs2

    #overall
    #predict life tables 
    ex_india_nfhs2_m <- lthat.any2.logquad(coefs, "Male", Q5=0.0801154, QQa=0.27144051)
    ex_india_nfhs2_m
    ex_india_nfhs2_f <- lthat.any2.logquad(coefs, "Female", Q5=0.0888473, QQa=0.21669601)
    ex_india_nfhs2_f
    
    #sc 
    ex_india_nfhs2_m_sc <- lthat.any2.logquad(coefs, "Male", Q5= 0.0914259, QQa=0.29879814)
    ex_india_nfhs2_m_sc
    
    ex_india_nfhs2_f_sc <- lthat.any2.logquad(coefs, "Female", Q5= 0.1031649, QQa=0.26131296)
    ex_india_nfhs2_f_sc
    
    #st 
    ex_india_nfhs2_m_st <- lthat.any2.logquad(coefs, "Male", Q5= 0.1095758, QQa=0.35109714)
    ex_india_nfhs2_m_st
    ex_india_nfhs2_f_st <- lthat.any2.logquad(coefs, "Female", Q5= 0.1109297, QQa=0.25167745)
    ex_india_nfhs2_f_st
    
    #muslim
    ex_india_nfhs2_m_mu <- lthat.any2.logquad(coefs, "Male", Q5= 0.0685569, QQa=0.22328843)
    ex_india_nfhs2_m_mu
    ex_india_nfhs2_f_mu <- lthat.any2.logquad(coefs, "Female", Q5= 0.0713506, QQa=0.21338589)
    ex_india_nfhs2_f_mu
    
    #obc 
    ex_india_nfhs2_m_obc <- lthat.any2.logquad(coefs, "Male", Q5= 0.0765495, QQa=0.28887782)
    ex_india_nfhs2_m_obc
    ex_india_nfhs2_f_obc <- lthat.any2.logquad(coefs, "Female", Q5= 0.0947932, QQa=0.21848096)
    ex_india_nfhs2_f_obc 
    
    #hc 
    ex_india_nfhs2_m_hc <- lthat.any2.logquad(coefs, "Male", Q5= 0.0741670, QQa=0.23821947)
    ex_india_nfhs2_m_hc
    ex_india_nfhs2_f_hc <- lthat.any2.logquad(coefs, "Female", Q5= 0.0764570, QQa=0.18719773)
    ex_india_nfhs2_f_hc 
    
  
  #nfhs4 
    
    #predict life tables 
    #overall
    ex_india_nfhs4_m <- lthat.any2.logquad(coefs, "Male", Q5=0.0511399, QQa=0.21096256)
    ex_india_nfhs4_m
    
    ex_india_nfhs4_f <- lthat.any2.logquad(coefs, "Female", Q5=0.0474309, QQa=0.12905887)
    ex_india_nfhs4_f
    
    #sc 
    ex_india_nfhs4_m_sc <- lthat.any2.logquad(coefs, "Male", Q5=0.0590132, QQa=0.24671400)
    ex_india_nfhs4_m_sc
    
    ex_india_nfhs4_f_sc <- lthat.any2.logquad(coefs, "Female", Q5=0.0532700, QQa=0.14941686)
    ex_india_nfhs4_f_sc
    
    #st
    ex_india_nfhs4_m_st <- lthat.any2.logquad(coefs, "Male", Q5=0.0644771, QQa=0.26291373)
    ex_india_nfhs4_m_st
    
    ex_india_nfhs4_f_st <- lthat.any2.logquad(coefs, "Female", Q5=0.0497542, QQa=0.15428071)
    ex_india_nfhs4_f_st
    
    #muslim 
    ex_india_nfhs4_m_mu <- lthat.any2.logquad(coefs, "Male", Q5=0.04386604, QQa=0.18353079)
    ex_india_nfhs4_m_mu
    
    ex_india_nfhs4_f_mu <- lthat.any2.logquad(coefs, "Female", Q5=0.04861391, QQa=0.12662910)
    ex_india_nfhs4_f_mu
    
    #obc 
    ex_india_nfhs4_m_obc <- lthat.any2.logquad(coefs, "Male", Q5=0.05259454, QQa=0.20393680)
    ex_india_nfhs4_m_obc
    
    ex_india_nfhs4_f_obc <- lthat.any2.logquad(coefs, "Female", Q5=0.04861391, QQa=0.12821309)
    ex_india_nfhs4_f_obc

    #hc 
    ex_india_nfhs4_m_hc <- lthat.any2.logquad(coefs, "Male", Q5=0.0383890, QQa=0.18569350)
    ex_india_nfhs4_m_hc
    
    ex_india_nfhs4_f_hc <- lthat.any2.logquad(coefs, "Female", Q5=0.03713512, QQa=0.10994100)
    ex_india_nfhs4_f_hc
    

#export these files in csv 
  write.csv(ex_india_nfhs2_m$lt, "log_quad_lt\\ex_india_nfhs2_m.csv")
  write.csv(ex_india_nfhs2_f$lt, "log_quad_lt\\ex_india_nfhs2_f.csv")
  write.csv(ex_india_nfhs2_m_sc$lt, "log_quad_lt\\ex_india_nfhs2_m_sc.csv")
  write.csv(ex_india_nfhs2_f_sc$lt, "log_quad_lt\\ex_india_nfhs2_f_sc.csv")
  write.csv(ex_india_nfhs2_m_st$lt, "log_quad_lt\\ex_india_nfhs2_m_st.csv")
  write.csv(ex_india_nfhs2_f_st$lt, "log_quad_lt\\ex_india_nfhs2_f_st.csv") 
  write.csv(ex_india_nfhs2_m_mu$lt, "log_quad_lt\\ex_india_nfhs2_m_mu.csv")
  write.csv(ex_india_nfhs2_f_mu$lt, "log_quad_lt\\ex_india_nfhs2_f_mu.csv")  
  write.csv(ex_india_nfhs2_m_obc$lt, "log_quad_lt\\ex_india_nfhs2_m_obc.csv")
  write.csv(ex_india_nfhs2_f_obc$lt, "log_quad_lt\\ex_india_nfhs2_f_obc.csv") 
  write.csv(ex_india_nfhs2_m_hc$lt, "log_quad_lt\\ex_india_nfhs2_m_hc.csv")
  write.csv(ex_india_nfhs2_f_hc$lt, "log_quad_lt\\ex_india_nfhs2_f_hc.csv")   
  
  write.csv(ex_india_nfhs4_m$lt, "log_quad_lt\\ex_india_nfhs4_m.csv")
  write.csv(ex_india_nfhs4_f$lt, "log_quad_lt\\ex_india_nfhs4_f.csv")
  write.csv(ex_india_nfhs4_m_sc$lt, "log_quad_lt\\ex_india_nfhs4_m_sc.csv")
  write.csv(ex_india_nfhs4_f_sc$lt, "log_quad_lt\\ex_india_nfhs4_f_sc.csv")
  write.csv(ex_india_nfhs4_m_st$lt, "log_quad_lt\\ex_india_nfhs4_m_st.csv")
  write.csv(ex_india_nfhs4_f_st$lt, "log_quad_lt\\ex_india_nfhs4_f_st.csv") 
  write.csv(ex_india_nfhs4_m_mu$lt, "log_quad_lt\\ex_india_nfhs4_m_mu.csv")
  write.csv(ex_india_nfhs4_f_mu$lt, "log_quad_lt\\ex_india_nfhs4_f_mu.csv")  
  write.csv(ex_india_nfhs4_m_obc$lt, "log_quad_lt\\ex_india_nfhs4_m_obc.csv")
  write.csv(ex_india_nfhs4_f_obc$lt, "log_quad_lt\\ex_india_nfhs4_f_obc.csv") 
  write.csv(ex_india_nfhs4_m_hc$lt, "log_quad_lt\\ex_india_nfhs4_m_hc.csv")
  write.csv(ex_india_nfhs4_f_hc$lt, "log_quad_lt\\ex_india_nfhs4_f_hc.csv")   
    
