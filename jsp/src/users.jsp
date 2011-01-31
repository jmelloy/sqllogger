<%@ page import = 'java.sql.*' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.visualdistortion.util.Util' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/users.jsp $-->
<!--$Rev: 960 $ $Date: 2004-12-16 00:05:48 -0600 (Thu, 16 Dec 2004) $ -->

<%
String startChar = Util.safeString(request.getParameter("start"), "a");

ResultSet rset = null;
ResultSet infoSet = null;

Map params = new HashMap();
LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");

try {
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Users</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="styles/layout.css" />
<link rel="stylesheet" type="text/css" href="styles/default.css" />
<link rel="stylesheet" type="text/css" href="styles/users.css" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<script language="javascript" type="text/javascript">
 function OpenLink(c){
   window.open(c, 'link', 'width=480,height=480,scrollbars=yes,status=yes,toolbar=no');
 }
</script>
</head>
<body>
    <div id="container">
        <div id="header">
        </div>
        <div id="banner">
            <div id="bannerTitle">
            <img class="adiumIcon" src="images/headlines/users.png" width="128" height="128" border="0" alt="Users" />
                <div class="text">
                    <h1>Edit Users</h1>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><a href="index.jsp">Viewer</a></li>
                    <li><a href="search.jsp">Search</a></li>
                    <li><span id="current">Users</span></li>
                    <li><a href="meta.jsp">Meta-Contacts</a></li>
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">
                <h1>Login Users</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
                    <form action="User" method="get">
                        <input type="hidden" name="action" value="updateLogin" />
<%
    rset = lc.executeQuery("possible_login_users", params);

    while (rset.next())  {
        out.println("<p>");
        out.print("<input type=\"checkbox\" name=\"" +
            rset.getString("user_id") + "\" ");

        if(rset.getBoolean("login")) {
            out.print("checked=\"checked\"");
        }

        out.print("/>");
        out.println(rset.getString("username") + "</p>");
    }

%>
                        <input type="submit">
                    </form>
                </div>
                <div class="boxThinBottom"></div>
            </div>
            <div id="content">
                <h1>Users</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    out.println("<div align=\"center\">");
    String letters[] = {"a", "b", "c", "d", "e", "f", "g", "h","i",
            "j", "k", "l", "m", "n", "l", "o", "p", "q", "r", "s", "t",
            "u", "v", "w", "x", "y", "z"};

    for(int i = 0; i < letters.length; i++) {
        out.println("<a href=\"users.jsp?start=" + letters[i] +
                "\">" + letters[i] + "</a> | ");
        if(i == 13) {
            out.println("<br />");
        }
    }

    out.println("<a href=\"users.jsp?start=0\"> #</a>");

    out.println("</div><br />");

    rset = lc.executeQuery("information_keys_count", params);

    rset.next();

    int height = rset.getInt("count") * 31 + 80;

    if(startChar.equals("0")) {
        rset = lc.executeQuery("users_starting_non_letter", params);
    } else {
        params.put("letter", startChar);
        rset = lc.executeQuery("users_starting_with_letter", params);
    }

    while(rset.next()) {

        String editURL = "edit.jsp?user_id=" + rset.getString("user_id");
%>
<span class="edit"<a href="#"
    onClick="window.open('<%= editURL %>', 'Edit User', 'width=275,height=<%= height %>')">Edit Info ...</a></span>
<%

        out.print("<h2><img src=\"images/services/" +
            rset.getString("service") + ".png\" width=\"14\" height=\"14\" /> " +
            rset.getString("display_name") + " (" +
            "<a href=\"chats.jsp?sender=" +
            rset.getString("user_id") + "\">" +
            rset.getString("username") + "</a>)</h2>");
        out.println("<div class=\"meta\">");

        params.put("user_id", new Integer(rset.getInt("user_id")));
        infoSet = lc.executeQuery("user_info", params);

        out.println("<table>");

        while(infoSet.next()) {
            out.println("<tr><td class=\"left\">" +
                infoSet.getString("key_name") + "</td>" +
                "<td>" + infoSet.getString("value") +
                "</td></tr>");
        }
        out.println("</table>");


%>
        </div>
<%

    }

%>
                </div>
                <div class="boxWideBottom"></div>
            </div>
            <div id="bottom">
                <div class="cleanHackBoth"> </div>
            </div>
        </div>
        <div id="footer">&nbsp;</div>
    </div>
<%
} catch (SQLException e) {
    out.print("<br />" + e.getMessage());
}
%>
</body>
</html>
