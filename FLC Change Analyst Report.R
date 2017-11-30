#########################################################################################
## This R script is a sample code that demonstrate 
## how to extract information from two workspaces using Autodesk Fusion Lifecycle V3 API.
#########################################################################################
# Define Fusion Lifecycle username and password, and tenant URL
User_Name <- "Input your Autodesk ID here"
User_Password <- "Input your Autodesk ID password here"
Tenant_Url <- "Input your Fusion Lifecycle site Url here"
Items_BOMs_Workspace_Id <- "Input the workspace Id of your Items & BOMs workspace here"
Change_Orders_Workspace_Id <- "Input the workspace Id of your Change Orders workspace here"

#Load libraries required for the R script
library(httr)
library(jsonlite)

#Use Fusion Lifecycle Authentication REST V1 API to get access token
App_Authenticate <- POST(Tenant_Url "/rest/auth/1/login",
                 add_headers("Accept" = "application/json"),
                 add_headers("Content-Type" = "application/json"),
                 body=I(list(userID = User_Name,
                             password = User_Password)),
                 encode = "form")
Access_Token <- paste("Bearer", content(App_Authenticate)$access_token,  sep=" ")



# Clear Variables
rm(i, User_Name,
   User_Password,
   Tenant_Url,
   Items_BOMs_Workspace_Id,
   Change_Orders_Workspace_Id
   )
© 2017 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
API
Training
Shop
Blog
About
