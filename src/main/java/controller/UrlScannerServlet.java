package controller;

import java.io.*;
import java.net.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/scanUrl")
public class UrlScannerServlet extends HttpServlet {

    private static final String API_KEY = "D9E3HTjHcpagT2bd5U1oSRVQxCD8xZyI";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String url = request.getParameter("url");

        if (url == null || url.trim().isEmpty()) {
            request.setAttribute("error", "Please enter a URL.");
            request.getRequestDispatcher("urlScanner.jsp").forward(request, response);
            return;
        }

        String displayUrl = url.trim();

        try {
            // IPQS uses a GET request with the URL encoded in the path
            String apiUrl = "https://ipqualityscore.com/api/json/url/"
                          + API_KEY + "/"
                          + URLEncoder.encode(displayUrl, "UTF-8");

            HttpURLConnection conn = (HttpURLConnection) new URL(apiUrl).openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "CyberSphere-App");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            int status = conn.getResponseCode();

            if (status != 200) {
                request.setAttribute("error", "API returned HTTP " + status);
                request.getRequestDispatcher("urlScanner.jsp").forward(request, response);
                return;
            }

            BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            reader.close();

            request.setAttribute("resultJson", sb.toString());
            request.setAttribute("scannedUrl", displayUrl);
            
         
            try {
                String jdbcURL = "jdbc:mysql://localhost:3306/cybersphere";
                String dbUser = "root";
                String dbPass = "root";

                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(jdbcURL, dbUser, dbPass);

                String json = sb.toString();

                // Basic extraction (simple parsing without library)
                int riskScore = json.contains("\"risk_score\":") 
                    ? Integer.parseInt(json.split("\"risk_score\":")[1].split(",")[0].trim()) 
                    : 0;

                boolean isPhishing   = json.contains("\"phishing\":true");
                boolean isMalware    = json.contains("\"malware\":true");
                boolean isSpam       = json.contains("\"spamming\":true");
                boolean isSuspicious = json.contains("\"suspicious\":true");
                boolean isParked     = json.contains("\"parked\":true");
                boolean redirected   = json.contains("\"redirected\":true");

                boolean hasHttps = displayUrl.startsWith("https");

                // Risk level logic
                String riskLevel;
                if (riskScore < 30) {
                    riskLevel = "safe";
                } else if (riskScore < 70) {
                    riskLevel = "medium";
                } else {
                    riskLevel = "high";
                }

                // Extract domain
                String domain = displayUrl.replace("https://", "").replace("http://", "");
                if (domain.contains("/")) domain = domain.substring(0, domain.indexOf("/"));

                // User + IP
                HttpSession sessionUser = request.getSession();
                Integer userId = (Integer) sessionUser.getAttribute("userId");
                String ipAddress = request.getRemoteAddr();

                String sql = "INSERT INTO url_scanner_log (user_id, url, domain, ip_address, risk_score, risk_level, is_phishing, is_malware, is_spam, is_parked, is_suspicious, has_https, redirected, full_response) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                PreparedStatement ps = con.prepareStatement(sql);

                ps.setInt(1, userId != null ? userId : 0);
                ps.setString(2, displayUrl);
                ps.setString(3, domain);
                ps.setString(4, ipAddress);
                ps.setInt(5, riskScore);
                ps.setString(6, riskLevel);
                ps.setBoolean(7, isPhishing);
                ps.setBoolean(8, isMalware);
                ps.setBoolean(9, isSpam);
                ps.setBoolean(10, isParked);
                ps.setBoolean(11, isSuspicious);
                ps.setBoolean(12, hasHttps);
                ps.setBoolean(13, redirected);
                ps.setString(14, json);

                ps.executeUpdate();

                ps.close();
                con.close();

            } catch (Exception dbEx) {
                dbEx.printStackTrace();
            }
            

        } catch (UnknownHostException e) {
            request.setAttribute("error", "Cannot reach IPQS — check your internet connection.");
        } catch (SocketTimeoutException e) {
            request.setAttribute("error", "Request timed out. Try again.");
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getClass().getName() + " — " + e.getMessage());
        }

        request.getRequestDispatcher("urlScanner.jsp").forward(request, response);
    }
}