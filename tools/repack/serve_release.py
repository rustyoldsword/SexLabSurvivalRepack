# Localhost relay for one release archive (dwemermods upload: Chrome file_upload caps at 10 MB, the site's CSP blocks
# fetch to localhost). Serves only the named file and /relay?name=X, a page that fetches the file from its own origin
# and posts the Blob to window.opener on https://dwemermods.com.  Run: python -I serve_release.py <port> <file>
import http.server
import os
import sys
import urllib.parse

PORT = int(sys.argv[1])
FILE = os.path.abspath(sys.argv[2])
NAME = os.path.basename(FILE)

RELAY = """<!doctype html><meta charset="utf-8"><title>relay</title><body>relay
<script>
fetch('/file/' + encodeURIComponent(%r)).then(r => r.blob()).then(b => {
  document.body.textContent = 'sending ' + b.size;
  window.opener.postMessage({relay: %r, blob: b}, 'https://dwemermods.com');
  document.body.textContent = 'sent ' + b.size;
}).catch(e => document.body.textContent = 'error ' + e);
</script>"""


class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        u = urllib.parse.urlparse(self.path)
        if u.path == '/relay':
            body = (RELAY % (NAME, NAME)).encode()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif urllib.parse.unquote(u.path) == '/file/' + NAME:
            self.send_response(200)
            self.send_header('Content-Type', 'application/x-7z-compressed')
            self.send_header('Content-Length', str(os.path.getsize(FILE)))
            self.end_headers()
            with open(FILE, 'rb') as f:
                while chunk := f.read(1 << 20):
                    self.wfile.write(chunk)
        else:
            self.send_error(404)

    def log_message(self, *a):
        pass


http.server.ThreadingHTTPServer(('127.0.0.1', PORT), H).serve_forever()
