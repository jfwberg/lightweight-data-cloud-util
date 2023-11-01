/**
 * Run 1 by 1 to prevent govenor limits
 */
insertAccounts();
insertContacts();
insertOpportunities();

public void insertAccounts(){
    
    Account[] accounts = new Account[]{};

    for (Integer i = 0; i < 4; i++) {
    
        // A postfix to keep track of what item we're dealing with
        String postfix = String.valueOf(i+1).leftPad(4,'0');
        
        // Create a new account
        accounts.add(new Account(
            Name = 'Demo Account - ' + postfix
        ));
    }

    insert accounts;
}


public void insertContacts(){
    Account[] accounts = [SELECT Id FROM Account WHERE Name LIKE 'Demo Account - %' ORDER BY Name ASC LIMIT 10];
    Contact[] contacts = new Contact[]{};


    for(integer i=0, max=accounts.size(); i<max; i++){
        for(integer j=1; j< 4; j++){
        
            // Postfix to keep track of where we are
            String postfix = String.valueOf(i+1).leftPad(4,'0') + ' - ' + String.valueOf(j).leftPad(2,'0');
            
            contacts.add(new Contact(
                AccountId= accounts[i].Id,
                FirstName= 'Demo',
                LastName = 'Contact - ' + postfix
            ));

            
        }
    }
    insert contacts;
}


public void insertOpportunities(){
    Account[] accounts = [SELECT Id FROM Account WHERE Name LIKE 'Demo Account - %' ORDER BY Name ASC LIMIT 10];
    Opportunity[] opportunities = new Opportunity[]{};

    for(integer i=0, max=accounts.size(); i<max; i++){
        for(integer j=1; j< 4; j++){
        
            // Postfix to keep track of where we are
            String postfix = String.valueOf(i+1).leftPad(4,'0') + ' - ' + String.valueOf(j).leftPad(2,'0');
            
            opportunities.add(new Opportunity(
                AccountId= accounts[i].Id,
                Name = 'Opportunity - ' + postfix,
                StageName = 'New',
                CloseDate = Date.today().addDays(i)
            ));
        }
    }
    insert opportunities;
}
