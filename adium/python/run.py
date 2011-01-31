from message import HTMLMessageParser

f = open('paul_status.html', 'r')

data = f.read()

f.close()

x = HTMLMessageParser()

x.feed(data)

print x.messages

for m in [f for f in x.messages if f['message_type'] in ['send', 'receive']]:
    print m['sender'], m['message']