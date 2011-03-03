component persistent="false" accessors="true" output="false" extends="BaseController" {
	
	property name="productService" type="any";
	
	public void function detail(required struct rc) {
		param name="rc.filename" default="";
		param name="rc.productID" default="";
		
		if(rc.productID != "") {
			rc.product = getProductService().getByID(rc.productID);
		} else if(rc.filename != "") {
			rc.product = getProductService().getByFilename(rc.filename);
		}
		if(isNull(rc.product)) {
			rc.product = getProductService().getNewEntity();
		}
		
		rc.$.slatwall.setCurrentProduct(rc.product);
		
		rc.$.content().setTitle(rc.product.getTitle());
		rc.$.content().setTemplate(rc.product.getTemplate());
		rc.$.content().setHTMLTitle(rc.product.getTitle());
	}
}