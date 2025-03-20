public with sharing class INA_KnowledgeCategoryAttachment {
    
    public static Map<String, List<String>> generator() {
        List<DataCategoryGroupCustom__dlm> dcgList = [SELECT DeveloperName__c, Id, Id__c 
                                                      FROM DataCategoryGroupCustom__dlm];
        List<DataCategoryCustom__dlm> dcList = [SELECT Id, DataCategoryGroupId__c, DeveloperName__c 
                                                FROM DataCategoryCustom__dlm];

        Map<String, List<String>> categoryHierarchy = new Map<String, List<String>>();

        for (DataCategoryGroupCustom__dlm dcg : dcgList) {
            if (!categoryHierarchy.containsKey(dcg.DeveloperName__c)) {
                categoryHierarchy.put(dcg.DeveloperName__c, new List<String>());
            }
            for (DataCategoryCustom__dlm dc : dcList) {
                if (dc.DataCategoryGroupId__c == dcg.Id__c) {
                    categoryHierarchy.get(dcg.DeveloperName__c).add(dc.DeveloperName__c);
                }
            }
        }

        System.debug('Data Category Hierarchy: ' + categoryHierarchy);
        return categoryHierarchy;
    }

    public static void assignCategoriesToArticle(Id knowledgeId, List<String> selectedCategories) {
        if (knowledgeId == null || selectedCategories == null || selectedCategories.isEmpty()) {
            System.debug('Erro: ID do artigo ou lista de categorias está vazio.');
            return;
        }

        
        Map<String, List<String>> categoryHierarchy = generator();

        Knowledge__kav know = [SELECT Id, Title FROM Knowledge__kav WHERE Id = :knowledgeId LIMIT 1];
        
        if (know == null) {
            System.debug('Erro: Artigo Knowledge não encontrado.');
            return;
        }

        List<Knowledge__DataCategorySelection> categoryAssignments = new List<Knowledge__DataCategorySelection>();

        for (String categoryName : selectedCategories) {
            for (String groupName : categoryHierarchy.keySet()) {
                if (categoryHierarchy.get(groupName).contains(categoryName)) {
                    Knowledge__DataCategorySelection kds = new Knowledge__DataCategorySelection(
                        ParentId = know.Id,
                        DataCategoryGroupName = groupName,
                        DataCategoryName = categoryName
                    );
                    categoryAssignments.add(kds);
                    System.debug('Categoria atribuída: ' + categoryName + ' no grupo ' + groupName);
                }
            }
        }

        if (!categoryAssignments.isEmpty()) {
            insert categoryAssignments;
            System.debug('Categorias atribuídas com sucesso ao artigo ' + know.Title);
        } else {
            System.debug('Nenhuma categoria válida encontrada para atribuir ao artigo.');
        }
    }
}
