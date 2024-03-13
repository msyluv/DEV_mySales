public class ApiResponseParser {
    // Class to represent the JSON structure of records in the API response
    public class ApiResponseRecord {
        public Map<String, Object> record;
        public Map<String, Object> group1;
    }

    // Method to parse the API response and generate a dynamic HTML table
    public static String parseApiResponse(String apiResponse) {
        // Deserialize the JSON response into a list of ApiResponseRecord objects
        List<ApiResponseRecord> recordsWithGroup = (List<ApiResponseRecord>) JSON.deserialize(apiResponse, List<ApiResponseRecord>.class);

        // Start building the HTML table
        String htmlTable = '<table border=\'1\'>';

        // Check if the response has records
        if (recordsWithGroup != null && !recordsWithGroup.isEmpty()) {
            // Get field names from the first record to use as table headers
            Set<String> fieldNames = recordsWithGroup[0].record.keySet();

            // Add headers
            htmlTable += '<tr>';
            for (String fieldName : fieldNames) {
                htmlTable += '<th>' + fieldName + '</th>';
            }
            htmlTable += '</tr>';

            // Add data rows
            for (ApiResponseRecord recordWithGroup : recordsWithGroup) {
                htmlTable += '<tr>';
                if (recordWithGroup.record != null) {
                    for (String fieldName : fieldNames) {
                        htmlTable += '<td>' + formatCellValue(recordWithGroup.record.get(fieldName)) + '</td>';
                    }
                }
                htmlTable += '</tr>';

                // Check for groupings and add grouping rows
                if (recordWithGroup.group1 != null && !recordWithGroup.group1.isEmpty()) {
                    for (String groupName : recordWithGroup.group1.keySet()) {
                        htmlTable += '<tr><td colspan=\'' + fieldNames.size() + '\'><strong>' + groupName + '</strong></td></tr>';
                        htmlTable += '<tr><td colspan=\'' + fieldNames.size() + '\'>' + formatCellValue(recordWithGroup.group1.get(groupName)) + '</td></tr>';
                    }
                }
            }
        } else {
            // If no records, add an empty row with a message
            htmlTable += '<tr><td colspan=\'999\'>No data available</td></tr>';
        }

        // Close the table and return the HTML
        htmlTable += '</table>';
        return htmlTable;
    }

    // Helper method to format cell values (handle null values, etc.)
    private static String formatCellValue(Object cellValue) {
        if (cellValue == null) {
            return '';
        } else if (cellValue instanceof Date) {
            return String.valueOf((Date) cellValue);
        } else if (cellValue instanceof DateTime) {
            return String.valueOf((DateTime) cellValue);
        } else if (cellValue instanceof Time) {
            return String.valueOf((Time) cellValue);
        } else {
            return String.valueOf(cellValue);
        }
    }
}