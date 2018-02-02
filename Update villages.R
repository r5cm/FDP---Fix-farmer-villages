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

# PENDIENTES: Patila, Tolangi, Mulyorejo and Kalotok


# Retrieve village names and  ID
villages <- rforcecom.retrieve(session.rep, "village__c", 
                               c("Id", "Name", "district__r.Name"))
names(villages) <- c("Id.village", "name.village", "name.district")
# Remove duplicated villages
villages <- villages[order(villages$name.village), ]
dup.villages <- duplicated(villages$name.village)
villages <- villages[!dup.villages, ]



# Add village Id to farmers
library(dplyr)
test <- farmers %>% left_join(villages, by = c("subm.village" = "name.village"))

farmers.upd <- select(farmers, Id.farmer, Id.village)

# Update farmer's  villages

# Test update