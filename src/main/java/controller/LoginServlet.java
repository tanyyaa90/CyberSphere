package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginInput = request.getParameter("loginInput"); // username or email
        String password = request.getParameter("password");
        String enteredCaptcha = request.getParameter("captchaInput");

        HttpSession session = request.getSession();

        // Captcha validation (server-side)
        String actualCaptcha = (String) session.getAttribute("captcha");

        if (actualCaptcha == null || !actualCaptcha.equals(enteredCaptcha)) {
            response.sendRedirect("login.jsp?error=Wrong captcha");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql =
                "SELECT * FROM users WHERE (email=? OR username=?) AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, loginInput);
            ps.setString(2, loginInput);
            ps.setString(3, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("username", rs.getString("username"));

                response.sendRedirect("home.jsp");
            } else {
                response.sendRedirect(
                    "login.jsp?error=Username or password is incorrect"
                );
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                "login.jsp?error=Something went wrong. Please try again"
            );
        }
    }
}
