/**
 * Cielo
 * Todos os direitos reservados
 * ----------
 * @author Renata Cavalcanti @ Accenture
 * @date 04/03/2025
 * @description Classe que permite associar um artigo a um case.
 */
public with sharing class INA_CaseArticleAttachment {
    // This method attaches an article to a case
    // Parameters:
    // - caseId: The Id of the case to which the article will be attached
    // - articleId: The Id of the article to be attached to the case
    @InvocableMethod
    public static List<CaseArticleAttachmentResponse>  attachArticleToCase(List<CaseArticleAttachmentRequest> requests) {
        List<CaseArticleAttachmentResponse> responses = new List<CaseArticleAttachmentResponse>();

        CaseArticleAttachmentResponse response = new CaseArticleAttachmentResponse();
        CaseArticleAttachmentRequest request = null;

        if (requests != null){
            request = requests[0];

            try {
                // Execute the SOQL query
                Knowledge__kav article = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :request.articleId LIMIT 1];
                Case case1 = [SELECT ID FROM Case WHERE CaseNumber = :request.caseNumber LIMIT 1];
    
                // Create a new CaseArticle record to link the case and the article
                CaseArticle caseArticle = new CaseArticle();
                caseArticle.CaseId = case1.Id;
                caseArticle.KnowledgeArticleId = article.KnowledgeArticleId;
    
                // Insert the CaseArticle record
                insert caseArticle;
                System.debug('Article successfully attached to the case.');
                response.message = 'O artigo foi associado ao caso com sucesso.';
            } catch (Exception e) {
                // Handle any other exceptions
                System.debug('Exception: ' + e.getMessage());
                response.message = 'Infelizmente não foi possível associar o artigo ao caso. Posso ajudar com mais alguma coisa?';
            }    
        }  else {
                // Handle any other exceptions
                System.debug('Request null');
                response.message = 'Infelizmente não foi possível associar o artigo ao caso. Posso ajudar com mais alguma coisa?';            
        }      

        responses.add(response);
        
        return responses;
    }

    // Define a class to hold the request parameters
    public class CaseArticleAttachmentRequest {
        @InvocableVariable(label='Case Number' description='The CaseNumber of the case' required=true)
        public String caseNumber;

        @InvocableVariable(label='Article ID' description='The ID of the article' required=true)
        public Id articleId;
    }

    // Wrapper class for invocable method results
    public class CaseArticleAttachmentResponse {
        @InvocableVariable
        public String message;
    }    
}