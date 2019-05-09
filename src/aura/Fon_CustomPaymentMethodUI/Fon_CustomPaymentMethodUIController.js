({
	doInit : function(cmp, event, helper) {
		helper.loadData(cmp, event, helper);
        var urlString = window.location.href;
        var retURL = urlString.substring(urlString.indexOf("retURL=")+7);
        cmp.set('v.returnURL', retURL);
        
	},
    handleClick: function (cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": cmp.get("v.returnURL")
        });
        urlEvent.fire();
        //window.open('https://www.google.com','_top')
    }
})