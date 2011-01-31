<%@ page import = 'java.sql.*' %>
<%@ page import = 'javax.naming.*' %>
<%@ page import = 'javax.sql.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>

<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.01 Transitional//EN">
<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/defrag.jsp $-->
<!--$Rev: 961 $ $Date: 2004-12-16 12:55:46 -0600 (Thu, 16 Dec 2004) $ -->
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();
int sender;
String sender_sn;
int total_messages = 0;
boolean loginUsers = false;

sender = Util.checkInt(request.getParameter("sender"));

loginUsers = Boolean.valueOf(request.getParameter("login")).booleanValue();
%>
<html>
    <head>
        <title>SQLLogger: Defrag Statistics</title>
    </head>
    <body>
    <%
    if (sender == 0) {
        out.print("<div align=\"center\">");
        out.print("<h3>Please choose a user:</h3>");
        if(!loginUsers) {
            out.print("<a href=\"statistics.jsp?login=true\">Login Users</a>");
        } else {
            out.print("<a href=\"statistics.jsp\">All Users</a>");
        }
        out.print("</div>");
    }
    %>
<%
PreparedStatement pstmt = null;
ResultSet rset = null;
ResultSetMetaData rsmd = null;
Statement stmt = null;
ResultSet totals = null;

try {
    stmt = conn.createStatement();

    if(sender != 0) {
        out.println("<table width=\"750\" cellspacing=\"0\" cellpadding=\"0\">");
        out.println("<tr>");

        pstmt = conn.prepareStatement("select " +
            " case when sender_id = ? then recipient_id else sender_id " +
            " end as sender_id " +
            " from im.messages where sender_id = ? or recipient_id = ? " +
            " order by message_date ");

        pstmt.setInt(1, sender);
        pstmt.setInt(2, sender);
        pstmt.setInt(3, sender);

        rset = pstmt.executeQuery();

        int red, green, blue;

        while(rset.next() ) {
            red = (0 + (rset.getInt("sender_id") * 3) % 255);
            green = (128 + (rset.getInt("sender_id") * 2) % 255);
            blue = (66 + (rset.getInt("sender_id") * 7 + 5) % 255);

            if(rset.getInt("sender_id") == 12) {
                red = 0;
                green = 0;
                blue = 0;
            }

            out.println("<td width=\"2\" height=\"2\" bgcolor=\"#" +
                Integer.toHexString(red) +
                Integer.toHexString(green) +
                Integer.toHexString(blue) + "\">");
            if(rset.getRow() % 375 == 0) {
                out.println("</tr><tr>");
            }
        }

        out.println("</table>");

    }
%>
    <table><tr>
    <td width="150" align="right" valign="top">
    <% if (sender != 0) out.print("<h4>Users:</h4>"); %>
    </td>
    </tr>
    <%
    if(!loginUsers) {
        rset = stmt.executeQuery("select user_id, username "+
            " as username from im.users" +
            " order by username");
    } else {
        rset = stmt.executeQuery("select sender_id as user_id, "+
            " username as username "+
            "from user_statistics, users where sender_id = user_id "+
            " group by sender_id, username "+
            " having count(*) > 1 order by username");
    }

    int peopleCnt = 1;

    if(sender != 0) {
        out.println("<tr><td colspan=\"5\">");
        if (loginUsers) {
            out.print("<a href=\"defrag.jsp?sender=" + sender + "&login=false\">All Users</a><br /><br />");
        } else {
            out.print("<a href=\"defrag.jsp?sender=" + sender + "&login=true\">Login Users</a><br /><br />");
        }
        out.println("</td>");
    }

    while (rset.next())  {
        if ((rset.getRow() -1) % 4 == 0) {
            out.println("</tr><tr>");
        }

        int red, green, blue;

        red = (0 + (rset.getInt("user_id") * 3) % 255);
        green = (128 + (rset.getInt("user_id") * 2) % 255);
        blue = (66 + (rset.getInt("user_id") * 7 + 5) % 255);

        if(rset.getInt("user_id") == 12) {
            red = 0;
            green = 0;
            blue = 0;
        }

        out.println("<td bgcolor=\"#" +
                Integer.toHexString(red) +
                Integer.toHexString(green) +
                Integer.toHexString(blue) + "\">");
        if (rset.getInt("user_id") != sender) {
            out.print("<a href=\"defrag.jsp?sender=" +
            rset.getString("user_id") + "&login=" +
            Boolean.toString(loginUsers) +
            "\">" + rset.getString("username") +
            "</a>");
        }
        else {
            out.print(rset.getString("username"));
        }
        out.println("</td>");
    }
%>
    </tr>
</table>
<%
} catch (SQLException e) {
    out.print("<br />" + e.getMessage());
} finally {
    if (stmt != null) {
        stmt.close();
    }
    conn.close();
}
%>
</body>
</html>
