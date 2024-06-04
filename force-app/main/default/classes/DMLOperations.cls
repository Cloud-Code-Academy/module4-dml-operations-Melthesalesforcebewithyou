/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Melissa Villanueva Vasquez
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAccount = new Account();
        // Set some fields on the Account
        newAccount.Name = 'Sample Insert Account';
        newAccount.Rating = 'Hot';
        // Insert the Account into the database
        insert newAccount; 
        // Return the Id of the newly created Account
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAccount = new Account (Name = name, Industry = industry);
        // Insert the Account
        insert newAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.FirstName = 'Melissa';
        newContact.LastName = 'Vasquez';
        newContact.Email = 'Mel@cloudcodeacademy.com';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact contactToUpdate = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        // Update the Contact's last name
        contactToUpdate.LastName = newLastName;
        // Update the Contact in the database
        update contactToUpdate; 
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity oppToUpdate = [SELECT Id FROM Opportunity WHERE Id = :oppId];    
        // Update the Opportunity's stage
        oppToUpdate.StageName = newStage;
        // Update the Opportunity in the database
        update oppToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accToUpdate = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        accToUpdate.Name = newName; 
        accToUpdate.Industry = newIndustry;
        
        update accToUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (Opportunity opp : opportunities) {
            // Set the Opportunity's Stage to Qualification
            opp.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opp.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opp.Amount = 50000; 
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities; 
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        if (String.isBlank(accountName) || oppNames == null || oppNames.isEmpty()) {
            throw new IllegalArgumentException('Account name and opportunity names must be provided.');
        }
        
        //Check if the account exists
        Account account;
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
        
        if (accounts.isEmpty()) {
            //If the account does not exist, create it
            account = new Account(Name = accountName);
            insert account;
        } else {
            account = accounts[0];
        }
        
        //Get existing opportunities for the given names associated with the account
        Map<String, Opportunity> existingOppMap = new Map<String, Opportunity>();
        List<Opportunity> existingOpportunities = [
            SELECT Id, Name 
            FROM Opportunity 
            WHERE Name IN :oppNames AND AccountId = :account.Id
        ];
        for (Opportunity opp : existingOpportunities) {
            existingOppMap.put(opp.Name, opp);
        }

        //Insert or update opportunities
        List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();
        for (String oppName : oppNames) {
            if (existingOppMap.containsKey(oppName)) {
                // Update existing opportunity if needed
                Opportunity existingOpp = existingOppMap.get(oppName);
                // Add any field updates here if needed
                opportunitiesToUpsert.add(existingOpp);
            } else {
                // Create new opportunity
                Opportunity newOpp = new Opportunity(Name = oppName, AccountId = account.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
                opportunitiesToUpsert.add(newOpp);
            }
        }
        
        // Upsert opp
        upsert opportunitiesToUpsert;
    }

    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        //Initialize the Account variable
        Account account; 
		// if the Account exists, update the description
        if(!accounts.isEmpty()) {
            account = accounts[0];
            account.Description = 'Updated Account';
        }
		// otherwise, create a new Account and set the description
            else {
                account = new Account(Name = accountName, Description = 'New Account');
            }
		// Upsert the Account
		upsert account;
        return account; 
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        //Intialize a list to hold contacts to be upserted
        List <Contact> contactsToUpsertList = new List <Contact>();
		// Loop through each Contact
        for (Contact contact : contactsToUpsert) { 
            // Extract the Account Name from Contact's LastName
            String accountName = contact.LastName;
            // Get the account based on the name or create one if it doesn't exist
            Account account =  upsertAccount (accountName);
            // Link the Contact to its Account using the Account Id
            contact.AccountId = account.Id;
            //Add contact to the list to be upserted
            contactsToUpsertList.add(contact);
        }
        //Upsert the Contacts
        upsert contactsToUpsertList;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Initialize a list to hold Leads
        List<Lead> leadsToInsert = new List<Lead>();
        
        // Loop through each Lead name
        for (String leadName : leadNames) {
            // Create a new Lead object and set the LastName field
            Lead newLead = new Lead(LastName = leadName, Company = 'Cloud Code Company'); // Company is a required field
            leadsToInsert.add(newLead);
        }
        
        // Insert the Leads
        insert leadsToInsert;
        
        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        //Check parameters
        if (String.isBlank(accountId) || numOfCases == null || numOfCases <= 0) {
            // Handle invalid parameters gracefully
            return;
        }
        //Initialize list to hold Case records
        List <Case> casesToInsert = new List <Case>();

        //Loop to create cases
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(
                AccountId = accountId,
                Subject = 'Case ' + (i + 1),
                Status = 'New'
            );
            casesToInsert.add(newCase);
        }

        // Insert the cases
        insert casesToInsert;
        // Delete the cases
        delete casesToInsert;
    }
}