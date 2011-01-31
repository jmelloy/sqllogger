<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- $URL$ -->
<!-- $Rev$ $Date$ -->

<%

String pg = request.getParameter("page");
String mode = request.getParameter("mode");

if(pg == null) pg = "index.xml";

%>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en" dir="ltr">
    <head>
        <title>
            SQL Logger
        </title>
        <meta http-equiv="Content-Type" content="text/html; charset=(iso-8859-1" />
        <style type="text/css" media="screen" >@import url("layout/css/fixed.css");</style>
        <script type="text/javascript" src="layout/js/styleswitcher.js"></script>
        <script type="text/javascript" src="layout/js/geckostyle.js"></script>
        <link rel="stylesheet" type="text/css" href="stylesheet.css" />
    </head>
    <body>
        <div id="pgContainerWrap">
            <div id="pgContainer">
                <div id="pgHeaderContainer">
                    <div id="pgHeader">
                        <div id="pgHeaderLogoLeft">
                            <img src="layout/images/hdr_left_grn.png" width="20" height="80" alt="" />
                        </div>
                        <div id="pgHeaderLogoRight">
                            <img
                                src="layout/images/hdr_right_grn.png" width="20" height="80" alt=""/>
                        </div>
                        <h1><a href="/sqllogger/">SQL Logger</a></h1>
                    </div>
                    <h2 class="pgBlockHide">Site Navigation</h2>
                    <div id="pgTopNav">
                        <div id="pgTopNavLeft">
                            <img src="layout/images/nav_lft.png" width="7" height="23" alt="" />
                        </div>
                        <div id="pgTopNavRight">
                            <img src="layout/images/nav_rgt.png" width="7" height="23" alt="" />
                        </div>
                        <ul id="pgTopNavList">
                            <li><a href="<%= ((mode == null) ? "index.jsp?page=index.xml" : "index.html") %>">Home</a></li>
                            <li><a href="<%= ((mode == null) ? "index.jsp?page=screenshots.jsp" : "http://www.visualdistortion.org/sqllogger/?page=screenshots.jsp" )%>">
                            Screenshots</a></li>
                            <li><a href="<%= ((mode == null) ? "index.jsp?page=install.xml" : "install.html") %>">
                            Installation</a></li>
                            <li><a href="<%= ((mode == null) ? "index.jsp?page=technical.xml" : "technical.html") %>">
                            Technical Details</a></li>
                            <li><a href="<%= ((mode == null) ? "index.jsp?page=performance.xml" : "performance.html") %>">Maintenance/Performance</a></li>
                            <li><a href="<%= (( mode == null) ? "index.jsp?page=changelog.txt" : "http://www.visualdistortion.org/sqllogger/index.jsp?page=changelog.txt") %>">Changes</a></li>
                        </ul>
                    </div>
                </div>
                <div id="pgContent">
                    <div id="pgSideWrap">
                        <div id="pgSideNav">
                            <ul>
                                <li><a href="http://www.adiumx.com">Adium</a></li>
                                <ul>
                                    <li><a
                                    href="http://forums.adiumx.com">Forums</a></li>
                                    <li><a
                                    href="http://www.visualdistortion.org/sqllogger/adium_63.tar.gz">Plugin (.63)</a></li>
                                    <li class="last-child"><a
                                    href="http://www.visualdistortion.org/sqllogger/adium_70.tar.gz">Plugin (.70)</a></li>
                                </ul>
                                <li><a
                                href="http://fire.sourceforge.net">Fire</a></li>
                                <ul>
                                    <li><a
                                    href="http://fire.sourceforge.net/forums/">Forums</a></li>
                                    <li class="last-child"><a
                                    href="http://www.visualdistortion.org/sqllogger/fire_15.tar.gz">Plugin</a></li>
                                </ul>
                                <li><a
                                href="http://wwww.postgresql.org">PostgreSQL</a></li>
                                <ul>
                                    <li><a
                                    href="http://www.postgresql.org/docs/7.4/interactive/index.html">Documentation</a></li>
                                    <li><a
                                    href="http://www.xceltech.net/products/freeware_products.html">PostMan
                                    Query</a></li>
                                </ul>
                            </ul>
                        </div>
                    </div>

                    <div id="pgContentWrap">
                        <div id="pgDownloadsWrap">
                            <div id="pgDownloads">
                            <%
                                try {
                            %>
                                    <jsp:include page="<%= pg %>" />
                            <%
                                } catch (java.io.FileNotFoundException e) {
                            %>
                                    <h1>Page Not Found</h1>
                            <%
                                }
                            %>
                            </div>
                        </div>

                        <div id="pgQuickDownloadsWrap">
                            <div id="pgQuickDownloads">
                                <dl>
                                    <dt>Downloads</dt>
                                    <dd>
                                        <p><a
                                        href="sqllogger.tar.gz">WAR/HTML/Plugins</a></p>
                                        <p><a href="sqllogger.war">SQL Logger
                                        WAR</a></p>
                                    </dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                    <br class="pgClearBoth" />
                </div>
                <div id="pgFooter">

                </div>
            </div>
        </div>
    </body>
</html>
