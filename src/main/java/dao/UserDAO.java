package dao;

import model.User;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    public User login(String email, String password) {

        User user = null;

        try {
            Connection con = DBUtil.getConnection();

            String sql =
                "SELECT * FROM users WHERE email=? AND password=?";

            PreparedStatement ps =
                con.prepareStatement(sql);

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                user = new User();
                user.setId(rs.getInt("id"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }
}