/*
 * $URL$
 * $Id$
 *
 * Jeffrey Melloy
 */

package org.visualdistortion.sqllogger;

import org.visualdistortion.util.Util;

/**
 * Handles various parts of the SQL Logger searching mechanism.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev$ $Date$
 **/
public class SearchUtil {

    public static String getLink(String string, String group, String group_sort, String within, String within_sort, String dateStart, String search) {

        return "<a href=\"search.jsp?" +
            "&search=" + search +
            "&group=" + Util.safeString(group) +
            "&group_sort=" + Util.safeString(group_sort) +
            "&within=" + Util.safeString(within) +
            "&within_sort=" + Util.safeString(within_sort) +
            "&start=" + Util.safeString(dateStart) +
            "\">" + Util.safeString(string) + "</a>";
    }
}
