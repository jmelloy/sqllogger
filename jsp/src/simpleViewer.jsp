<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.ArrayList' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%@ page import = 'org.visualdistortion.sqllogger.*' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/simpleViewer.jsp $-->
<!--$Rev: 1075 $ $Date: 2005-05-19 18:07:58 -0500 (Thu, 19 May 2005) $ -->

<%
String dateStart, dateFinish, from_sn, to_sn, contains_sn;
boolean showDisplay = true;
boolean showMeta = false;

Date today = new Date(System.currentTimeMillis());
int chat_id = 0;
int meta_id = 0;

dateFinish = Util.checkNull(request.getParameter("finish"));
dateStart = Util.checkNull(request.getParameter("start"));
from_sn = Util.checkNull(request.getParameter("from"));
to_sn = Util.checkNull(request.getParameter("to"));
contains_sn = Util.checkNull(request.getParameter("contains"));
String screenDisplayMeta = Util.checkNull(request.getParameter("screen_or_display"));
String service = Util.checkNull(request.getParameter("service"));

String title = new String("");
String notes = new String("");

chat_id = Util.checkInt(request.getParameter("chat_id"));

if(screenDisplayMeta != null && screenDisplayMeta.equals("screen")) {
    showDisplay = false;
} else if (screenDisplayMeta != null && screenDisplayMeta.equals("meta")) {
    showMeta = true;
    showDisplay = false;
}

meta_id = Util.checkInt(request.getParameter("meta_id"));
if(meta_id != 0) {
    showMeta = true;
    showDisplay = false;
}

MessageFormatter.clearUsers();

ResultSet rset = null;
ResultSet noteSet = null;

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
Map paramMap = new HashMap();
try {

    if(chat_id != 0) {

        paramMap.put("chat_id", new Integer(chat_id));
        rset = lc.executeQuery("saved_chat", paramMap);

        if(rset != null && rset.next()) {
            from_sn = rset.getString("sent_sn");
            to_sn = rset.getString("received_sn");
            contains_sn = rset.getString("single_sn");
            dateFinish = rset.getString("date_finish");
            dateStart = rset.getString("date_start");
            title = rset.getString("title");
            notes = rset.getString("notes");
            meta_id = rset.getInt("meta_id");
            if(meta_id != 0) {
                showMeta = true;
                showDisplay = false;
            }
        }
    } else {
        title = "Message Viewer";
    }
%>
<html xms="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: <%= title %></title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<style>
body {
    font-family: "Lucida Grande", "Lucida Sans Unicode", verdana, lucida, sans-serif;
    font-size: 11px;
}

a, a:link, a:visited {
    color: #006600;
    text-decoration: none;
}

a:hover {
    color: #ff9934;
    text-decoration: underline;
}

.dateHeader {
    border: 1px solid #CCCCCC;
    font-weight: bold;
    color: #333;
    margin-bottom: 5px;
    margin-top: 5px;
    padding: 2px;
}

.messages {
    margin-top: 1px;
    margin-bottom: 1px;
    text-indent: -15px;
    padding-left: 30px;
}

.usernames {
    margin-top: 3px;
    margin-bottom: 3px;
}
</style>
</head>
<body>
<%
    boolean unconstrained = false;

    if(dateStart != null && dateFinish == null) unconstrained = true;

    if(unconstrained) {
        out.print("<div align=\"center\"><i>Limited to 250 " +
        "messages.</i><br><br></div>");
    }

    paramMap.put("startDate", dateStart);
    paramMap.put("endDate", dateFinish);
    paramMap.put("sendSN", from_sn);
    paramMap.put("recSN", to_sn);
    paramMap.put("containsSN", contains_sn);
    paramMap.put("service", service);
    paramMap.put("meta_id", new Integer(meta_id));

    if(unconstrained) paramMap.put("limit", new Integer(250));
    else paramMap.put("limit", null);

    if(showDisplay)
        rset = lc.executeQuery("message_span_display", paramMap);
    else
        rset = lc.executeQuery("message_span_meta", paramMap);

    if (!rset.isBeforeFirst()) {
        out.print("<div align=\"center\"><i>No records found.</i></div>");
    }

    String sent_color = new String();
    String received_color = new String();
    String prevSender, prevRecipient;
    prevSender = new String();
    prevRecipient = new String();
    String currentSender = new String();
    String currentRecipient = new String();

    Date currentDate = null;
    Timestamp currentTime = new Timestamp(0);

    while (rset.next()) {
        if(!rset.getDate("message_date").equals(currentDate)) {
            currentDate = rset.getDate("message_date");
            prevSender = "";
            prevRecipient = "";

            out.print("<div class=\"dateHeader\">");
            out.print(rset.getString("fancy_date"));
            out.print("</div>");
        } else if (rset.getTimestamp("message_date").getTime() -
            currentTime.getTime() > 60*10*1000) {
            out.print("<hr width=\"75%\">");
        }

        if(showMeta) {
            currentSender = rset.getString("sender_meta");
            currentRecipient = rset.getString("recipient_meta");
            sent_color = MessageFormatter.nameColor(rset.getString("sender_meta"));
            received_color = MessageFormatter.nameColor(rset.getString("recipient_meta"));
        } else {
            currentSender = rset.getString("sender_sn");
            currentRecipient = rset.getString("recipient_sn");
            sent_color = MessageFormatter.nameColor(rset.getString("sender_sn"));
            received_color = MessageFormatter.nameColor(rset.getString("recipient_sn"));
        }

        currentTime = rset.getTimestamp("message_date");

        String message = rset.getString("message");

        message = message.replaceAll("\r|\n", "<br />");
        message = message.replaceAll("   ", " &nbsp; ");

        if(!prevSender.equals(currentSender) || !prevRecipient.equals(currentRecipient)) {
            out.print("<p class=\"usernames\"><a href=\"#\"");

            out.print("title=\"" + rset.getString("sender_sn") + "\">");

            out.print("<span style=\"color: " + sent_color + "\">");
            if(showDisplay) {
                out.print(rset.getString("sender_display"));
            } else if (showMeta) {
                out.print(rset.getString("sender_meta"));
            } else {
                out.print(rset.getString("sender_sn"));
            }

            if((to_sn == null || from_sn == null) &&  contains_sn == null) {
                out.print("</span></a>");
                out.print("&rarr;");

                out.print("<a href=\"#\" title=\"" +
                        rset.getString("recipient_sn") + "\">");

                out.print("<span style=\"color: " +
                        received_color + "\">");
                if(showDisplay) {
                    out.print(rset.getString("recipient_display"));
                } else if (showMeta) {
                    out.print(rset.getString("recipient_meta"));
                } else {
                    out.print(rset.getString("recipient_sn"));
                }
            }

            out.print("</span></a>: \n</p>");
        }

        out.print("<span class=\"messages\">(" + rset.getTime("message_date") + ")&nbsp;" + message);

        if(rset.getBoolean("notes")) {

            paramMap.put("message_id", new Integer(rset.getInt("message_id")));
            noteSet = lc.executeQuery("message_notes", paramMap);

            out.print("<span style=\"color:black; background-color: yellow\">");

            while(noteSet.next()) {
                out.print("(<b>" + noteSet.getString("title") + "</b> " +
                    noteSet.getString("notes") + ") ");
            }
            out.print("</span>");

        }

        out.print("</span><br />");
        if(showMeta) {
            prevSender = rset.getString("sender_meta");
            prevRecipient = rset.getString("recipient_meta");
        } else {
            prevSender = rset.getString("sender_sn");
            prevRecipient = rset.getString("recipient_sn");
        }

        if(!rset.getDate("message_date").equals(currentDate)) {
            prevSender = "";
            prevRecipient = "";
        }

    }

}catch(SQLException e) {
    out.print("<br /><span style=\"color: red\">" + e.getMessage() + "</span>");
}
%>
</body>
</html>
