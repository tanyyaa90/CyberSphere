<%@ page import="java.sql.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("content.jsp?error=No content ID provided");
        return;
    }
    
    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");

    	String DB_URL = System.getenv().getOrDefault(
    	    "DB_URL",
    	    "jdbc:mysql://localhost:3306/cybersphere"
    	);

    	String DB_USER = System.getenv().getOrDefault("DB_USER", "root");
    	String DB_PASS = System.getenv().getOrDefault("DB_PASS", "root");

    	conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        
        ps = conn.prepareStatement("DELETE FROM learning_content WHERE id = ?");
        ps.setInt(1, Integer.parseInt(id));
        
        int rowsDeleted = ps.executeUpdate();
        
        if (rowsDeleted > 0) {
            response.sendRedirect("content.jsp?success=Content deleted successfully");
        } else {
            response.sendRedirect("content.jsp?error=Content not found");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("content.jsp?error=Database error");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>