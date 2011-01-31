<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'java.io.File' %>
<%@ page import = 'org.slamb.axamol.library.*' %>

<%
ResultSet rset = null;

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map params = new HashMap();

try {

    rset = lc.executeQuery("information_keys", params);
%>
<html>
    <head><title>Add Meta-Contact</title></head>
    <link rel="stylesheet" type="text/css" href="styles/default.css" />
    <link rel="stylesheet" type="text/css" href="styles/users.css" />
    <body style="background: #ffffff">
        <form action="MetaContact" method="get">
            <table border="0" cellpadding="0" cellspacing="5">
            <tr>
            <td align="right" class="header">
            <label for="name">Name</label>
            </td>
            <td>
            <input type="text" name="name" size="20" />
            </td>
            </tr>
<%
    while(rset.next()) {
        out.println("<tr><td align=\"right\">");
        out.println("<label for=\"" + rset.getString("key_name") + "\">" +
            rset.getString("key_name") + "</label>");

        out.println("</td><td>");

        out.println("<input type=\"text\" name=\"" +
            rset.getString("key_id") + "\" size=\"20\">");

        out.println("</td></tr>");
    }

%>
            </table>
            <div align="right">
                <input type="reset" /><input type="submit" />
            </div>
            <input type="hidden" name="action" value="addMeta" />
        </form>
        <p><a href="manageFields.jsp?return=addMeta.jsp">Manage Fields ... </a></p>
    </body>
</html>
<%
} catch (SQLException e) {
    out.println("<br />" + e.getMessage());
}
%>
