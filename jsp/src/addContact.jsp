<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'java.io.File' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>

<%

ResultSet rset = null;

String title = new String();
String service = new String();
String username = new String();
int meta_id;

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map params = new HashMap();

meta_id = Util.checkInt(request.getParameter("meta_id"));

service = Util.checkNull(request.getParameter("service"));

username = Util.checkNull(request.getParameter("username"));

try {

    params.put("meta_id", new Integer(meta_id));
    rset = lc.executeQuery("meta_contained_users", params);


    if(rset.next()) {
        title = rset.getString("name");
    }

%>

<html>
<head><title>Add Contact: <%= title %></title>
<script src="ac.js" ></script>
<body>
<form action="MetaContact" method="get" name="add">
<input type="hidden" name="action" value="addContactToMeta" />
    <input type="text" name="username" value="<%= Util.safeString(username) %>" autocomplete="off" size="30"/><br />
    <input type="checkbox" name="all" id="all"><label for="all">Add All</label>
    <input type="hidden" value="<%= meta_id %>" name="meta_id" />
    <div align="right">
        <input type="submit" name="gbtn"/>
    </div>
</form>
<script>
InstallAC(document.add,document.add.username,document.add.gbtn,"User","en");
</script>
</body>
</html>

<%
} catch (SQLException e) {
    out.println("<br />" + e.getMessage());
}
%>
