<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Vector' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/statistics.jsp $-->
<!--$Rev: 1080 $ $Date: 2005-05-29 14:38:48 -0500 (Sun, 29 May 2005) $ -->

<%

int sender, meta_id;
String sender_sn = new String();
String senderDisplay = new String();
String title = new String("Statistics");
String notes = new String();

int total_messages = 0;
boolean loginUsers = false;

sender = Util.checkInt(request.getParameter("sender"));
meta_id = Util.checkInt(request.getParameter("meta_id"));

loginUsers = Boolean.valueOf(request.getParameter("login")).booleanValue();

int totalStats[][] = new int[2][3];
double sentAve = 0;
double recAve = 0;

int max = 0;
int years = 0;

int monthArray[][][] = new int[10][14][2];

ResultSet rset = null;
ResultSet totals = null;
ResultSetMetaData rsmd = null;


LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
LibraryConnection stats = (LibraryConnection) request.getAttribute("lc-stats");

Map params = new HashMap();

params.put("startDate", null);
params.put("endDate", null);

try {

    if(sender != 0) {
        params.put("user_id", new Integer(sender));
        rset = lc.executeQuery("user_display_name", params);
        rset.next();

        title = "<img src=\"images/services/" + rset.getString("service") +
            ".png\" width=\"28\" height=\"28\"> " +
            rset.getString("display_name") + " (" +
            rset.getString("username") + ")";

        sender_sn = rset.getString("username");
        senderDisplay = rset.getString("display_name");
    }

    if(meta_id != 0) {

        params.put("meta_id", new Integer(meta_id));
        rset = lc.executeQuery("meta_contained_users", params);

        while(rset.next()) {
            title = rset.getString("name");
            sender_sn = rset.getString("name");
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
<title>SQL Logger: Statistics</title>
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
                <img class="adiumIcon" src="images/headlines/stats.png" width="128" height="128" border="0" alt="Statistics Icon" />
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
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><span id="current">Statistics</span></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">
<%
        if(sender == 0) {
            params.put("sender", null);
        } else {
            params.put("sender", new Integer(sender));
        }

        params.put("meta_id", new Integer(meta_id));

        if (meta_id != 0) {
            totals = stats.executeQuery("yearly_monthly_totals_meta", params);
        } else {
            totals = stats.executeQuery("yearly_monthly_totals_sender", params);
        }

        for(int i = 0; i < 2; i++) {
            for( int j = 0; j < 3; j++) {
                totalStats[i][j] = 0;
            }
        }

        for(int i = 0; i < 10; i++) {
            for(int j = 0; j < 14; j++) {
                monthArray[i][j][0] = 0;
                monthArray[i][j][1] = 0;
            }
        }

        String prev = new String();

        while(totals.next()) {

            if(totals.getBoolean("is_sender")) {

                totalStats[0][0] += totals.getInt("count");
                totalStats[0][1]++;
                sentAve = (double)totalStats[0][0] /
                    totalStats[0][1];

            } else {

                totalStats[1][0] += totals.getInt("count");
                totalStats[1][1]++;
                recAve = (double) totalStats[1][0] /
                    totalStats[1][1];
            }

            boolean found = false;

            for(int i = 0; i < years && !found; i++) {
                if(monthArray[i][0][0] == totals.getInt("year")) {
                    found = true;
                    monthArray[i][totals.getInt("month")][totals.getInt("is_sender")] =
                        totals.getInt("count");
                    monthArray[i][13][totals.getInt("is_sender")] += totals.getInt("count");
                }
            }

            if(!found) {
                monthArray[years][0][0] = totals.getInt("year");
                monthArray[years][totals.getInt("month")][totals.getInt("is_sender")] +=
                    totals.getInt("count");
                monthArray[years++][13][totals.getInt("is_sender")] +=
                    totals.getInt("count");
            }
        }

        for (int i = 0; i < years; i++) {
            for(int j = 1; j < 13; j++) {
                if(monthArray[i][j][0] + monthArray[i][j][1] > max)
                    max = monthArray[i][j][0] + monthArray[i][j][1];
            }
        }

%>
                <h1>Meta Contacts</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">

<%

    rset = lc.executeQuery("meta_contacts", params);

    while(rset.next()) {
        out.println("<p><a href=\"statistics.jsp?meta_id=" + rset.getInt("meta_id") + "\">" + rset.getString("name") + "</a></p>");
    }
%>
                </div>
                <div class="boxThinBottom"></div>

                <h1>Users</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
<%

    params.put("login", Boolean.toString(loginUsers));
    rset = lc.executeQuery("all_users", params);

    if(!loginUsers) {
        out.print("<p><i><a href=\"statistics.jsp?sender=" +
            sender + "&login=true\">Login Users</a></i></p>");
    } else {
        out.print("<p><i><a href=\"statistics.jsp?sender=" +
            sender + "&login=false\">" +
            "All Users</a></i></p>");
    }

    out.println("<p></p>");

    while (rset.next())  {
        if (Integer.parseInt(rset.getString("user_id")) != sender) {
            out.println("<p>");
            out.println("<img src=\"images/services/" +
                rset.getString("service") + ".png\" width=\"12\" height=\"12\" />");
            out.println("<a href=\"statistics.jsp?sender=" +
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

            <h1>Detailed Statistics</h1>
            <div class="boxWideTop"></div>
            <div class="boxWideContent">
                <jsp:include page="Calendar">
                    <jsp:param name="sender" value="<%=sender%>"/>
                    <jsp:param name="meta_id" value="<%=meta_id%>"/>
                    <jsp:param name="returnURL" value="details.jsp"/>
                </jsp:include>
            </div>
            <div class="boxWideBottom"></div>


                <h1>Total Messages Sent/Received</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    total_messages += totalStats[0][0];
    total_messages += totalStats[1][0];
    if(sender != 0 || meta_id != 0) {
        out.print("Total Messages Sent: " +
                totalStats[0][0] + "<br>");

        out.print("Average Sent per Month: " + (int)sentAve + " <br /><br />");

        out.print("Total Messages Received: " +
                totalStats[1][0] + "<br />");

        out.println("Average Received per Month: " + (int)recAve + "<br />");
    }

    out.println("<br />Total Messages Sent/Received: " + total_messages + "<br /><br/>");

%>
                </div>
                <div class="boxWideBottom"></div>


                <h1>Messages Sent/Received by Month and Year</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    double maxDistance = max * 1.2;

    for(int yrCnt = 0; yrCnt < years; yrCnt++) {
        out.print("<br />\n");
        out.println("<b>" + monthArray[yrCnt][0][0] + "</b> (" +
                (monthArray[yrCnt][13][0] + monthArray[yrCnt][13][1]) +
                ")<br />");
        out.println("<table height=\"243\" width=\"400\"" +
                " cellspacing=\"0\"><tr>");

        for(int i = 1; i < 13; i++) {
            out.println("<td valign=\"bottom\" rowspan=\"13\"" +
                    " background=\"images/gridline2.gif\">");

            double sendHeight = monthArray[yrCnt][i][1] / maxDistance * 225;
            if (sendHeight < 1 && sendHeight != 0) sendHeight = 1;
            out.println("<img src=\"images/bar_red.gif\" width = \"15\" height=\"" +
                    (int)sendHeight + "\">");

            double recHeight = monthArray[yrCnt][i][0] / maxDistance * 225;
            if (recHeight < 1 && recHeight != 0) recHeight = 1;
            out.println("<img src=\"images/bar2.gif\" width = \"15\" height=\"" +
                    (int)recHeight + "\">");

            out.println("</td>");
        }

        out.println("</tr>");

        String months[] = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
            "Aug", "Sep", "Oct", "Nov", "Dec"};
        for(int i = 1; i < 13; i++) {
            out.println("<tr><td align=\"right\">" + months[i] + ":</td><td "+
                    " align=\"left\" width=\"100\"> " + monthArray[yrCnt][i][1] +
                    " / " + monthArray[yrCnt][i][0] +
                    "</td></tr>");
        }

        out.println("<tr>");
        for(int i = 1; i < 13; i++) {
            out.println("<td align=\"center\">" + i + "</td>");
        }
        out.println("</tr></table>");
    }
%>
                </div>
                <div class="boxWideBottom"></div>

                <h1>Most Popular Users</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%


    if(meta_id != 0) {
        rset = stats.executeQuery("popular_users_meta", params);
    } else {
        rset = stats.executeQuery("popular_users_sender", params);
    }

    out.println("<table>");
    out.println("<tr><td>#</td><td>Username</td><td>Sent</td><td>Received</td><td>Random Quote</td></tr>");

    while(rset.next()) {
        out.println("<tr>");
        out.println("<td>" + rset.getRow() + "</td>");
        out.println("<td>" + rset.getString("username") + "</td>");
        out.println("<td>" + rset.getString("sent") + "</td>");
        out.println("<td>" + rset.getString("received") + "</td>");
        out.println("<td>" + rset.getString("message") + "</td>");
        out.println("</tr>");
    }

    out.println("</table>");
%>
                </div>
                <div class="boxWideBottom"></div>
<%
    if(sender != 0 || meta_id != 0) {
%>
                <h1>Most Popular Messages</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

        if(sender != 0) {
            rset = stats.executeQuery("popular_messages_sender", params);
        }

        if(meta_id != 0) {
            rset = stats.executeQuery("popular_messages_meta", params);
        }

        out.println("<table>");

        out.println("<tr><td>#</td>"+
                "<td>Message</td><td>"+
                "Cnt</td><td>Last Used</td></tr>");

        while(rset.next()) {
            out.println("<tr><td>" + rset.getRow() + "</td>");
            out.println("<td>" +
                    rset.getString("message") + "</td>");
            out.println("<td>" +
                    rset.getString("count") + "</td>");
            out.println("<td>" +
                    rset.getString("max") + "</td>");

        }
        out.println("</table>");

%>
                </div>
                <div class="boxWideBottom"></div>
<%
    }
%>
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
