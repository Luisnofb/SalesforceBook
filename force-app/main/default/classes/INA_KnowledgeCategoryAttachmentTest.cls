@isTest
public class INA_KnowledgeCategoryAttachmentTest {

    @testSetup
    static void setupTestData() {
        // Criar um Data Category Group de teste
        DataCategoryGroupCustom__dlm categoryGroup = new DataCategoryGroupCustom__dlm(
            DeveloperName__c = 'Financeiro', 
            Id__c = 'DCG001'
        );
        insert categoryGroup;

        // Criar Data Categories dentro do grupo
        DataCategoryCustom__dlm category1 = new DataCategoryCustom__dlm(
            DeveloperName__c = 'Adequar_Aluguel',
            DataCategoryGroupId__c = categoryGroup.Id__c
        );
        DataCategoryCustom__dlm category2 = new DataCategoryCustom__dlm(
            DeveloperName__c = 'Orçamento',
            DataCategoryGroupId__c = categoryGroup.Id__c
        );
        insert new List<DataCategoryCustom__dlm>{ category1, category2 };

        // Criar um artigo Knowledge de teste
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Teste de Artigo'
        );
        insert testArticle;
    }

    @isTest
    static void testGeneratorMethod() {
        Test.startTest();
        // Executa o método generator()
        Map<String, List<String>> categoryHierarchy = INA_KnowledgeCategoryAttachment.generator();
        Test.stopTest();

        // Valida se a estrutura foi criada corretamente
        System.assertNotEquals(null, categoryHierarchy, 'O mapa de categorias não deveria estar nulo');
        System.assertNotEquals(0, categoryHierarchy.size(), 'O mapa de categorias não deveria estar vazio');
        System.debug('Resultado do generator(): ' + categoryHierarchy);
    }

    @isTest
    static void testAssignCategoriesToArticle_Success() {
        // Buscar um artigo Knowledge real
        Knowledge__kav testArticle = [SELECT Id, Title FROM Knowledge__kav LIMIT 1];

        // Lista de categorias a atribuir
        List<String> categoriesToAssign = new List<String>{ 'Adequar_Aluguel', 'Franquias' };

        Test.startTest();
        INA_KnowledgeCategoryAttachment.assignCategoriesToArticle(testArticle.Id, categoriesToAssign);
        Test.stopTest();

        // Verificar se as categorias foram atribuídas corretamente
        List<Knowledge__DataCategorySelection> selections = [
            SELECT ParentId, DataCategoryGroupName, DataCategoryName 
            FROM Knowledge__DataCategorySelection 
            WHERE ParentId = :testArticle.Id
        ];
        
        System.assertNotEquals(0, selections.size(), 'O artigo deveria ter pelo menos 1 categoria atribuída');
        System.debug('Categorias atribuídas: ' + selections);
    }

}
