public with sharing class INA_KnowledgeShareAttachment {

    public static void createKnowledgeShares(Id knowledgeId,List<Id> userOrGroupIds,String accessLevel,String rowCause) {
        if (knowledgeId == null || userOrGroupIds == null || userOrGroupIds.isEmpty()) {
            System.debug('Parâmetros inválidos.');
            return;
        }

        List<Knowledge__Share> sharesToInsert = new List<Knowledge__Share>();

        for (Id userOrGroupId : userOrGroupIds) {
            Knowledge__Share share = new Knowledge__Share(
                ParentId = knowledgeId,
                UserOrGroupId = userOrGroupId,
                AccessLevel = accessLevel,
                RowCause = rowCause
            );
            sharesToInsert.add(share);
        }

        if (!sharesToInsert.isEmpty()) {
            try {
                insert sharesToInsert;
                System.debug('Compartilhamentos criados com sucesso: ' + sharesToInsert.size());
            } catch (Exception e) {
                System.debug('Erro ao criar compartilhamentos: ' + e.getMessage());
                return;
            }
        }
    }
}
