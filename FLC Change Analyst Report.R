#########################################################################################
## This R script is a sample code that demonstrate 
## how to extract information from two workspaces using Autodesk Fusion Lifecycle V3 API.
#########################################################################################
# Define Fusion Lifecycle username and password, and tenant URL
# User_Name <- "Input your Autodesk ID here"
# User_Password <- "Input your Autodesk ID password here"
# Tenant_Url <- "Input your Fusion Lifecycle site Url here"
# Items_BOMs_Workspace_Id <- "Input the workspace Id of your Items & BOMs workspace here"
# Change_Orders_Workspace_Id <- "Input the workspace Id of your Change Orders workspace here"
User_Name = "bastien.mazeran"
User_Password = "quinsac4$"
Tenant_Url = "https://adskmazerab.autodeskplm360.net"
Items_BOMs_Workspace_Id = "57"
Change_Orders_Workspace_Id = "9"
ECO_Number = "CO000012"
ECO_DmsId = ""

#Load libraries required for the R script
library(httr)
library(jsonlite)

#Use Fusion Lifecycle Authentication REST V1 API to get access token
login_body <- list(userID = User_Name, password = User_Password)
login_body = toJSON(login_body, pretty = TRUE, auto_unbox = TRUE)
req <- httr::POST(paste0(Tenant_Url, "/rest/auth/1/login"),
                  httr::add_headers(
                    "Accept" = "application/json",
                    "Content-Type" = "application/json"
                  ),
                  body = login_body
);

#Extract the cookie
if (status_code(req) == '200') {
  print(lapply(cookies(req), "[[", 2)$value)
  search_req <- httr::GET(paste0(Tenant_Url, "/api/v3/search-results?query=", ECO_Number, "&workspace=", Change_Orders_Workspace_Id),
                          httr::add_headers("Content-Type" = "application/json"),
                          set_cookies("JSESSIONID" = lapply(cookies(req), "[[", 2)$value)
  );
  status_code(search_req)
  content(search_req)
  # Get list of affected items for that ECO through GET https://adskmazerab.autodeskplm360.net/api/v3/workspaces/9/items/7468/affected-items 
  # Get BOM for each affected items through https://adskmazerab.autodeskplm360.net/api/v3/workspaces/57/items/7422/bom 
}
