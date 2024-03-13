public class ImageController {
    // Remote action method to fetch the image content
    @RemoteAction
    public static Map<String, Object> getImageContent() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            String imageUrl = 'https://sdssfa--qa.sandbox.my.salesforce.com/analytics/download/lightning-dashboard/01Z1s0000000GC7EAM.png?sdtd=1';

            HttpRequest request = new HttpRequest();
            request.setEndpoint(imageUrl);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                Blob imageContent = response.getBodyAsBlob();
                String base64Image = EncodingUtil.base64Encode(imageContent);
                system.debug('base64-->' + base64Image);
                result.put('success', true);
                result.put('content', base64Image);
            } else {
                result.put('success', false);
                result.put('error', 'Failed to fetch the image. Status Code: ' + response.getStatusCode() + ', Message: ' + response.getStatus());
            }
        } catch (Exception ex) {
            result.put('success', false);
            result.put('error', 'An exception occurred: ' + ex.getMessage());
        }
        return result;
    }
}