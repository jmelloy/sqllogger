<%@ page import = 'java.util.Enumeration' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%
Enumeration e = request.getParameterNames();
%>
<html>
    <head><title>Save <%= Util.safeString(request.getParameter("type")) %></title></head>
    <body>
        <form action="SaveFormItems" method="get">
            <label for="title"><b>Name</b></label><br />
            <input type="text" name="title" size="30" /><br /><br />

            <label for="notes"><b>Notes</b></label><br />
            <textarea rows="6" cols="30" name="notes"></textarea><br />
            <br />
<%
while(e.hasMoreElements()) {
    String key = (String) e.nextElement();
    String value = request.getParameter(key);
    if(value != null && !value.equals("")) {
        out.println("<input type=\"hidden\" name=\"" + key + "\" " +
                "value=\"" + value + "\" />");
    }
}
%>
            <div align="right">
                <input type="submit">
            </div>
        </form>

    </body>
</html>
