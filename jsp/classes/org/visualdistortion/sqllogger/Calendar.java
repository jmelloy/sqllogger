/*
 * Calendar.java
 *
 * Created on April 24, 2005, 10:16 AM
 */

package org.visualdistortion.sqllogger;

import java.io.*;
import java.net.*;

import javax.servlet.*;
import javax.servlet.http.*;

import java.sql.*;
import org.slamb.axamol.library.*;
import java.util.Map;
import java.util.HashMap;

import org.visualdistortion.util.Util;
/**
 *
 * @author jmelloy
 * @version
 */
public class Calendar extends HttpServlet {
    
    /** Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        
        int sender = Util.checkInt(request.getParameter("sender"));
        int meta_id = Util.checkInt(request.getParameter("meta_id"));
        String returnURL = Util.checkNull(request.getParameter("returnURL"));
        
        ResultSet rset = null;
        
        LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
        Map params = new HashMap();
        if(sender != 0)
            params.put("user_id", new Integer(sender));
        else
            params.put("user_id", null);
        
        if(meta_id != 0)
            params.put("meta_id", new Integer(meta_id));
        
        out.println("<table><tr>");

        try {
            if(meta_id != 0) {
                rset = lc.executeQuery("distinct_months_meta", params);
            } else {
                rset = lc.executeQuery("distinct_months_user", params);
            }
        } catch (SQLException e) {
            out.println(e);
        }
        
        String prevYear = new String();
        String months[] = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul",
            "Aug", "Sep", "Oct", "Nov", "Dec"};

        int yearCount = 0;
        int i = 1;

        try {
            while(rset.next()) {

                if(!rset.getString("year").equals(prevYear)) {

                    while(i <= 12 && rset.getRow() != 1) {
                        if((i - 1) % 4 == 0)
                            out.println("<tr>");

                        out.println("<td>" + months[i] + "</td>");

                        if(i % 4 == 0)
                            out.println("</tr>");

                        i++;
                    }

                    if(i >= 12) {
                        yearCount++;
                        out.println("</td></table>");
                        i = 1;
                        if(yearCount % 4 == 0)
                            out.println("</tr><tr>");
                    }

                    out.println("<td><table>");
                    out.println("<tr><td colspan=\"4\" align=\"center\"><b>" +
                        rset.getString("year") + "</b></td></tr>");
                }

                while(i <= 12 && i < rset.getInt("month_num")) {
                    if((i - 1) % 4 == 0)
                        out.println("<tr>");

                    out.println("<td>" + months[i] + "</td>");

                    if(i % 4 == 0)
                        out.println("</tr>");

                    i++;
                }

                if((i - 1) % 4 == 0)
                    out.println("<tr>");

                out.println("<td>");
                out.println("<a href=\"" + returnURL + "?sender=" + sender +
                    "&meta_id=" + meta_id +
                    "&start=" + rset.getString("month_start") +
                    "&finish=" + rset.getString("last_day") +
                    "\">" + rset.getString("month_abb") + "</a>");
                i++;
                out.println("</td>");

                if((i -1) % 4 == 0)
                    out.println("</tr>");

                prevYear = rset.getString("year");
            }
        } catch (SQLException e) {
            out.println(e);
        }

        while(i <= 12) {
            if((i - 1) % 4 == 0)
                out.println("<tr>");

            out.println("<td>" + months[i] + "</td>");

            if(i % 4 == 0)
                out.println("</tr>");

            i++;
        }

        out.println("</td></table>");
        if(yearCount % 4 == 0)
            out.println("</tr><tr>");


        out.println("</tr></table></td></tr></table>");

        
        out.close();
    }
    
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Returns a short description of the servlet.
     */
    public String getServletInfo() {
        return "Short description";
    }
    // </editor-fold>
}
