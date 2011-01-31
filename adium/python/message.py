import amara
import re
from cStringIO import StringIO
from xml.dom import pulldom
import psycopg2
import psycopg2.extensions
from sgmllib import SGMLParser
import htmlentitydefs

class Message:
    "Holds a message object"

    def __init__(self, msg, account, contact, sender, service, timestamp):

        self.service = service

        self.sender = sender
        self.recipient = contact
        
        if self.sender == contact:
            self.recipient = account
        
        self.timestamp = timestamp

        self.message = msg


    def __str__(self):
        return "S: %s; R: %s; M: %s" % (
                self.sender, self.recipient, self.message.encode('utf-8'))

    def insert(self, conn):
        cursor = conn.cursor()

        #print self.sender + ": " + self.message

        insert = """
            INSERT INTO im.message_v
            (sender_sn, recipient_sn, message, message_date,
            sender_service, recipient_service)
            values (%(sender)s, %(recipient)s, %(message)s, %(timestamp)s,
            %(service)s, %(service)s);
            """

        params = {
                'sender': self.sender,
                'recipient': self.recipient,
                'message': self.message, #.encode('utf-8'),
                'timestamp': self.timestamp,
                'service': self.service
        }

        cursor.execute(insert, params)

class XMLMessage(Message):
    def __init__(self, msg, account, contact, service):

        self.service = service

        self.sender = msg.sender
        self.recipient = contact

        if self.sender == contact:
            self.recipient = account

        self.timestamp = msg.time

        messageData = []
        
        stream = StringIO(msg.div.xml())

        events = pulldom.parse(stream)

        el = []

        for (event, node) in events:
            #print event, node.nodeName
            if event == "CHARACTERS" and node.nodeName == "#text":
                messageData.append(node.nodeValue)
            elif event == "START_ELEMENT" and node.nodeName == "span":
                if node.hasAttribute("style"):
                    if node.getAttribute("style").find("bold") > -1:
                        el.append("</b>")
                        messageData.append("<b>")
                    elif node.getAttribute("style").find("italic") > -1:
                        el.append("</i>")
                        messageData.append("<i>")
                    elif node.getAttribute("style").find("underline") > -1:
                        el.append("</u>")
                        messageData.append("<u>")
                    else:
                        el.append("")
                else:
                    el.append("")
            elif event == "START_ELEMENT" and node.nodeName == "br":
                messageData.append("<br />")
            elif event == "START_ELEMENT" and node.nodeName != "span" and node.nodeName != "div":
                messageData.append("<%s" % (node.nodeName))
                for k in node.attributes.keys():
                    if k != "style":
                        messageData.append(' %s="%s"' % (k, node.getAttribute(k)))
                messageData.append(">")
            elif event == "END_ELEMENT" and node.nodeName == "span":
                messageData.append(el.pop())
            elif event == "END_ELEMENT" and node.nodeName != "span" and node.nodeName != "div" and node.nodeName != "br":
                messageData.append('</%s>' % node.nodeName)
        self.message = "".join(messageData).encode('utf-8')
        
class HTMLMessageParser(SGMLParser):
    def __init__(self, verbose=0):
        self.messages = []
        self.currMessage = {}
        self.currStart = None
        SGMLParser.__init__(self, verbose)
    
    def reset(self):                              
        SGMLParser.reset(self)
        self.messages = []
        self.currMessage = {}
        self.currStart = None
        self.currData = []
        
    def start_div(self, attrs):
        self.currMessage = {}
        self.currData = []
        
        l = [v for k, v in attrs if k =='class']
        if l:
            self.currMessage['message_type'] = "".join(l)
    
    def end_div(self):
        self.messages.append(self.currMessage)
        self.currMessage = {}

    def start_pre(self, attrs):
        self.currStart = "message"

    def end_pre(self):
        self.currMessage[self.currStart] = "".join(self.currData)
        self.currData = []
        self.currStart = None

    def start_span(self, attrs):
        l = [v for k, v in attrs if k =='class']
        if l:
            self.currStart = "".join(l)

    def end_span(self):
        data = "".join(self.currData)
        if self.currStart == "sender":
            data = data.strip(': ')
            
        self.currMessage[self.currStart] = data
        self.currStart = None
        self.currData = []

    def start_font(self, attrs):
        l = [v for k, v in attrs if k =='class']
        if l:
            self.currStart = "".join(l)

    def end_font(self):
        data = "".join(self.currData)
        if self.currStart == "sender":
            data = data.strip(': ')

        self.currMessage[self.currStart] = data
        self.currStart = None
        self.currData = []


    def unknown_starttag(self, tag, attrs):
        strattrs = "".join([' %s="%s"' % (key, value) for key, value in attrs])
        self.currData.append("<%(tag)s%(strattrs)s>" % locals())

    def unknown_endtag(self, tag):
        self.currData.append("</%(tag)s>" % locals())

    def handle_charref(self, ref):
        self.currData.append("&#%(ref)s;" % locals())

    def handle_entityref(self, ref):
        self.currData.append("&%(ref)s" % locals())
        if htmlentitydefs.entitydefs.has_key(ref):
            self.currData.append(";")

    def handle_data(self, text):
        self.currData.append(text)

    def handle_comment(self, text):
        self.currData.append("<!--%(text)s-->" % locals())

    def handle_pi(self, text):
        self.currData.append("<?%(text)s>" % locals())

    def handle_decl(self, text):
        self.currData.append("<!%(text)s>" % locals())

class TXTMessageParser():
    def __init__(self):
        self.messages = []
        self.currMessage = {}
        
    def parse(self, data):
        
        data = data.replace("<", "&lt;")
        data = data.replace(">", "&gt;")
        
        newLines = re.compile('\n((?!\(\d\d\:\d\d\:\d\d\)[\w\_\.\@\+\-]*\:|(\&lt\;\w*\s.*\d\d\:\d\d\:\d\d.*\&gt\;)))')
        
        lines = newLines.sub('<br />', data).split("\n")
        
        status_line = re.compile("^&lt;.*&gt;[<br />]?")
        
        time_message = re.compile('^\((?P<timestmap>\d\d\:\d\d\:\d\d)\)(?P<sender>[\w\@\_\.\+\-]*)\:(?P<message>.*)')
        time_status = re.compile('^(?P<message>&lt;.*(?P<timestamp>\d\d\:\d\d\:\d\d).*)')
        
        for i in range(1, len(lines)):
            message = lines[i]
            #print message,
            
            if status_line.match(message):
                self.currMessage = time_status.search(message).groupdict()
                self.currMessage['message_type'] = 'status'
            else:
                self.currMessage = time_message.search(message).groupdict()
                self.currMessage['message_type'] = 'message'
                
            self.messages.append(self.currMessage)
            self.currMessage = {}
                
            #print " done "