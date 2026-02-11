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

@WebServlet("/SignUpServlet")
public class SignUpServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        // Password match check
        if (!password.equals(confirm)) {
            response.sendRedirect("signup.jsp");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // Check if username already exists
            PreparedStatement ps1 =
                    con.prepareStatement("SELECT id FROM users WHERE username=?");
            ps1.setString(1, username);
            ResultSet rs1 = ps1.executeQuery();

            if (rs1.next()) {
                response.sendRedirect("signup.jsp");
                return;
            }

            // Check if email already exists
            PreparedStatement ps2 =
                    con.prepareStatement("SELECT id FROM users WHERE email=?");
            ps2.setString(1, email);
            ResultSet rs2 = ps2.executeQuery();

            if (rs2.next()) {
                response.sendRedirect("signup.jsp");
                return;
            }

            // Insert new user
            PreparedStatement ps =
                    con.prepareStatement(
                        "INSERT INTO users(first_name,last_name,username,email,phone,password) VALUES(?,?,?,?,?,?)"
                    );

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, username);
            ps.setString(4, email);
            ps.setString(5, phone);
            ps.setString(6, password); // hashing comes next step

            ps.executeUpdate();

            ps.close();
            con.close();

            response.sendRedirect("login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("signup.jsp");
        }
    }
}
