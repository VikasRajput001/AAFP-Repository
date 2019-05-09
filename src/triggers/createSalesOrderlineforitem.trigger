trigger createSalesOrderlineforitem on OrderApi__Sales_Order_Line__c (after insert,after update) {

  if(trigger.isInsert && trigger.isAfter ){
  
  CreateSalesOrderLine.SalesOrderLinesForItems(trigger.new);
  }

}