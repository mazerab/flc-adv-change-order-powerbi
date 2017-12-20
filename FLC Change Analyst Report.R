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
WfItems_Descriptor_List = list()
BOMItems_Descriptor_List = list()
JSESSIONID = ""

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
  JSESSIONID = lapply(cookies(req), "[[", 2)$value
  # Get list of affected items for the ECO
  workflow_items_req <- httr::GET(paste0(Tenant_Url, "/api/rest/v1/workspaces/", Change_Orders_Workspace_Id, "/items/", Change_Order_DmsId, "/workflow-items"),
                                  httr::add_headers("Content-Type" = "application/json"),
                                  set_cookies("JSESSIONID" = JSESSIONID)
  );
  if (status_code(workflow_items_req) == '200') {
    workflow_items_content = content(workflow_items_req)
    if (length(workflow_items_content$list$workflowItem) > 0) { # Ensure the list of affected items is not empty
      for (wfItem in workflow_items_content$list$workflowItem) {
        WfItems_DmsId_List <- c(wfItem$masterItem$id, WfItems_DmsId_List)
        WfItems_Descriptor_List <- c(wfItem$masterItem$details$descriptor, WfItems_Descriptor_List)
      }
    }
  }
  
  # Get BOM for each affected items
  for (dmsId in WfItems_DmsId_List) {
    bom_item_req <- httr::GET(paste0(Tenant_Url, "/api/rest/v1/workspaces/", Items_BOMs_Workspace_Id, "/items/", dmsId, '/boms'),
                              httr::add_headers("Content-Type" = "application/json"),
                              set_cookies("JSESSIONID" = JSESSIONID)
    );
    if (status_code(bom_item_req) == '200') {
      bom_item_content = content(bom_item_req)
      if (length(bom_item_content$list$data) > 0) {
        for (bomItem in bom_item_content$list$data) {
          BOMItems_Descriptor_List <-c(bomItem$`bom-item`$descriptor, BOMItems_Descriptor_List)
        }
      }
    }
  }
  
}

for (bomItem in BOMItems_Descriptor_List) {
  if (endsWith(bomItem, "[REV:w]")) {
    if (!(bomItem %in% WfItems_Descriptor_List)) {
      print("Found a BOM item that is not in the list of affected items of this change order!")
      print(bomItem)
    }
  }
}
