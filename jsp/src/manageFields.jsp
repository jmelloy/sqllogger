<%@ page import = 'java.sql.*' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>

<%
ResultSet rset = null;

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-update");
Map params = new HashMap();

try {

    rset = lc.executeQuery("all_info_keys", params);
%>
<html>
    <head><title>Manage Fields</title></head>
    <link rel="stylesheet" type="text/css" href="styles/default.css" />
    <body style="background :#fff">
        <form action="SaveFormItems" method="get">
            <input type="hidden" name="action" value="updateFields" />
            <table border="0" cellpadding="0" cellspacing="5">
            <tr>
            <td align="right">
            <label for="name">Delete?</label>
            </td>
            <td>
                Field Name
            </td>
            </tr>
<%
    while(rset.next()) {
        out.println("<tr><td align=\"right\">");

        out.println("<input type=\"checkbox\" name=\"" +
            rset.getInt("key_id") + "\" id=\"" +
            rset.getString("key_name") + "\"" +
            (rset.getBoolean("delete") ? " checked=\"checked\"" : "") + "/>");
        out.println("</td><td>");

        out.println("<label for=\"" + rset.getString("key_name") +
            "\">" + rset.getString("key_name") + "</label>");

        out.println("</td></tr>");
    }

    for(int i = 1; i <= 3; i ++) {
        out.println("<tr><td></td><td>");
        out.println("<input type=\"text\" name=\"new" + i + "\" />");
        out.println("</td></tr>");
    }
%>

            </table>
                <input type="hidden" name="return" value="<%= request.getParameter("return") %>">
                <input type="reset" /><input type="submit" />
            </div>
        </form>
    </body>
</html>
<%
} catch (SQLException e) {
    out.println("<br />" + e.getMessage());
}
%>
