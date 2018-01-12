#########################################################################################
## This R script is a sample code that demonstrate 
## how to extract information from two workspaces using Autodesk Fusion Lifecycle V3 API.
#########################################################################################
# Define Fusion Lifecycle username and password, and tenant URL
User_Name <- "<Your Fusion Lifecycle Login Name>"
User_Password <- "<Your Fusion Lifecycle Login Password>"
Tenant_Name <- "<Your Fusion Lifecycle Site Name>"
Items_BOMs_Workspace_Id <- "<ID of your Items and BOMs workspace, typically 57 ...>"
Change_Orders_Workspace_Id <- "<ID of your Change Orders workspace, typically 9 ...>"
Change_Order_DmsId <- "<dmsID of your Change Order>"
Tenant_Url = paste0("https://", Tenant_Name, ".autodeskplm360.net")

WfItems_DmsId_List = list()
WfItems_Descriptor_List = list()
BOMItems_Descriptor_List = list()
BOMItems_Problem_List = list()
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
          if (!(is.element(bomItem$`bom-item`$descriptor, BOMItems_Descriptor_List))) {
            BOMItems_Descriptor_List <-c(bomItem$`bom-item`$descriptor, BOMItems_Descriptor_List)
          }
        }
      }
    }
  }
  
}

for (bomItem in BOMItems_Descriptor_List) {
  if (endsWith(bomItem, "[REV:w]")) {
    if (!(bomItem %in% WfItems_Descriptor_List)) {
      BOMItems_Problem_List <-c(bomItem, BOMItems_Problem_List)
    }
  }
}

#create data frame for PowerBI.
WfItems_Descriptor_Frame <- data.frame(matrix(data=sapply(WfItems_Descriptor_List, as.character), ncol=1, byrow=TRUE))
names(WfItems_Descriptor_Frame)[startsWith(names(WfItems_Descriptor_Frame),"matrix.data")] <- "Affected Items"
WfItems_Descriptor_Frame

BOMItems_Descriptor_Frame <- data.frame(matrix(data=sapply(BOMItems_Descriptor_List, as.character), ncol=1, byrow=TRUE))
names(BOMItems_Descriptor_Frame)[startsWith(names(BOMItems_Descriptor_Frame),"matrix.data")] <- "BOM Items"
BOMItems_Descriptor_Frame

if (length(BOMItems_Problem_List) > 0) {
  BOMItems_Problem_Frame <- data.frame(matrix(data=sapply(BOMItems_Problem_List, as.character), ncol=1, byrow=TRUE))
  names(BOMItems_Problem_Frame)[startsWith(names(BOMItems_Problem_Frame),"matrix.data")] <- "Problem Items"
  BOMItems_Problem_Frame
}
