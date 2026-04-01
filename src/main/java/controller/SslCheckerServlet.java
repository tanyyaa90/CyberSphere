package controller;

import java.io.*;
import java.net.*;
import java.security.cert.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.net.ssl.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/checkSsl")
public class SslCheckerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String domain = request.getParameter("domain");

        if (domain == null || domain.trim().isEmpty()) {
            request.setAttribute("error", "Please enter a domain.");
            request.getRequestDispatcher("sslChecker.jsp").forward(request, response);
            return;
        }

        domain = domain.trim()
                       .replace("https://", "")
                       .replace("http://", "")
                       .replace("www.", "");

        if (domain.contains("/")) {
            domain = domain.substring(0, domain.indexOf("/"));
        }

        try {
            SSLSocketFactory factory = (SSLSocketFactory) SSLSocketFactory.getDefault();
            SSLSocket socket = (SSLSocket) factory.createSocket();
            socket.connect(new InetSocketAddress(domain, 443), 5000);
            socket.startHandshake();

            SSLSession session = socket.getSession();
            Certificate[] certs = session.getPeerCertificates();
            X509Certificate cert = (X509Certificate) certs[0];

            String subject  = cert.getSubjectDN().getName();
            String issuer   = cert.getIssuerDN().getName();
            Date validFrom  = cert.getNotBefore();
            Date validTo    = cert.getNotAfter();
            String protocol = session.getProtocol();
            String cipher   = session.getCipherSuite();

            long diff     = validTo.getTime() - new Date().getTime();
            long daysLeft = diff / (1000 * 60 * 60 * 24);

            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            String fromStr = sdf.format(validFrom);
            String toStr   = sdf.format(validTo);

            boolean isExpired    = validTo.before(new Date());
            boolean expiringSoon = !isExpired && daysLeft <= 30;

            StringBuilder sans = new StringBuilder();
            try {
                if (cert.getSubjectAlternativeNames() != null) {
                    for (java.util.List<?> san : cert.getSubjectAlternativeNames()) {
                        if (san.get(1) instanceof String) {
                            if (sans.length() > 0) sans.append(", ");
                            sans.append(san.get(1).toString());
                        }
                    }
                }
            } catch (Exception e) {
                sans.append("Unable to read");
            }

            String cn = subject;
            if (subject.contains("CN=")) {
                cn = subject.substring(subject.indexOf("CN=") + 3);
                if (cn.contains(",")) cn = cn.substring(0, cn.indexOf(","));
            }

            String org = issuer;
            if (issuer.contains("O=")) {
                org = issuer.substring(issuer.indexOf("O=") + 2);
                if (org.contains(",")) org = org.substring(0, org.indexOf(","));
            }

            socket.close();
            
         // ===== DATABASE INSERT START =====
            try {
                String jdbcURL = "jdbc:mysql://localhost:3306/cybersphere";
                String dbUser = "root";
                String dbPass = "root";

                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(jdbcURL, dbUser, dbPass);

                // Flags
                boolean isValid = !isExpired;
                boolean isSelfSigned = issuer.equals(subject);
                boolean weakProtocol = protocol.contains("SSL") || protocol.contains("TLSv1");

                // Get user + IP
                HttpSession sessionUser = request.getSession();
                Integer userId = (Integer) sessionUser.getAttribute("userId");
                String ipAddress = request.getRemoteAddr();

                String sql = "INSERT INTO ssl_checker_log (user_id, domain, ip_address, is_valid, is_expired, is_self_signed, expiring_soon, days_left, valid_from, valid_to, issuer_org, common_name, protocol, cipher_suite, sans, weak_protocol) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                PreparedStatement ps = con.prepareStatement(sql);

                ps.setInt(1, userId != null ? userId : 0);
                ps.setString(2, domain);
                ps.setString(3, ipAddress);
                ps.setBoolean(4, isValid);
                ps.setBoolean(5, isExpired);
                ps.setBoolean(6, isSelfSigned);
                ps.setBoolean(7, expiringSoon);
                ps.setLong(8, daysLeft);
                ps.setTimestamp(9, new java.sql.Timestamp(validFrom.getTime()));
                ps.setTimestamp(10, new java.sql.Timestamp(validTo.getTime()));
                ps.setString(11, org);
                ps.setString(12, cn);
                ps.setString(13, protocol);
                ps.setString(14, cipher);
                ps.setString(15, sans.toString());
                ps.setBoolean(16, weakProtocol);

                ps.executeUpdate();

                ps.close();
                con.close();

            } catch (Exception dbEx) {
                dbEx.printStackTrace();
            }
            // ===== DATABASE INSERT END =====

            request.setAttribute("domain",       domain);
            request.setAttribute("cn",           cn);
            request.setAttribute("issuerOrg",    org);
            request.setAttribute("validFrom",    fromStr);
            request.setAttribute("validTo",      toStr);
            request.setAttribute("daysLeft",     daysLeft);
            request.setAttribute("isExpired",    isExpired);
            request.setAttribute("expiringSoon", expiringSoon);
            request.setAttribute("protocol",     protocol);
            request.setAttribute("cipher",       cipher);
            request.setAttribute("sans",         sans.toString());
            request.setAttribute("checked",      true);

        } catch (SSLHandshakeException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";

            if (msg.contains("validity check failed")) {
                request.setAttribute("expiredError", true);
                request.setAttribute("domain", domain);
            } else if (msg.contains("unable to find valid certification path")) {
                request.setAttribute("selfSignedError", true);
                request.setAttribute("domain", domain);
            } else if (msg.contains("No subject alternative names")) {
                request.setAttribute("error", "Certificate domain mismatch — the certificate was issued for a different domain.");
            } else {
                request.setAttribute("error", "SSL handshake failed — " + msg);
            }
        } catch (ConnectException e) {
            request.setAttribute("error", "Could not connect to " + domain + " on port 443. The site may not support HTTPS.");
        } catch (SocketTimeoutException e) {
            request.setAttribute("error", "Connection timed out. Check the domain and try again.");
        } catch (UnknownHostException e) {
            request.setAttribute("error", "Domain not found: " + domain);
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getClass().getName() + " — " + e.getMessage());
        }

        request.getRequestDispatcher("sslChecker.jsp").forward(request, response);
    }
}