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
    
    public static List<Account> createAccounts(Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();

        for (Integer index = 1; index <= numberOfAccounts; index++) {
            accounts.add(buildAccount('Limit Test', '1111111111', 'true'));
        }
        INSERT accounts;
        
        return accounts;
    }
    
    public static Account getFirst() {
        return getAll()?.get(0);
    }

    public static List<Account> getAll() {
        return [SELECT Id,Name,Active__c,Phone,Website
            	FROM Account
                ORDER BY CreatedDate DESC];
    }
    
    public static List<Account> getAccountByName(String accountName){
        List<Account> accounts = new List<Account>();
        
        for(Account account: getAll()) {
            if(account.Name == accountName) {
                accounts.add(account);
            }
        }
        
        return accounts;
    }
    
    public static Account getAccountById(String accountId){
        for(Account account: getAll()) {
            if (account.Id == accountId) {
                return account;
            }
        }
        
        return null;
    }
    
}