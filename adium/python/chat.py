import amara
import os
import psycopg2
from message import XMLMessage
from message import Message
from message import HTMLMessageParser
from message import TXTMessageParser
from xml.sax import SAXParseException

class Chat:
    "Reads in a file and loops over the messages."
    
    def __init__(self, filename, account, contact, service, conn):
        self.filename = filename
        self.account = account
        self.contact = contact
        self.service = service
        self.connection = conn

        fn = getattr(self, "create_msg_%s" % os.path.splitext(filename)[1].strip('.'))
        
        fn()
        self.connection.commit()
        
    def create_msg_chatlog(self):
        # Logs of the format
        #<message sender="wordsaboutmehere" time="2008-02-24T12:49:08-08:00">
        # <div><span style="font-family: Lucida Grande; font-size: 12pt;">
        # My counting program is taking quite a  long time to run
        # </span></div></message>
        # Rip through with a DOM parser and pass the entire message object to
        # XMLMessage, where it is parsed into the appropriate pieces.
        try:
            doc = amara.parse(self.filename)

            try:
                for msg in doc.chat.message:
                    m = XMLMessage(msg, self.account, self.contact, self.service)
                    m.insert(self.connection)
            except AttributeError:
                print "%s: No messages" % self.filename
        except SAXParseException:
            print "Error: %s" % self.filename
            
    def create_msg_html(self):
        # Logs of the format:
        # <div class="receive">
        # <span class="timestamp">12:59:43 PM</span>
        # <span class="sender">wordsaboutmehere: </span>
        # <pre class="message">What up?</pre></div>
        # Logs are passed through whole to HTMLMessageParser, which 
        # returns a list of dicts with the various values 
        # [{'timestamp': '7:58:47 PM', 'message': 'Hmmmm', 
        # 'message_type': 'receive', 'sender': 'wordsaboutmehere'}]
        # The message_type will be send, receive, or status
        # For now we ignore status
        
        # Need to get the date from the filename
        # wordsaboutmehere (2006-11-20).html
        
        date = self.filename.split('(')[1].split(')')[0].replace("|", "-")
        
        try:            
            f = open(self.filename, 'r')
            data = f.read()
            f.close()
            
            p = HTMLMessageParser()

            p.feed(data)
            
            for msg in [f for f in p.messages
                    if f['message_type'] in ['send', 'receive']]:
                m = Message(msg['message'], 
                        self.account, self.contact, msg['sender'], 
                        self.service, date + " " + msg['timestamp'])
                m.insert(self.connection)
        except IOError:
            print "Error: %s" % self.filename
    
    def create_msg_adiumLog(self):
        # Logs of the format:
        # (00:07:25)fetchgreebledonx:Do you know how you replace spaces in a string with nothing?
        # Logs are passed to TXTMessageParser, which returns a list of dicts with 
        # timestamp, message_type, message, and sender
        # message_type will be either message or sender, and for now we ignore status
        
        date = self.filename.split('(')[1].split(')')[0].replace("|", "-")
        
        try:            
            f = open(self.filename, 'r')
            data = f.read()
            f.close()
            
            p = TXTMessageParser()
            
            p.parse(data)
            
            for msg in [f for f in p.messages
                    if f['message_type'] in ['message']]:
                m = Message(msg['message'], 
                        self.account, self.contact, msg['sender'], 
                        self.service, date + " " + msg['timestamp'])
                m.insert(self.connection)
        except IOError:
            print "Error: %s" % self.filename
        