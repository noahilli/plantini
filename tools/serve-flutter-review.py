"""IPv4-only local review server with Flutter's OIDC callback fallback.

Never logs request URLs: authentication callbacks can contain sensitive codes.
This is a development utility, not a production web server.
"""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        # SPA routes (no file extension, no such file) fall back to the app shell,
        # like a production web server would. Includes the OIDC callbacks.
        last = path.rsplit('/', 1)[-1]
        if path in ('/auth/callback', '/auth/logout-callback') or (
            '.' not in last and not Path(self.translate_path(path)).is_file()
        ):
            self.path = '/'
        super().do_GET()

    def log_message(self, *_):
        pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', default='apps/flutter/build/demo-review')
    parser.add_argument('--port', type=int, default=3000)
    args = parser.parse_args()
    root = Path(args.directory).resolve()
    if not (root / 'index.html').is_file():
        parser.error('Build Flutter Web before starting the review server.')
    server = ThreadingHTTPServer(('127.0.0.1', args.port), partial(Handler, directory=str(root)))
    print(f'Flutter review: http://127.0.0.1:{args.port}', flush=True)
    server.serve_forever()
