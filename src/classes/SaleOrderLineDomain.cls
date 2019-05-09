/**
 *
 * Domain class for the SaleOrderLine SObjectType
 *
 **/

global class SaleOrderLineDomain extends Framework.Domain{
    public SaleOrderLineDomain(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new SaleOrderLineDomain(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(SaleOrderLineDomain.class.getName(),'beforeInsert'); 
        SaleOrderLineService.createSaleOrderLine((OrderApi__Sales_Order_Line__c[]) records); 
        Framework.Log.pop();
    }
}