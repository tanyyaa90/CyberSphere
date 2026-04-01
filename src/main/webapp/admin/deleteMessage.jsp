<%@ page import="java.sql.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String id = request.getParameter("id");
    if (id != null) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/cybersphere", "root", "root");
            
            ps = conn.prepareStatement("DELETE FROM contact_messages WHERE id = ?");
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
    
    response.sendRedirect("messages.jsp");
%>