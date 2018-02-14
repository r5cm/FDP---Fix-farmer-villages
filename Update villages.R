# Login to Salesforce
library(RForcecom)
username.adm <- "admin@utzmars.org"
password.adm <- "gfutzmars2018n0ljYwQQqYVWfu9RIfPqWIn8"
session.adm <- rforcecom.login(username.adm, password.adm)

username.rep <- "reports@utzmars.org"
password.rep <- "marsme2018HWNSDAF67f2wAQNThoFnEHEV"
session.rep <- rforcecom.login(username.rep, password.rep)

# Retrieve farmers with submission__r.village
farmers <- rforcecom.retrieve(session.rep, "farmer__c", 
                              c("Id", "FDP_submission__r.village__c"))
library(dplyr)
farmers <- select(farmers, Id, FDP_submission__c.village__c)
names(farmers) <- c("Id.farmer", "subm.village")
# Clean farmers
farmers <- farmers[!is.na(farmers$subm.village), ]
rm.farmers <- c("Happy Village", "Happy Village3", "Sync Vill2")
farmers <-  farmers[!(farmers$subm.village %in% rm.farmers ), ]
# Fix mispelt villages
farmers$subm.village <- gsub("Salu paremang", "Salu Paremang", farmers$subm.village)
farmers$subm.village <- gsub("Olo-Oloho", "Olo-oloho", farmers$subm.village)
farmers$subm.village <- gsub("Bone pute", "Bone Pute", farmers$subm.village)
farmers$subm.village <- gsub("sumabu", "Sumabu", farmers$subm.village)
farmers$subm.village <- gsub("Mekar Sari Jaya", "Mekar sari jaya", farmers$subm.village)
farmers$subm.village <- gsub("Buntu Terpedo", "buntu torpedo", farmers$subm.village)
farmers$subm.village <- gsub("Terpedo Jaya", "Torpedo jaya", farmers$subm.village)
farmers$subm.village <- gsub("Lembang-Lembang", "LeMbang-LeMbang", farmers$subm.village)
farmers$subm.village <- gsub("Mekar Sai Jaya", "Mekar sari jaya", farmers$subm.village)

# Retrieve village names and  ID
villages <- rforcecom.retrieve(session.rep, "village__c", 
                               c("Id", "Name", "district__r.Name"))
names(villages) <- c("Id.village", "name.village", "name.district")
# Remove duplicated villages
villages <- villages[order(villages$name.village), ]
dup.villages <- duplicated(villages$name.village)
villages <- villages[!dup.villages, ]



# Add village Id to farmers
farmers <- farmers %>% left_join(villages, by = c("subm.village" = "name.village"))
farmers.upd <- select(farmers, Id.farmer, Id.village)
names(farmers.upd) <- c("Id", "village__c")

# Update farmer's  villages
# run an insert job into the Account object
job_info <- rforcecom.createBulkJob(session.adm, 
                                    operation='update', 
                                    object='farmer__c')

# split into batch sizes of 500 (2 batches for our 1000 row sample dataset)
batches_info <- rforcecom.createBulkBatch(session.adm, 
                                          jobId=job_info$id, 
                                          farmers.upd, 
                                          multiBatch = TRUE, 
                                          batchSize=500)

# check on status of each batch
batches_status <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session.adm, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
# get details on each batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session.adm, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })
# close the job
close_job_info <- rforcecom.closeBulkJob(session.adm, jobId=job_info$id)

# Test update (SF report)
# https://taroworks-1410.cloudforce.com/00O0K00000A2QsZ