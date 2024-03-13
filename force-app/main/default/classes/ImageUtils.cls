public class ImageUtils {
    //sample non salesforce url from google --> https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg
    //it is similar to our url we hit --> https://sdssfa--qa.sandbox.lightning.force.com/analytics/download/lightning-dashboard/01Z1s0000000GEDEA2.png
    public static String convertImageToBase64(String imageUrl) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(imageUrl);
        request.setHeader('Authorization', 'Bearer ' + Userinfo.getSessionId());
        request.setMethod('GET');
        
        HttpResponse response = new Http().send(request);
      
            Blob imageBlob = response.getBodyAsBlob();
            system.debug('response-->' + EncodingUtil.base64Encode(imageBlob));
            return EncodingUtil.base64Encode(imageBlob);
      
        }
    
}