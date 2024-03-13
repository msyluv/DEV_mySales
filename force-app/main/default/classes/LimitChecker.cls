public class LimitChecker {
    public static Boolean isLimitExceededBy95Percent() {
        
        Integer maxCpuTime = Limits.getLimitCpuTime();

        
        Integer currentCpuTime = Limits.getCpuTime();

        
        Double cpuUsagePercentage = (currentCpuTime / (maxCpuTime * 1.0)) * 100;

        
        if (cpuUsagePercentage > 100) {
            return true;
        }

        
        Integer maxHeapSize = Limits.getLimitHeapSize();

        
        Integer currentHeapSize = Limits.getHeapSize();

        
        Double heapUsagePercentage = (currentHeapSize / (maxHeapSize * 1.0)) * 100;

        
        if (heapUsagePercentage > 100) {
            return true;
        }

        
        return false;
    }
}