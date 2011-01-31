/*
 * $URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/classes/org/visualdistortion/sqllogger/MessageFormatter.java $
 * $Id: MessageFormatter.java 963 2004-12-19 00:37:21Z jmelloy $
 *
 * Jeffrey Melloy
 */

package org.visualdistortion.sqllogger;

import java.util.ArrayList;

/**
 * Determines message formatting info.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 963 $ $Date: 2004-12-18 18:37:21 -0600 (Sat, 18 Dec 2004) $
 **/
public class MessageFormatter {
    static String colorArray[] = {"red","blue","green","purple","black", "teal", "fuchsia", "gray", "lime", "maroon", "olive", "aqua", "navy"};
    static ArrayList userArray = new java.util.ArrayList();

    public static String nameColor(String username) {
        String retVar = null;

        for(int i = 0; i < userArray.size(); i++) {
            if(userArray.get(i).equals(username)) {
                retVar = colorArray[i % colorArray.length];
            }
        }

        if(retVar == null) {
            retVar = colorArray[userArray.size() % colorArray.length];
            userArray.add(username);
        }

        return retVar;
    }

    public static void clearUsers() {
        userArray.clear();
    }
}

