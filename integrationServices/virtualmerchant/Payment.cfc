/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/

component accessors="true" output="false" displayname="VirtualMerchant" implements="Slatwall.integrationServices.PaymentInterface" extends="Slatwall.integrationServices.BasePayment" {
	
	// Custom Properties that need to be set by the end user
	property name="merchantID" displayname="Merchant ID" type="string";
	property name="userID" displayname="Virtual Merchant User ID" type="string";
	property name="pin" displayname="Virtual Merchant PIN" type="string";
	property name="liveModeFlag" displayname="Live Mode" type="boolean";
	
	//Global variables
	variables.liveGatewayAddress = "https://www.myvirtualmerchant.com/VirtualMerchant/process.do";
	variables.testGatewayAddress = "https://demo.myvirtualmerchant.com/VirtualMerchantDemo/process.do";
	variables.transactionCodes = {};

	public any function init(){
		// Set Defaults
		setMerchantID("");
		setUserID("");
		setPin("");
		setLiveModeFlag(false);
		
		variables.transactionCodes = {
			authorize="ccauthonly",
			authorizeAndCharge="ccsale",
			chargePreAuthorization="ccforce",
			credit="cccredit",
			void="ccvoid",
			inquiry=""
		};
		
		return this;
	}
	
	public any function getPaymentMethods() {
		return "creditCard";
	}
	
	public Slatwall.com.utility.payment.CreditCardTransactionResponseBean function processCreditCard(required Slatwall.com.utility.payment.CreditCardTransactionRequestBean requestBean){
		
		var requestData = getRequestData(requestBean);
		var rawResponse = postRequest(requestData, requestBean.getTransactionID());
		
		return getResponseBean(rawResponse, requestData, requestBean);
		
	}
	
	private string function getRequestData(required any requestBean){
		
		var requestData = "";
		requestData = "ssl_transaction_type=#variables.transactionCodes[arguments.requestBean.getTransactionType()]#&ssl_show_form=false";
		requestData = listAppend(requestData,getLoginNVP(),"&");
		requestData = listAppend(requestData,getPaymentNVP(requestBean),"&");
		if(variables.transactionCodes[arguments.requestBean.getTransactionType()] == "C" || variables.transactionCodes[arguments.requestBean.getTransactionType()] == "D"){
			requestData = listAppend(requestData,"ORIGID=#requestBean.getProviderTransactionID()#","&");
		}
		
		return requestData;
		
	}

	private string function getLoginNVP(){
		
		var loginData = [];
		arrayAppend(loginData,"ssl_merchant_id=#getMerchantID()#");
		arrayAppend(loginData,"ssl_user_id=#getUserID()#");
		arrayAppend(loginData,"ssl_pin=#getPin()#");
		
		return arrayToList(loginData,"&");
	}
	
	private string function getPaymentNVP(required any requestBean){
		
		var paymentData = [];
		arrayAppend(paymentData,"ssl_card_number=#requestBean.getCreditCardNumber()#");
		arrayAppend(paymentData,"ssl_card_present=N");
		arrayAppend(paymentData,"ssl_exp_date=#Left(requestBean.getExpirationMonth(),2)##Right(requestBean.getExpirationYear(),2)#");
		return arrayToList(paymentData,"&");
		
	}
	
	private any function postRequest(required string requestData, required string requestID){
		
		var httpRequest = new http();
		httpRequest.setMethod("POST");
		httpRequest.setUrl(getGatewayAddress());
		httpRequest.setPort(443);
		httpRequest.setTimeout(45);
		httpRequest.setResolveurl(false);
		
		httpRequest.addParam(type="header",name="Content-Type",VALUE="text/namevalue");
		httpRequest.addParam(type="header",name="Content-Length",VALUE="#Len(requestData)#");
		httpRequest.addParam(type="body",value="#requestData#");
		
		return httpRequest.send().getPrefix();
	}
	
	private string function getGatewayAddress(){
		if(getLiveModeFlag()){
			return variables.liveGatewayAddress;
		} else {
			return variables.testGatewayAddress;
		}
	}
	
	private any function getResponseBean(required struct rawResponse, required any requestData, required any requestBean){
		
		var response = new Slatwall.com.utility.payment.CreditCardTransactionResponseBean();
		
		var responseDataArray = listToArray(rawResponse.fileContent,"&");
		var responseData = {};
		
		for(var item in responseDataArray){
			responseData[listFirst(item,"=")] = listRest(item,"=");
		}
		
		// Populate the data with the raw response & request
		var data = {
			responseData = arguments.rawResponse,
			requestData = arguments.requestData
		};
		response.setData(data);
		
		// Add message for what happened
		response.addMessage(responseData["ssl_result"], responseData["ssl_result_message"]);
		
		// Set the status Code
		response.setStatusCode(responseData["ssl_result"]);
		
		// Check to see if it was successful
		if(responseData["ssl_result"] != 0) {
			// Transaction did not go through
			response.addError(responseData["errorCode"], responseData["errorMessage"]);
		} else {
			if(requestBean.getTransactionType() == "authorize") {
				response.setAmountAuthorized(requestBean.getTransactionAmount());
			} else if(requestBean.getTransactionType() == "authorizeAndCharge") {
				response.setAmountAuthorized(requestBean.getTransactionAmount());
				response.setAmountCharged(requestBean.getTransactionAmount());
			} else if(requestBean.getTransactionType() == "chargePreAuthorization") {
				response.setAmountCharged(requestBean.getTransactionAmount());
			} else if(requestBean.getTransactionType() == "credit") {
				response.setAmountCredited(requestBean.getTransactionAmount());
			}
		}
		
		response.setTransactionID(responseData["ssl_txn_id"]);
		response.setAuthorizationCode(responseData["ssl_approval_code"]);
		response.setAVSCode( responseData["ssl_avs_response"] );
		
		if(responseData["ssl_cvv2_response"] == 'M') {
			response.setSecurityCodeMatch(true);
		} else {
			response.setSecurityCodeMatch(false);
		}
		
		return response;
	}
	
}