package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/AddAdminServlet")
public class AddAdminServlet extends HttpServlet {
    
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
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        int assignedBy = (Integer) session.getAttribute("userId");
        
        boolean canManageUsers = request.getParameter("can_manage_users") != null;
        boolean canManageQuizzes = request.getParameter("can_manage_quizzes") != null;
        boolean canManageContent = request.getParameter("can_manage_content") != null;
        boolean canManageMessages = request.getParameter("can_manage_messages") != null;
        boolean canViewLogs = request.getParameter("can_view_logs") != null;
        
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false);
            
            // Update user role to admin
            ps1 = conn.prepareStatement("UPDATE users SET role = 'admin' WHERE id = ?");
            ps1.setInt(1, userId);
            ps1.executeUpdate();
            
            // Insert admin permissions
            ps2 = conn.prepareStatement(
                "INSERT INTO admin_permissions (admin_id, can_manage_users, can_manage_quizzes, can_manage_content, can_manage_messages, can_view_logs, assigned_by) VALUES (?, ?, ?, ?, ?, ?, ?)");
            ps2.setInt(1, userId);
            ps2.setBoolean(2, canManageUsers);
            ps2.setBoolean(3, canManageQuizzes);
            ps2.setBoolean(4, canManageContent);
            ps2.setBoolean(5, canManageMessages);
            ps2.setBoolean(6, canViewLogs);
            ps2.setInt(7, assignedBy);
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