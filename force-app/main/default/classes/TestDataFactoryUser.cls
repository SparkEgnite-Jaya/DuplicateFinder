public class TestDataFactoryUser {
    
    public static User createUser(Id profileId) {
        User user = buildUser(profileId);
        insert user;
        
        return user;
    }

    public static User buildUser(Id profileId){
        User adminUser = new User(
            Alias = 'tadmin',
            Email = 'testadmin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testadmin' + System.currentTimeMillis() + '@example.com'
        );
        
        return adminUser;
    }
    
    public static User getUserByProfileName(String profileName){
        return [SELECT Id, Name FROM User
                WHERE Profile.Name =: profileName LIMIT 1];
    }

    public static Profile getProfileByName(String name) {
        return [SELECT Id, Name, UserType FROM Profile WHERE Name =: name];
    }

}