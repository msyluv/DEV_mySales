public class JSONUtilsForReportData {
    public static Integer getNumberOfGroupingLevels(List<Object> jsonData) {
        Integer maxLevels = 0;
        for (Object item : jsonData) {
            Integer levels = countGroupingLevels((Map<String, Object>)item, 0);
            if (levels > maxLevels) {
                maxLevels = levels;
            }
        }
        return maxLevels;
    }

    private static Integer countGroupingLevels(Map<String, Object> item, Integer currentLevel) {
        Integer maxLevels = currentLevel;
        if (item.containsKey('groupings') && item.get('groupings') instanceof List<Object>) {
            List<Object> groupings = (List<Object>)item.get('groupings');
            for (Object grouping : groupings) {
                Integer levels = countGroupingLevels((Map<String, Object>)grouping, currentLevel + 1);
                if (levels > maxLevels) {
                    maxLevels = levels;
                }
            }
        }
        return maxLevels;
    }
}