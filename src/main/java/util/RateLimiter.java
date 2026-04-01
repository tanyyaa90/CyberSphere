package util;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class RateLimiter {
    private static final int MAX_ATTEMPTS = 5;
    private static final long TIME_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
    
    private static Map<String, UserAttempts> attempts = new ConcurrentHashMap<>();
    
    public static boolean isAllowed(String emailOrPhone) {
        UserAttempts userAttempts = attempts.get(emailOrPhone);
        long now = System.currentTimeMillis();
        
        if (userAttempts == null) {
            attempts.put(emailOrPhone, new UserAttempts(1, now));
            return true;
        }
        
        if (now - userAttempts.timestamp > TIME_WINDOW_MS) {
            // Reset after time window
            attempts.put(emailOrPhone, new UserAttempts(1, now));
            return true;
        }
        
        if (userAttempts.count < MAX_ATTEMPTS) {
            userAttempts.count++;
            return true;
        }
        
        return false; // Rate limited
    }
    
    private static class UserAttempts {
        int count;
        long timestamp;
        
        UserAttempts(int count, long timestamp) {
            this.count = count;
            this.timestamp = timestamp;
        }
    }
}