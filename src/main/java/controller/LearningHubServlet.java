package controller;

import model.ContentLearning;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.sql.*;

@WebServlet("/learningHub")
public class LearningHubServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    
    private static final String ARTICLE_THUMBNAIL = "images/article.webp";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = null;
        if (session != null) {
            userId = (Integer) session.getAttribute("userId");
        }

        List<ContentLearning> list = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            stmt = conn.createStatement();
            
            rs = stmt.executeQuery("SELECT * FROM learning_content ORDER BY topic, id");
            
            while (rs.next()) {
                String type = rs.getString("type");
                String title = rs.getString("title");
                String topic = rs.getString("topic");
                String url = rs.getString("url");
                String thumbnail = rs.getString("thumbnail_url");
                
                if (topic == null || topic.trim().isEmpty()) {
                    continue;
                }
                
                // Fix YouTube URLs for videos
                if ("video".equals(type) && url != null) {
                    url = fixYouTubeUrl(url);
                }
                
                String displayTitle = title;
                if (displayTitle == null || displayTitle.isEmpty()) {
                    if ("video".equals(type)) {
                        displayTitle = topic + " - Video Tutorial";
                    } else if ("article".equals(type)) {
                        displayTitle = topic + " - Article";
                    } else if ("image".equals(type)) {
                        displayTitle = topic + " - Infographic";
                    }
                }
                
                // Generate thumbnail
                if ("video".equals(type)) {
                    if (thumbnail == null || thumbnail.isEmpty()) {
                        String videoId = extractYouTubeId(url);
                        if (!videoId.isEmpty()) {
                            thumbnail = "https://img.youtube.com/vi/" + videoId + "/0.jpg";
                        } else {
                            thumbnail = "https://via.placeholder.com/320x180/1a1e24/44634d?text=Video";
                        }
                    }
                } else if ("article".equals(type)) {
                    thumbnail = ARTICLE_THUMBNAIL;
                } else if ("image".equals(type)) {
                    if (thumbnail == null || thumbnail.isEmpty()) {
                        thumbnail = url;
                    }
                }
                
                ContentLearning content = new ContentLearning(
                    displayTitle,
                    type,
                    url,
                    thumbnail,
                    topic
                );
                
                list.add(content);
                
                if (userId != null) {
                    trackContentView(userId, content, request);
                }
            }
            
            System.out.println("✅ Loaded " + list.size() + " content items from database");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ Error loading content: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        
        if (list.isEmpty()) {
            System.out.println("⚠️ No content in database, using fallback content");
            addFallbackContent(list);
        }

        Map<String, List<ContentLearning>> groupedContent = new TreeMap<>();
        
        for (ContentLearning content : list) {
            String category = content.getCategory();
            List<ContentLearning> categoryList = groupedContent.get(category);
            if (categoryList == null) {
                categoryList = new ArrayList<>();
                groupedContent.put(category, categoryList);
            }
            categoryList.add(content);
        }

        int videoCount = 0, articleCount = 0, imageCount = 0;
        for (ContentLearning content : list) {
            String type = content.getType();
            if ("video".equals(type)) videoCount++;
            else if ("article".equals(type)) articleCount++;
            else if ("image".equals(type)) imageCount++;
        }

        request.setAttribute("groupedContent", groupedContent);
        request.setAttribute("totalCount", list.size());
        request.setAttribute("videoCount", videoCount);
        request.setAttribute("articleCount", articleCount);
        request.setAttribute("imageCount", imageCount);
        
        request.getRequestDispatcher("learningHub.jsp").forward(request, response);
    }
    
    // Fix YouTube URL to embed format
    private String fixYouTubeUrl(String url) {
        if (url == null) return null;
        
        // Already embed format
        if (url.contains("/embed/")) {
            return url;
        }
        
        // Convert watch?v= format
        if (url.contains("youtube.com/watch?v=")) {
            return url.replace("watch?v=", "embed/");
        }
        
        // Convert youtu.be format
        if (url.contains("youtu.be/")) {
            String videoId = url.substring(url.lastIndexOf("/") + 1);
            if (videoId.contains("?")) {
                videoId = videoId.substring(0, videoId.indexOf("?"));
            }
            return "https://www.youtube.com/embed/" + videoId;
        }
        
        return url;
    }
    
    // Extract YouTube video ID from URL
    private String extractYouTubeId(String url) {
        if (url == null) return "";
        
        if (url.contains("/embed/")) {
            String id = url.substring(url.lastIndexOf("/") + 1);
            if (id.contains("?")) {
                id = id.substring(0, id.indexOf("?"));
            }
            return id;
        }
        
        if (url.contains("youtube.com/watch?v=")) {
            String id = url.substring(url.indexOf("v=") + 2);
            if (id.contains("&")) {
                id = id.substring(0, id.indexOf("&"));
            }
            return id;
        }
        
        if (url.contains("youtu.be/")) {
            String id = url.substring(url.lastIndexOf("/") + 1);
            if (id.contains("?")) {
                id = id.substring(0, id.indexOf("?"));
            }
            return id;
        }
        
        return "";
    }
    
    private void trackContentView(int userId, ContentLearning content, HttpServletRequest request) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String viewSql = "INSERT INTO content_views (user_id, content_id, content_type, content_title, viewed_at) " +
                             "VALUES (?, ?, ?, ?, NOW())";
            ps = conn.prepareStatement(viewSql);
            
            int contentId = Math.abs(content.getTitle().hashCode() % 10000);
            
            ps.setInt(1, userId);
            ps.setInt(2, contentId);
            ps.setString(3, content.getType());
            ps.setString(4, content.getTitle());
            
            ps.executeUpdate();
            
        } catch (Exception e) {
            System.out.println("⚠️ Could not track content view: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void addFallbackContent(List<ContentLearning> list) {
        // Videos with proper embed URLs
        addVideo(list, "Phishing Attacks Explained", "n9Lff-cSxLQ", "Phishing Emails");
        addVideo(list, "What is Phishing?", "XBkzBrXlle0", "Phishing Emails");
        addVideo(list, "Security Dangers of Public Wi-Fi", "XcghUy-8VRA", "Public WiFi Risks");
        addVideo(list, "What is Credential Stuffing?", "kVa7exobAFA", "Credential Stuffing");
        addVideo(list, "OTP Scam Awareness", "UX2FC4d7liw", "OTP Scams");
        addVideo(list, "Safe Browsing Habits", "xa7qaSJeyRQ", "Safe Browsing");
        addVideo(list, "How Hackers Attack on Public Wi-Fi", "mqZzXUzxUYM", "Public WiFi Risks");
        addVideo(list, "What is Firewall?", "9GZlVOafYTg", "Firewall");
        addVideo(list, "VPN Explained", "R-JUOpCgTZc", "VPN");
        addVideo(list, "What is Malware?", "NMYbkzjI5EY", "Malware");
        addVideo(list, "What is Cryptography", "jhXCTbFnK8o", "Cryptography");
        addVideo(list, "Software Updates Importance", "o1WsviOK9fE", "Software Updates");
        
        // Articles with article.webp thumbnail
        addArticle(list, "How to Recognize & Avoid Phishing Scams",
                  "https://consumer.ftc.gov/articles/how-recognize-avoid-phishing-scams",
                  "Phishing Awareness");
        
        addArticle(list, "10 Tips to Browse Internet Safely",
                  "https://swisscyberinstitute.com/blog/10-tips-browse-internet-safely/",
                  "Safe Browsing");
        
        addArticle(list, "Understanding Patches & Software Updates",
                  "https://www.bu.edu/tech/support/information-security/security-for-everyone/understanding-patches-and-software-updates/",
                  "Software Security");
        
        addArticle(list, "What is a Firewall?",
                  "https://www.fortinet.com/resources/cyberglossary/firewall",
                  "Network Security");
        
        addArticle(list, "Are VPNs Safe?",
                  "https://www.fortinet.com/resources/cyberglossary/are-vpns-safe",
                  "Privacy & VPN");
        
        // Images/Infographics
        addImage(list, "5 Red Flags to Identify Phishing Emails",
                 "https://www.fortinet.com/content/dam/fortinet/images/cyberglossary/5-red-flags-to-identify-phishing-emails.png",
                 "Phishing Awareness");
        
        addImage(list, "Password Strength Checklist",
                 "https://images.pexels.com/photos/60504/security-protection-anti-virus-software-60504.jpeg",
                 "Password Security");
    }
    
    private void addVideo(List<ContentLearning> list, String title, String videoId, String category) {
        list.add(new ContentLearning(
            title, 
            "video", 
            "https://www.youtube.com/embed/" + videoId,
            "https://img.youtube.com/vi/" + videoId + "/0.jpg", 
            category
        ));
    }
    
    private void addArticle(List<ContentLearning> list, String title, String link, String category) {
        list.add(new ContentLearning(
            title, 
            "article", 
            link,
            ARTICLE_THUMBNAIL,
            category
        ));
    }
    
    private void addImage(List<ContentLearning> list, String title, String link, String category) {
        list.add(new ContentLearning(
            title, 
            "image", 
            link,
            link,
            category
        ));
    }
}