package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/RemoveAdminServlet")
public class RemoveAdminServlet extends HttpServlet {
    
	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isMainAdmin") == null || !(Boolean) session.getAttribute("isMainAdmin")) {
            response.sendRedirect("manageAdmins.jsp");
            return;
        }
        
        int adminId = Integer.parseInt(request.getParameter("adminId"));
        
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false);
            
            // Remove admin permissions
            ps1 = conn.prepareStatement("DELETE FROM admin_permissions WHERE admin_id = ?");
            ps1.setInt(1, adminId);
            ps1.executeUpdate();
            
            // Update user role back to user
            ps2 = conn.prepareStatement("UPDATE users SET role = 'user' WHERE id = ?");
            ps2.setInt(1, adminId);
            ps2.executeUpdate();
            
            conn.commit();
            
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
        } finally {
            if (ps1 != null) try { ps1.close(); } catch (Exception e) {}
            if (ps2 != null) try { ps2.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        
        response.sendRedirect("manageAdmins.jsp");
    }
}