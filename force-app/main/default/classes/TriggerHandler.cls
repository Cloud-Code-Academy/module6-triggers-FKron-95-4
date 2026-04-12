public with sharing class TriggerHandler {

        public static void handleAccountInsert(List<Account> newAccounts){
            for(Account a : newAccounts){
                if(String.isBlank(a.Type)) {
                    a.Type = 'Prospect';
                }
                if(
                    !String.isBlank(a.ShippingStreet) ||
                    !String.isBlank(a.ShippingCity) ||
                    !String.isBlank(a.ShippingState) ||
                    !String.isBlank(a.ShippingPostalCode) ||
                    !String.isBlank(a.ShippingCountry)
                    ){
                    a.BillingStreet = a.ShippingStreet;
                    a.BillingCity = a.ShippingCity;
                    a.BillingState = a.ShippingState;
                    a.BillingPostalCode = a.ShippingPostalCode;
                    a.BillingCountry = a.ShippingCountry;
                    }
                    
                if(
                    !String.isBlank(a.Phone) &&
                    !String.isBlank(a.Website) &&
                    !String.isBlank(a.Fax)
                    ){
                        a.Rating = 'Hot';
                    }
            }
        }

        public static void handleAccountAfterInsert(List<Account> newAccounts){
            List<Contact> newContacts = new List<Contact>();
            for(Account a : newAccounts){
                newContacts.add(new Contact(
                    AccountId = a.Id,
                    LastName = 'DefaultContact',
                    Email = 'default@email.com'
                ));
            }

            if(!newContacts.isEmpty()){
                insert newContacts;
            }
        }


        public static void handleOpportunityBeforeUpdate(List<Opportunity> newOpps){
            for(Opportunity o : newOpps){
                if(o.amount != null && o.Amount <= 5000){
                    o.addError('Opportunity amount must be greater than 5000');
                }
            }
        }

        public static void handleOpportunityBeforeDelete(List<Opportunity> oldOpps){
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity o : oldOpps){
                if(o.AccountId != null){
                    accountIds.add(o.AccountId);
                }
            }

            Map<Id, Account> accountMap = new Map<Id, Account>(
                [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
            );

            for(Opportunity opp : oldOpps){
                Account acc = accountMap.get(opp.AccountId);

                if(
                    opp.StageName == 'Closed Won' &&
                    acc != null &&
                    acc.Industry == 'Banking'){
                        opp.addError('Cannot delete closed opportunity for a banking account that is won');
                    }                
            }
        }

        public static void handleOpportunityAfterUpdate(List<Opportunity> newOpps){
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : newOpps){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }
            List<Contact> contactList = [SELECT Id, Title, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO'];

            Map<Id,Contact> ceoByAccount = new Map<Id, Contact>();
            for(Contact con : contactList){
                ceoByAccount.put(con.AccountId, con);
            }

            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for(Opportunity opp : newOpps){
                Contact ceo = ceoByAccount.get(opp.AccountId);
                if(ceo != null  && opp.Primary_Contact__c != ceo.Id){
                    oppsToUpdate.add(new Opportunity(
                        Id = opp.Id,
                        Primary_Contact__c = ceo.Id
                    ));
                }
            }
            if(!oppsToUpdate.isEmpty()){
                    update oppsToUpdate;
                }
        }
}