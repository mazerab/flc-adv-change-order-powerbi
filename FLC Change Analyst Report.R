#########################################################################################	
## This R script is a sample code that demonstrate
## how to extract information from two workspaces using Autodesk Fusion Lifecycle V3 API.
#########################################################################################
# Define Fusion Lifecycle username and password, and tenant URL
User_Name = "Input your Autodesk ID here"
User_Password = "Input your Autodesk ID password here"
Tenant_Url = "Input your Fusion Lifecycle site Url here"
Items_BOMs_Workspace_Id = "Input the workspace Id of your Items & BOMs workspace here"
Change_Orders_Workspace_Id = "Input the workspace Id of your Change Orders workspace here"
Change_Order_DmsId = "Input the dmsId of the change order you want to check on"
WfItems_DmsId_List = list()
	
#Load libraries required for the R script
library(httr)
library(jsonlite)
	
#Use Fusion Lifecycle Authentication REST V1 API to get access token
login_body <- list(userID = User_Name, password = User_Password)
login_body = toJSON(login_body, pretty = TRUE, auto_unbox = TRUE)
req <- httr::POST(paste0(Tenant_Url, "/rest/auth/1/login"),
                  httr::add_headers("Accept" = "application/json","Content-Type" = "application/json"),
                  body = login_body
);
	
#Extract the cookie
if (status_code(req) == '200') {
  print(lapply(cookies(req), "[[", 2)$value)
  # Get list of affected items for the ECO
  workflow_items_req <- httr::GET(paste0(Tenant_Url, "/api/rest/v1/workspaces/", Change_Orders_Workspace_Id, "/items/", Change_Order_DmsId, "/workflow-items"),
                                  httr::add_headers("Content-Type" = "application/json"),
                                  set_cookies("JSESSIONID" = lapply(cookies(req), "[[", 2)$value)
  );
  if (status_code(workflow_items_req) == '200') {
    workflow_items_content = content(workflow_items_req)
    if (length(workflow_items_content$list$workflowItem) > 0) { # Ensure the list of affected items is not empty
      for (wfItem in workflow_items_content$list$workflowItem) {
        WfItems_DmsId_List <- c(wfItem$masterItem$id, WfItems_DmsId_List)
      }
    }
  }
  
  # Get BOM for each affected items through https://adskmazerab.autodeskplm360.net/api/v3/workspaces/57/items/7422/bom 
  print(WfItems_DmsId_List) # list of the affected items' dmsIds ...
}
