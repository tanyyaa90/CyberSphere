<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String level = request.getParameter("level");
    String sublevel = request.getParameter("sublevel");
    
    if (level == null || sublevel == null) {
        response.sendRedirect("quizzes.jsp");
        return;
    }
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    PreparedStatement ps = null;
    int deletedCount = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // Delete all questions for this quiz
        String sql = "DELETE FROM questions WHERE level = ? AND sub_level = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, level);
        ps.setInt(2, Integer.parseInt(sublevel));
        
        deletedCount = ps.executeUpdate();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Redirect back to quizzes page with message
    if (deletedCount > 0) {
        response.sendRedirect("quizzes.jsp?success=Quiz deleted successfully (" + deletedCount + " questions removed)");
    } else {
        response.sendRedirect("quizzes.jsp?error=No questions found to delete");
    }
%>