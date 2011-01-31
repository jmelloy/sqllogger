<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%@ page import = 'java.net.URLEncoder' %>

<%
int meta_id = Util.checkInt(request.getParameter("meta_id"));
int user_id = Util.checkInt(request.getParameter("user_id"));

ResultSet rset = null;
String name = new String();

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map params = new HashMap();

params.put("meta_id", new Integer(meta_id));
params.put("user_id", new Integer(user_id));

try {

    if(meta_id == 0 && user_id == 0) {
        out.print("Error:  No user or meta id");
    } else {
        if(meta_id != 0)
            rset = lc.executeQuery("meta_info", params);

        if(user_id != 0)
            rset = lc.executeQuery("user_info", params);

        if(rset.next()) {
            name = rset.getString("name");
        }
        
        if(meta_id != 0)
            rset = lc.executeQuery("meta_info_all_keys", params);

        if(user_id != 0)
            rset = lc.executeQuery("user_info_all_keys", params);
    }

%>
<html>
    <head><title>Edit <%= name %></title></head>
    <link rel="stylesheet" type="text/css" href="styles/default.css" />
    <link rel="stylesheet" type="text/css" href="styles/users.css" />
    <body style="background :#fff">

    <table border="0" cellpadding="0" cellspacing="5">

<%
    if(meta_id != 0) {
%>
        <form action="MetaContact" method="get">
            <input type="hidden" name="action" value="changeMetaInfo" />

            <tr>
            <td align="right" class="header">
            <label for="name">Name</label>
            </td>
            <td>
            <input type="text" name="name" size="20"
                value="<%= name %>"/>
            </td>
            </tr>
<% }

    if(user_id != 0) {
%>
        <form action="User" method="get">
            <input type="hidden" name="action" value="changeUserInfo" />
<% }

        while(rset.next()) {
            out.println("<tr><td align=\"right\">");
            out.println("<label for=\"" + rset.getString("key_name") + "\">" +
                rset.getString("key_name") + "</label>");

            out.println("</td><td>");

            out.println("<input type=\"text\" name=\"" +
                rset.getString("key_id") + "\" size=\"20\" value=\"" +
                rset.getString("value") + "\">");

            out.println("</td></tr>");
        }

%>
            </table>
            <input type="hidden" name="meta_id" value="<%= meta_id %>">
            <input type="hidden" name="user_id" value="<%= user_id %>">

            <div align="right">
                <input type="reset" /><input type="submit" />
            </div>
        </form>
        <p><a href="manageFields.jsp?return=<%= URLEncoder.encode("edit.jsp?" + request.getQueryString()) %>">Manage ...</a></p>
    </body>
</html>
<%
} catch (SQLException e) {
    out.println("<br />" + e.getMessage());
}
%>
