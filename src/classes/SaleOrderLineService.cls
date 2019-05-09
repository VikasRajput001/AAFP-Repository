public class SaleOrderLineService {
    Public static void createSaleOrderLine(List<OrderApi__Sales_Order_Line__c> newList){
        if(!system.isBatch()){
            List<OrderApi__Item__c> convenienceitemList= [select OrderApi__Price__c from OrderApi__Item__c where Name='Convenience fee' And OrderApi__Is_Active__c=true];//Create a new soli with item 'Convenience fee' of value $15. 
            List<OrderApi__Sales_Order_Line__c> insertSalesOrderLineList = new List<OrderApi__Sales_Order_Line__c>();
            Map<Id,Id> soliVSitem = new Map<Id,Id>();
            Map<Id,Decimal> itemVSprice = new  Map<Id,Decimal>(); 
            Set<Id> ItemIds = new Set<Id>();
            Map<Id,Id> soliVSsubscription = new Map<Id,Id>();
            Set<Id> subscriptionIds = new Set<Id>();
            Set<Id> salesOrderIds = new Set<Id>();
            Set<Id> existingConvenienceFeeSoli = new Set<Id>();
            
            if(newList.size()>0){
                for(OrderApi__Sales_Order_Line__c currentSoli:newList){
                    ItemIds.add(currentSoli.OrderApi__Item__c);//Item Id
                    soliVSitem.put(currentSoli.Id,currentSoli.OrderApi__Item__c);
                    subscriptionIds.add(currentSoli.OrderApi__Subscription__c);//Subscription Id
                    soliVSsubscription.put(currentSoli.Id,currentSoli.OrderApi__Subscription__c);
                    salesOrderIds.add(currentSoli.OrderApi__Sales_Order__c);
                }
                if(!salesOrderIds.isEmpty()){
                    List<OrderApi__Sales_Order_Line__c> existingSoli = [select OrderApi__Sales_Order__c from OrderApi__Sales_Order_Line__c where OrderApi__Sales_Order__c in:salesOrderIds And OrderApi__Item__r.Name='Convenience fee'];
                    if(existingSoli.size()>0){
                        for(OrderApi__Sales_Order_Line__c ext:existingSoli){
                            existingConvenienceFeeSoli.add(ext.OrderApi__Sales_Order__c);
                        }
                    }
                }
                if(!ItemIds.isEmpty()){
                    List<OrderApi__Item__c> foundationDonationItemList= [select OrderApi__Price__c from OrderApi__Item__c where Is_Foundation_Donation__c=true And OrderApi__Is_Active__c=true];
                    if(foundationDonationItemList.size()>0){
                        for(OrderApi__Item__c itm:foundationDonationItemList){
                            itemVSprice.put(itm.Id,itm.OrderApi__Price__c);
                        }
                    }
                }
                if(!subscriptionIds.isEmpty()){
                    List<OrderApi__Subscription__c> subscriptionList =[select id from OrderApi__Subscription__c where OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c=true];
                    subscriptionIds.clear();
                    if(subscriptionList.size()>0)
                        subscriptionIds = (new Map<Id,OrderApi__Subscription__c>(subscriptionList)).keySet();
                }
                for(OrderApi__Sales_Order_Line__c currentSoli:newList){
                    if(currentSoli.OrderApi__Is_Renewal__c == true && currentSoli.OrderApi__Subscription__c!=Null && subscriptionIds.contains(soliVSsubscription.get(currentSoli.Id))){//If soli 'is Renewal' is checked for current SOLI, 'Subscription (Upgrade/Renew)' is not empty for current SOLI 
                        if(convenienceitemList.size()>0 && !existingConvenienceFeeSoli.contains(currentSoli.OrderApi__Sales_Order__c)){
                            OrderApi__Sales_Order_Line__c newSoli= createConvenienceFeeSoli(currentSoli.OrderApi__Sales_Order__c,convenienceitemList[0].Id,convenienceitemList[0].OrderApi__Price__c);
                            insertSalesOrderLineList.add(newSoli);
                            existingConvenienceFeeSoli.add(currentSoli.OrderApi__Sales_Order__c);
                        } 
                        if(!itemVSprice.isEmpty() && itemVSprice.containsKey(soliVSitem.get(currentSoli.Id))){
                            OrderApi__Sales_Order_Line__c newSoli= createFoundationDonationSoli(currentSoli.OrderApi__Sales_Order__c,currentSoli.OrderApi__Item__c,itemVSprice.get(soliVSitem.get(currentSoli.id)));
                            insertSalesOrderLineList.add(newSoli);
                        }
                    }
                }                
                if(insertSalesOrderLineList.size()>0){
                    insert insertSalesOrderLineList;
                }
            }
        }
    }
    public static OrderApi__Sales_Order_Line__c createConvenienceFeeSoli(Id SalesOrderId,Id itemId,Decimal itemPrice){
        OrderApi__Sales_Order_Line__c newSoli = new OrderApi__Sales_Order_Line__c();
        newSoli.OrderApi__Sales_Order__c= SalesOrderId;
        newSoli.OrderApi__Item__c= itemId;     
        //newSoli.OrderApi__Sale_Price__c= itemPrice;
        return newSoli;
    }
    public static OrderApi__Sales_Order_Line__c createFoundationDonationSoli(Id SalesOrderId,Id itemId,Decimal itemPrice){
        OrderApi__Sales_Order_Line__c newSoli = new OrderApi__Sales_Order_Line__c();
        newSoli.OrderApi__Sales_Order__c= SalesOrderId;
        newSoli.OrderApi__Item__c= itemId;       
       // newSoli.OrderApi__Sale_Price__c= itemPrice;
        newSoli.OrderApi__Price_Override__c=true;
        return newSoli;
    }
}