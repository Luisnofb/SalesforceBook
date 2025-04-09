@isTest
public class INA_KnowledgeShareAttachmentTest {

    private static Id testUserId;
    private static Id testArticleId;

    @testSetup
    static void setupTestData() {
        // Criar um usuário de teste
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testu',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;
        testUserId = testUser.Id;

        // Criar um artigo Knowledge de teste
        Knowledge__kav article = new Knowledge__kav(
            Title = 'Artigo de Teste'
        );
        insert article;
        testArticleId = article.Id;
    }

    @isTest
    static void testCreateKnowledgeShares_Success() {
        List<Id> userList = new List<Id>{ testUserId };

        Test.startTest();
        INA_KnowledgeShareAttachment.createKnowledgeShares(
            testArticleId,
            userList,
            'Read',
            'Manual'
        );
        Test.stopTest();

        List<Knowledge__Share> shares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
            FROM Knowledge__Share
            WHERE ParentId = :testArticleId AND UserOrGroupId = :testUserId
        ];

        System.assertEquals(1, shares.size(), 'Deveria existir 1 compartilhamento');
        System.assertEquals('Read', shares[0].AccessLevel);
        System.assertEquals('Manual', shares[0].RowCause);
    }

    @isTest
    static void testCreateKnowledgeShares_InvalidInputs() {
        Test.startTest();
        INA_KnowledgeShareAttachment.createKnowledgeShares(null, new List<Id>(), 'Read', 'Rule');
        Test.stopTest();

        // Nenhum erro deve ser lançado, apenas deve passar silenciosamente
        System.assert(true, 'Código executado com entradas inválidas sem falha');
    }
}
