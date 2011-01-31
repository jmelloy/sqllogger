<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Vector' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%@ page import = 'org.visualdistortion.sqllogger.Calendar' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/chats.jsp $-->
<!--$Rev: 1066 $ $Date: 2005-04-24 12:01:02 -0500 (Sun, 24 Apr 2005) $ -->

<%
int sender, meta_id;
boolean loginUsers = Boolean.valueOf(request.getParameter("login")).booleanValue();

String title = new String();
String notes = new String();

sender = Util.checkInt(request.getParameter("sender"));
meta_id = Util.checkInt(request.getParameter("meta_id"));

String dateStart = Util.checkNull(request.getParameter("start"));
String dateFinish = Util.checkNull(request.getParameter("finish"));
String orderBy = "message_date " + Util.safeString(Util.checkNull(request.getParameter("order")), "asc");

ResultSet rset = null;
ResultSetMetaData rsmd = null;

boolean all = Boolean.valueOf(request.getParameter("all")).booleanValue();

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map params = new HashMap();

params.put("startDate", dateStart);
params.put("endDate", dateFinish);

try {

    if(sender != 0) {
        params.put("user_id", new Integer(sender));

        rset = lc.executeQuery("user_display_name", params);

        rset.next();

        title = "<img src=\"images/services/" + rset.getString("service") +
            ".png\" width=\"28\" height=\"28\"> " +
            rset.getString("display_name") + " (" +
            rset.getString("username") + ")";

    }

    if(meta_id != 0) {

        params.put("meta_id", new Integer(meta_id));

        rset = lc.executeQuery("meta_contained_users", params);

        while(rset.next()) {
            title = rset.getString("name");
            notes += "<img src=\"images/services/" +
                rset.getString("service") +
                ".png\" width=\"12\" height=\"12\" /> " +
                rset.getString("display_name") + " (" +
                rset.getString("username") + ")<br />";
        }
    }
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Chats</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="styles/layout.css" />
<link rel="stylesheet" type="text/css" href="styles/default.css" />
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
                <img class="adiumIcon" src="images/headlines/chats2.png" width="128" height="128" border="0" alt="Chats Icon" />
                <div class="text">
                    <h1><%= title %></h1>
                    <p><%= notes %></p>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><a href="index.jsp">Viewer</a></li>
                    <li><a href="search.jsp">Search</a></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><a href="meta.jsp">Meta-Contacts</a></li>
                    <li><span id="current">Chats</span></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">

                <h1>Meta Contacts</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">

<%
    rset = lc.executeQuery("meta_contacts", params);

    while(rset.next()) {
        out.println("<p><a href=\"chats.jsp?meta_id=" + rset.getInt("meta_id") + "\">" + rset.getString("name") + "</a></p>");
    }
%>
                </div>
                <div class="boxThinBottom"></div>

                <h1>Users</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
<%

    if(!loginUsers) {
        out.print("<p><i><a href=\"chats.jsp?sender=" +
            sender + "&login=true\">Login Users</a></i></p>");
    } else {
        out.print("<p><i><a href=\"chats.jsp?sender=" +
            sender + "&login=false\">" +
            "All Users</a></i></p>");
    }

    out.println("<p></p>");

    params.put("login", Boolean.toString(loginUsers));
    rset = lc.executeQuery("all_users", params);

    while (rset.next())  {
        if (rset.getInt("user_id") != sender) {
            out.println("<p>");
            out.println("<img src=\"images/services/" +
                rset.getString("service") + ".png\" width=\"12\" height=\"12\" />");
            out.println("<a href=\"chats.jsp?sender=" +
            rset.getString("user_id") + "&login=" +
            Boolean.toString(loginUsers) +
            "\" title=\"" + rset.getString("username") + "\">" +
            rset.getString("display_name") +
            "</a></p>");
        }
        else {
            out.println("<p>" + rset.getString("username") + "</p>");
        }
    }
%>
                </div>
                <div class="boxThinBottom"></div>
            </div>
            <div id="content">

<%
    if(sender != 0 || meta_id != 0) {
%>
                <h1>Months</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent" align="center">
                
                <jsp:include page="Calendar">
                    <jsp:param name="sender" value="<%=sender%>"/>
                    <jsp:param name="meta_id" value="<%=meta_id%>"/>
                    <jsp:param name="returnURL" value="chats.jsp"/>
                </jsp:include>
                
                    <span style="float: right">
                        <a href="chats.jsp?sender=<%= sender %>&meta_id=<%= meta_id %>&all=true">All</a> |
                        <a href="chats.jsp?sender=<%= sender %>&meta_id=<%= meta_id %>&start=<%= dateStart %>&finish=<%= dateFinish %>&order=<%= orderBy.equals("message_date asc") ? "desc" : "asc" %>&all=<%= all %>"><%= orderBy.equals("message_date asc") ? "Sort Desc" : "Sort Asc" %></a>
                </span>
                </div>
                <div class="boxWideBottom"></div>
<%
    }
%>
                <h1>Chats</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%
    if((dateStart != null || dateFinish != null) || all) {
        if(sender != 0) {
            params.put("user_id", new Integer(sender));
            rset = lc.executeQuery("all_chats_sender", params, orderBy);
        }

        if(meta_id != 0) {
            params.put("meta_id", new Integer(meta_id));

            rset = lc.executeQuery("all_chats_meta", params, orderBy);
        }

        String prevDate = new String();

        while(rset.next()) {
            if(!rset.getString("date").equals(prevDate)) {
                out.println("<h3>" + rset.getString("date") + "</h3>");
            }

            out.println("<span style=\"margin-left: 15px\">");

            if(sender != 0) {
                out.println(rset.getString("time") +
                    " <a href=\"index.jsp?sender=" + rset.getString("sender_sn") +
                    "&recipient=" + rset.getString("recipient_sn") +
                    "&message_id=" + rset.getString("message_id") +
                    "\" title=\"" + rset.getString("sender_sn") +
                    ":" + rset.getString("recipient_sn") + "\">" +
                    rset.getString("message") + "</a>");
            } else if (meta_id != 0) {
                out.println(rset.getString("time") +
                    " <a href=\"index.jsp?meta_id=" + meta_id +
                    "&message_id=" + rset.getString("message_id") + "\">" +
                    rset.getString("message") + "</a>");
            }

            out.println("</span>");

            out.println("<br />");

            prevDate = rset.getString("date");
        }
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
