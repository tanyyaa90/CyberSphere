package controller;

import dao.QuestionDAO;
import model.Question;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.sql.*;

@WebServlet("/ResultServlet")
public class ResultServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Replaced by QuizServlet.doPost() — do not use
        response.sendRedirect("home.jsp");
    }}