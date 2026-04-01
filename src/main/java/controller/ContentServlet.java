package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/ContentServlet")
public class ContentServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=========================================");
        System.out.println("ContentServlet doPost() was called!");
        System.out.println("=========================================");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action    = request.getParameter("action");
        String type      = request.getParameter("type");
        String title     = request.getParameter("title");
        String topic     = request.getParameter("topic");
        String url       = request.getParameter("url");
        String createdBy = request.getParameter("createdBy");
        String level       = request.getParameter("level");
        String thumbnail   = request.getParameter("thumbnail");
        String description = request.getParameter("description");
        String source      = request.getParameter("source");
        String duration    = request.getParameter("duration");

        System.out.println("Action: "    + action);
        System.out.println("Type: "      + type);
        System.out.println("Title: "     + title);
        System.out.println("Topic: "     + topic);
        System.out.println("URL: "       + url);
        System.out.println("CreatedBy: " + createdBy);

        if ("add".equals(action)) {

            // ── Basic validation ──────────────────────────────────────────
            if (type == null || type.isEmpty() ||
                title == null || title.isEmpty() ||
                topic == null || topic.isEmpty() ||
                url   == null || url.isEmpty()) {

                out.print("{\"success\": false, \"message\": \"Missing required fields.\"}");
                return;
            }

            // ── Insert into database ──────────────────────────────────────
            Connection conn = null;
            PreparedStatement ps = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

                String sql = "INSERT INTO learning_content " +
                             "(type, title, topic, url, thumbnail_url, description, " +
                             " level, source, duration, created_by, created_at) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

                ps = conn.prepareStatement(sql);
                ps.setString(1, type);
                ps.setString(2, title);
                ps.setString(3, topic);
                ps.setString(4, url);
                ps.setString(5, (thumbnail  != null && !thumbnail.isEmpty())   ? thumbnail   : null);
                ps.setString(6, (description != null && !description.isEmpty()) ? description : null);
                ps.setString(7, (level      != null && !level.isEmpty())       ? level       : null);
                ps.setString(8, (source     != null && !source.isEmpty())      ? source      : null);
                ps.setString(9, (duration   != null && !duration.isEmpty())    ? duration    : null);
                ps.setInt(10, Integer.parseInt(createdBy));

                int rows = ps.executeUpdate();
                System.out.println("Rows inserted: " + rows);

                if (rows > 0) {
                    out.print("{\"success\": true, \"message\": \"Content added successfully!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Insert failed — 0 rows affected.\"}");
                }

            } catch (Exception e) {
                e.printStackTrace();
                String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown error";
                out.print("{\"success\": false, \"message\": \"DB Error: " + msg + "\"}");

            } finally {
                if (ps   != null) try { ps.close();   } catch (Exception ignored) {}
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }

        } else if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Missing id.\"}");
                return;
            }
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                ps = conn.prepareStatement("DELETE FROM learning_content WHERE id = ?");
                ps.setInt(1, Integer.parseInt(idStr));
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    out.print("{\"success\": true}");
                } else {
                    out.print("{\"success\": false, \"message\": \"No row found with that id.\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown error";
                out.print("{\"success\": false, \"message\": \"DB Error: " + msg + "\"}");
            } finally {
                if (ps   != null) try { ps.close();   } catch (Exception ignored) {}
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }

        } else {
            out.print("{\"success\": false, \"message\": \"Unknown action: " + action + "\"}");
        }

        out.flush();
    }  // end doPost
}  // end class