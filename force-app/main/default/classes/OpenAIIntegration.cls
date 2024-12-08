public with sharing class OpenAIIntegration {
    @AuraEnabled
    public static String getChatbotResponse(String prompt) {
        // Endpoint for OpenAI
        String endpoint = 'https://api.openai.com/v1/chat/completions';

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Set HTTP request properties
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + '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');
        request.setHeader('Content-Type', 'application/json');

        // Construct the OpenAI request body for chat completions
        Map<String, Object> requestBody = new Map<String, Object>{
            'model' => 'gpt-3.5-turbo',
            'messages' => new List<Map<String, String>>{
                new Map<String, String>{
                    'role' => 'user',
                    'content' => prompt
                }
            },
            'max_tokens' => 150,
            'temperature' => 0.7
        };
        request.setBody(JSON.serialize(requestBody));

        // Make the API call
        try {
            HttpResponse response = http.send(request);
            System.debug('Response Status Code: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());

            if (response.getStatusCode() == 200) {
                // Parse the response for chat completions
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> choices = (List<Object>) responseMap.get('choices');
                if (!choices.isEmpty()) {
                    Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                    return (String) message.get('content');
                }
            }
            return 'No meaningful response from OpenAI.';
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
}