package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/admin/CheckQuizServlet")
public class CheckQuizServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String level = request.getParameter("level");
        String subLevel = request.getParameter("sublevel");
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        if (level == null || subLevel == null) {
            out.print("{\"exists\": false, \"error\": \"Missing parameters\"}");
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String sql = "SELECT COUNT(*) as count FROM questions WHERE level = ? AND sub_level = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, level);
            ps.setInt(2, Integer.parseInt(subLevel));
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int count = rs.getInt("count");
                if (count > 0) {
                    out.print("{\"exists\": true, \"count\": " + count + "}");
                } else {
                    out.print("{\"exists\": false}");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"exists\": false, \"error\": \"" + e.getMessage() + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}