@IsTest
public with sharing class TestDataFactoryAccount {
    
    public static Account createAccount() {
        Account account = buildAccount();
        insert account;
        
        return account;
    }

    public static Account buildAccount(){
        Account account = new Account();
        account.Name = 'testAccount';
        account.Phone = '1111111111';
        account.Active__c = 'true';
        
        return account;
    }
    
    public static Account buildAccount(String accountName,String accountPhone,String accountActive){
        Account account = new Account();
        account.Name = accountName;
        account.Phone = accountPhone;
        account.Active__c = accountActive;
        
        return account;
    }
    
    public static Account buildAccount(String accountName, String accountPhone, String accountActive, String website) {
        Account account = buildAccount(accountName, accountPhone, accountActive);
        account.Website = website;
        
        return account;
    }

    public static Account getFirst() {
        return getAll()?.get(0);
    }

    public static List<Account> getAll() {
        return [SELECT Id,Name,Active__c,Phone,Website
            	FROM Account
                ORDER BY CreatedDate ASC];
    }
    
    public static List<Account> getAccountByName(String accountName){
        return [SELECT Id,Name,Active__c,Phone,Website
                FROM Account
                WHERE Name =: accountName];
    }
    
    public static Account getAccountById(String accountId){
        return [SELECT Id,Name,Active__c,Phone,Website
                FROM Account
                WHERE Id =: accountId];
    }
    
}