package controller;

import model.PhishingPattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.regex.*;
import java.sql.*;

@WebServlet("/PhishingServlet")
public class PhishingServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    private static final List<PhishingPattern> patterns = Arrays.asList(
        new PhishingPattern(Pattern.compile("click here|link below|verify now", Pattern.CASE_INSENSITIVE), 15, "Urgent call to action"),
        new PhishingPattern(Pattern.compile("account (will be )?(suspended|closed|locked|terminated)", Pattern.CASE_INSENSITIVE), 20, "Threat of account suspension"),
        new PhishingPattern(Pattern.compile("unusual activity|suspicious activity|unauthorized", Pattern.CASE_INSENSITIVE), 10, "Claims of suspicious activity"),
        new PhishingPattern(Pattern.compile("verify (your )?(account|identity|information)", Pattern.CASE_INSENSITIVE), 15, "Requests account verification"),
        new PhishingPattern(Pattern.compile("http://|https://|www\\.", Pattern.CASE_INSENSITIVE), 2, "Contains links"),
        new PhishingPattern(Pattern.compile("bit\\.ly|tinyurl|shortlink|short-url", Pattern.CASE_INSENSITIVE), 15, "Suspicious shortened URL"),
        new PhishingPattern(Pattern.compile("update (your )?(payment|billing|credit card)", Pattern.CASE_INSENSITIVE), 20, "Requests payment information"),
        new PhishingPattern(Pattern.compile("confirm (your )?(details|information|data)", Pattern.CASE_INSENSITIVE), 15, "Requests personal information"),
        new PhishingPattern(Pattern.compile("urgent|immediate(ly)?|attention|action required", Pattern.CASE_INSENSITIVE), 15, "Creates urgency"),
        new PhishingPattern(Pattern.compile("dear (customer|user|client|valued)", Pattern.CASE_INSENSITIVE), 5, "Generic greeting"),
        new PhishingPattern(Pattern.compile("won|winner|lottery|prize|claim your", Pattern.CASE_INSENSITIVE), 30, "Too good to be true"),
        new PhishingPattern(Pattern.compile("fee|payment|processing fee|transfer", Pattern.CASE_INSENSITIVE), 25, "Requests money/fees"),
        new PhishingPattern(Pattern.compile("password|ssn|social security|credit card|pin", Pattern.CASE_INSENSITIVE), 20, "Requests sensitive data"),
        new PhishingPattern(Pattern.compile("microsoft|apple|google|paypal|amazon|bank(?!ing)", Pattern.CASE_INSENSITIVE), 10, "Impersonates trusted brand"),
        new PhishingPattern(Pattern.compile("@(?!.*\\.(com|org|net|edu|gov))[a-z]+\\.[a-z]{2,}", Pattern.CASE_INSENSITIVE), 20, "Suspicious email domain"),
        new PhishingPattern(Pattern.compile("24 hours|48 hours|within.*hours|expires?", Pattern.CASE_INSENSITIVE), 2, "Time pressure"),
        new PhishingPattern(Pattern.compile("free|discount|offer|limited time", Pattern.CASE_INSENSITIVE), 10, "Too good to be true offer"),
        new PhishingPattern(Pattern.compile("account.*limited|access.*restricted", Pattern.CASE_INSENSITIVE), 20, "Account restriction threat"),
        new PhishingPattern(Pattern.compile("verify.*identity|confirm.*identity", Pattern.CASE_INSENSITIVE), 15, "Identity verification request"),
        new PhishingPattern(Pattern.compile("irs|tax|refund|government", Pattern.CASE_INSENSITIVE), 20, "Government impersonation"),
        new PhishingPattern(Pattern.compile("inheritance|estate|beneficiary", Pattern.CASE_INSENSITIVE), 30, "Inheritance scam"),
        new PhishingPattern(Pattern.compile("western union|money gram|wire transfer", Pattern.CASE_INSENSITIVE), 25, "Suspicious payment method"),
        new PhishingPattern(Pattern.compile("click|link|attachment", Pattern.CASE_INSENSITIVE), 3, "Requests interaction with link/attachment"),
        new PhishingPattern(Pattern.compile("security.*alert|security.*notification", Pattern.CASE_INSENSITIVE), 15, "Security alert"),
        new PhishingPattern(Pattern.compile("(urgent|immediately|asap|act now|within \\d+ hours).*?(click|link|attachment)", Pattern.CASE_INSENSITIVE),15,"Urgent request to click link or open attachment")
    );

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\":true,\"message\":\"Unauthorized access\"}");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String emailText = request.getParameter("emailContent");

        if (emailText == null || emailText.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\":true,\"message\":\"Email content cannot be empty\"}");
            return;
        }

        int score = 0;
        List<Map<String, Object>> factorsList = new ArrayList<>();

        for (PhishingPattern p : patterns) {
            Matcher matcher = p.getPattern().matcher(emailText);
            if (matcher.find()) {
                score += p.getWeight();
                
                Map<String, Object> factor = new HashMap<>();
                factor.put("desc", p.getDescription());
                factor.put("points", p.getWeight());
                factorsList.add(factor);
            }
        }

        // Cap at 100%
        if (score > 100) score = 100;

        // Determine risk label and color
        String riskLabel;
        String color;

        if (score < 30) {
            riskLabel = "Low Risk";
            color = "green";
        } else if (score < 60) {
            riskLabel = "Moderate Risk";
            color = "orange";
        } else {
            riskLabel = "High Risk";
            color = "red";
        }

        // ========== NEW: Save to phishing_log table ==========
        Connection conn = null;
        PreparedStatement psInsert = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String insertSql = "INSERT INTO phishing_log (user_id, email_content, risk_percentage, risk_label) VALUES (?, ?, ?, ?)";
            psInsert = conn.prepareStatement(insertSql);
            
            psInsert.setInt(1, userId);
            // Truncate email content if too long (assuming text field has limits)
            String truncatedContent = emailText.length() > 500 ? emailText.substring(0, 500) + "..." : emailText;
            psInsert.setString(2, truncatedContent);
            psInsert.setInt(3, score);
            psInsert.setString(4, riskLabel);
            
            psInsert.executeUpdate();
            System.out.println("✅ Phishing analysis saved to database for user: " + userId);
            
        } catch (Exception e) {
            System.out.println("❌ Failed to save phishing analysis: " + e.getMessage());
            e.printStackTrace();
            // Continue even if logging fails - don't disrupt user experience
        } finally {
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        // ======================================================

        // Build JSON manually
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"percentage\":").append(score).append(",");
        json.append("\"riskLabel\":\"").append(riskLabel).append("\",");
        json.append("\"color\":\"").append(color).append("\",");
        json.append("\"factors\":[");
        
        for (int i = 0; i < factorsList.size(); i++) {
            if (i > 0) json.append(",");
            Map<String, Object> factor = factorsList.get(i);
            json.append("{");
            json.append("\"desc\":\"").append(factor.get("desc")).append("\",");
            json.append("\"points\":").append(factor.get("points"));
            json.append("}");
        }
        
        json.append("]");
        json.append("}");

        response.setStatus(HttpServletResponse.SC_OK);
        out.write(json.toString());
    }
}