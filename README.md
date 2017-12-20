# flc-adv-change-order-powerbi
R script that uses Fusion Lifecycle V3 API to enable cross-workspace reporting

In Fusion Lifecycle, you can approve an item for Production, even if its children are still in work. This is what we want to prevent with this report.

When you define the Change Order, you have to list all the items to be approved (either new ones or the ones being modified). And usually, this will list all the sub assemblies and components as you can easily add the whole assembly to the Change Order with a single click. But if the users modify these items’ BOMs later on (e.g. by adding or replacing a component), the CO will no longer list all the parts which require approval. And this will be very, very hard for the prover to figure out. Therefore, this report enables to do this validation automatically: the report will analyse all the CO's affected items and verify that their BOMs only contain items that are either approved already or which are listed as affected item as well. If the items to be approved contain an item which is in work and not part of the affected items list, the report will highlight these items.

As an example, let's consider this simple BOM
![alt text](https://github.com/mazerab/flc-adv-change-order-powerbi/blob/master/www/img/before%20BOM.png)
