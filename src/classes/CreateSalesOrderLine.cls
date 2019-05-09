public class CreateSalesOrderLine{

    public static void SalesOrderLinesForItems(list<OrderApi__Sales_Order_Line__c> listOfSalesOrderLines ){
    
    list<OrderApi__Sales_Order_Line__c> salesorderLinelist=new list<OrderApi__Sales_Order_Line__c>();
    set<Id> setIdSalesOrder=new set<Id>();
    set<Id> setIdSubscription=new set<Id>();
    set<Id> SalesOrderSetId =new set<Id>();
    set<Id> allsubscriptionId =new set<Id>();
    list<OrderApi__Item__c> ConvenienceItem=[select id,OrderApi__Price__c from OrderApi__Item__c where name='Convenience fee' And OrderApi__Is_Active__c=true];
    map<Id,Id> mapOfSubscription=new map<Id,Id>();
    Map<Id,Id> mapOfSalesOrder = new Map<Id,Id>();
    map<Id,Id> mapOfItem=new map<Id,Id>();
    set<id> setIdItem =new set<Id>();
    set<id> setId=new set<Id>();
    
    for(OrderApi__Sales_Order_Line__c salesOrderLine:listOfSalesOrderLines){
        
        mapOfSubscription.put(salesOrderLine.Id,salesOrderLine.OrderApi__Subscription__c);                    
        allsubscriptionId.add(salesOrderLine.OrderApi__Subscription__c);
        mapOfSalesOrder.put(salesOrderLine.Id,salesOrderLine.OrderApi__Sales_Order__c);
        setIdSalesOrder.add(salesOrderLine.OrderApi__Sales_Order__c);
        mapOfItem.put(salesOrderLine.Id,salesOrderLine.OrderApi__Item__c);
        setId.add(salesOrderLine.OrderApi__Item__c);
            
            }
    if(!setIdSalesOrder.isEmpty()){
    list<OrderApi__Sales_Order__c> salesOrderList = [select id,name,(select id,name,OrderApi__Item__c from OrderApi__Sales_Order_Lines__r where OrderApi__Item__r.Name = 'Convenience fee' ) from OrderApi__Sales_Order__c Where Id in:setIdSalesOrder];
   
        if(salesOrderList.size()>0){
    for(OrderApi__Sales_Order__c salesOrder:salesOrderList){
        if(salesOrder.OrderApi__Sales_Order_Lines__r.size()>0){
            SalesOrderSetId.add(salesOrder.Id); 
        }
      }
    }
  } 
    
    if(!allsubscriptionId.isEmpty()){
    list<OrderApi__Subscription__c> subscriptionlist=[select id from OrderApi__Subscription__c where OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c=true];
        if(subscriptionlist.size()>0){
          for(OrderApi__Subscription__c  subscription : subscriptionlist){
           setIdSubscription.add(subscription.Id);
          }
    }
  } 
   list<OrderApi__Item__c> itemfoundationList=[select id,OrderApi__Price__c from OrderApi__Item__c where Is_Foundation_Donation__c=true And OrderApi__Is_Active__c=true ];
    if(!setId.isEmpty()) {  
      
     if(itemfoundationList.size()>0){
    for(OrderApi__Item__c item : itemfoundationList){
        
        setIdItem.add(item.Id);
      }
     }
    }
    for(OrderApi__Sales_Order_Line__c salesOrderLine:listOfSalesOrderLines){
        
        if(salesOrderLine.OrderApi__Is_Renewal__c==true && salesOrderLine.OrderApi__Subscription__c!=null && setIdSubscription.contains(mapOfSubscription.get(salesOrderLine.Id)) && !SalesOrderSetId.contains(mapOfSalesOrder.get(salesOrderLine.Id)) ){
            if(ConvenienceItem.size()>0){
            OrderApi__Sales_Order_Line__c salesOrderLineConvenienceItem=new OrderApi__Sales_Order_Line__c(); 
            salesOrderLineConvenienceItem.OrderApi__Item__c= ConvenienceItem[0].id;
            salesOrderLineConvenienceItem.OrderApi__Sale_Price__c=ConvenienceItem[0].OrderApi__Price__c;
            salesOrderLineConvenienceItem.OrderApi__Sales_Order__c=salesOrderLine.OrderApi__Sales_Order__c;
            salesorderLinelist.add(salesOrderLineConvenienceItem);
            }
        }
        if(setIdItem.contains(mapOfItem.get(salesOrderLine.Id))){
           OrderApi__Sales_Order_Line__c salesOrderLineFoundationItem=new OrderApi__Sales_Order_Line__c();
           salesOrderLineFoundationItem.OrderApi__Item__c=itemfoundationList[0].Id;
           salesOrderLineFoundationItem.OrderApi__Sale_Price__c=itemfoundationList[0].OrderApi__Price__c;
           salesOrderLineFoundationItem.OrderApi__Price_Override__c =true;
           salesOrderLineFoundationItem.OrderApi__Sales_Order__c=salesOrderLine.OrderApi__Sales_Order__c;
           salesOrderLinelist.add(salesOrderLineFoundationItem);
        }
        
         
    }
    if(salesorderLinelist.size()>0){
    insert salesorderLinelist;
    }
}


    
    
    
}