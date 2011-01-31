<%@ page import = 'java.sql.*' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/meta.jsp $-->
<!--$Rev: 966 $ $Date: 2004-12-18 23:19:30 -0600 (Sat, 18 Dec 2004) $ -->

<%
ResultSet rset = null;
ResultSet metaSet = null;
ResultSet infoSet = null;

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map params = new HashMap();

try {
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Meta-Contacts</title>
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
                <img class="adiumIcon" src="images/headlines/meta.png" width="128" height="128" border="0" alt="Meta Contacts" />
                <div class="text">
                    <h1>Edit Meta-Contacts</h1>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><a href="index.jsp">Viewer</a></li>
                    <li><a href="search.jsp">Search</a></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><span id="current">Meta-Contacts</span></li>
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="content">
                <h1>Meta-Contacts/Grouping</h1>
                <div class="boxExtraWideTop"></div>
                <div class="boxExtraWideContent">
<%

    rset = lc.executeQuery("information_keys_count", params);

    rset.next();

    int height = rset.getInt("count") * 31 + 105;

    rset = lc.executeQuery("meta_contacts", params);

    while(rset.next()) {

        String editURL = "edit.jsp?meta_id=" + rset.getInt("meta_id");
%>
<span class="edit">

    <a href="MetaContact?action=removeMetaContact&meta_id=<%= rset.getInt("meta_id") %>">Delete</a> |

    <a href="#" onClick="window.open('<%= editURL %>',
    'Edit Meta Contact', 'width=275,height=<%= height %>')">Edit ...</a>
    </span>
<%
        out.print("<h2><a href=\"chats.jsp?meta_id=" +
            rset.getString("meta_id") + "\">" +
            rset.getString("name") + "</a> (" +
            rset.getString("count") + ")</h2>");
        out.println("<div class=\"meta\">");
        out.print("<div class=\"personal_info\">");

        params.put("meta_id", new Integer(rset.getInt("meta_id")));

        infoSet = lc.executeQuery("meta_info", params);

        out.println("<table>");

        while(infoSet.next()) {
            out.println("<tr><td class=\"left\">" +
                infoSet.getString("key_name") + "</td>" +
                "<td>" + infoSet.getString("value") +
                "</td></tr>");
        }
        out.println("</table>");
        out.println("</div>");


        params.put("meta_id", new Integer(rset.getInt("meta_id")));

        metaSet = lc.executeQuery("meta_contained_users", params);

        while(metaSet.next()) {
            out.println("<p><img src=\"images/services/" +
                metaSet.getString("service") + ".png\" width=\"12\" height=\"12\" /> " +
                metaSet.getString("display_name")  + " (" +
                "<a href=\"chats.jsp?sender=" +
                metaSet.getString("user_id") + "\">" +
                metaSet.getString("username") + "</a>)");
            out.println("<span class=\"remove\">");

            if(!metaSet.getBoolean("preferred")) {
                out.println("<a href=\"MetaContact?action=updatePreferredMetaContact&meta_id=" +
                    rset.getString("meta_id") + "&amp;user_id=" +
                    metaSet.getString("user_id") + "\">Set Preferred</a>");
            }

            out.println("<a href=\"MetaContact?action=removeContactFromMeta&meta_id=" +
                rset.getString("meta_id") + "&amp;user_id=" +
                metaSet.getString("user_id") + "\">Remove</a></span></p>");
        }

        String formURL = new String("addContact.jsp?meta_id=" +
            rset.getString("meta_id"));
%>
<p><a href="#"
    onClick="window.open('<%= formURL %>', 'Add Contact', 'width=<%= 250 %>,height=80')">
                Add Contact ...
            </a></p>

            <div style="clear:both">&nbsp;</div>
<%
        out.println("</div>");

    }

%>
    <h2>
<a href="#"
    onClick="window.open('addMeta.jsp', 'Add Meta Contact', 'width=275,height=<%= height %>')">Add Meta Contact ...</a></h2>

                </div>
                <div class="boxExtraWideBottom"></div>
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
