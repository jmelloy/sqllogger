import amara
from xml.sax import SAXParseException
from message import XMLMessage

try:
    account = 'fetchgreebledonx'
    contact = 'wordaboutmehere'
    service = 'AIM'
    filename = 'paul.chatlog'
    
    doc = amara.parse(filename)

    try:
        for msg in doc.chat.message:
            m = XMLMessage(msg, account, contact, service)
            print m
            #m.insert(self.connection)
    except AttributeError:
        print "No messages"
except SAXParseException:
    print "Error: %s" % self.filename