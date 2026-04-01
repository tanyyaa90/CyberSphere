package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/checkPassword")
public class PasswordCheckServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    // Handle GET requests (when user directly visits the URL)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to the password checker page
        response.sendRedirect("passwordChecker.jsp");
    }
    
    // Handle POST requests (when form is submitted)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String password = request.getParameter("password");
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please enter a password");
            request.getRequestDispatcher("passwordChecker.jsp").forward(request, response);
            return;
        }
        
        try {
            // Hash the password using SHA-1
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            byte[] hashBytes = md.digest(password.getBytes());
            
            // Convert to hex and uppercase
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                hexString.append(String.format("%02X", b));
            }
            String hash = hexString.toString().toUpperCase();
            
            // Get first 5 characters (prefix) for k-anonymity
            String prefix = hash.substring(0, 5);
            String suffix = hash.substring(5);
            
            // Query the HIBP API
            String apiUrl = "https://api.pwnedpasswords.com/range/" + prefix;
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            
            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String line;
            int count = 0;
            
         // AFTER this block ONLY
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(":");
                if (parts[0].equalsIgnoreCase(suffix)) {
                    count = Integer.parseInt(parts[1]);
                    break;
                }
            }
            reader.close();


            // ===== DATABASE INSERT START =====
            try {
                String jdbcURL = "jdbc:mysql://localhost:3306/cybersphere";
                String dbUser = "root";
                String dbPass = "root";

                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(jdbcURL, dbUser, dbPass);

                String riskLevel;
                if (count == 0) {
                    riskLevel = "low";
                } else if (count < 1000) {
                    riskLevel = "medium";
                } else {
                    riskLevel = "high";
                }

                HttpSession session = request.getSession();
                Integer userId = (Integer) session.getAttribute("userId");

                String ipAddress = request.getRemoteAddr();

                String sql = "INSERT INTO password_checker_log (user_id, password_hash, prefix, breach_count, risk_level, ip_address) VALUES (?, ?, ?, ?, ?, ?)";

                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, userId != null ? userId : 0);
                ps.setString(2, hash);
                ps.setString(3, prefix);
                ps.setInt(4, count);
                ps.setString(5, riskLevel);
                ps.setString(6, ipAddress);

                ps.executeUpdate();

                ps.close();
                con.close();

            } catch (Exception dbEx) {
                dbEx.printStackTrace();
            }
            // ===== DATABASE INSERT END =====
            
            
            
            request.setAttribute("checked", true);
            request.setAttribute("pwnCount", count);
            request.getRequestDispatcher("passwordChecker.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error checking password: " + e.getMessage());
            request.getRequestDispatcher("passwordChecker.jsp").forward(request, response);
        }
    }
} 