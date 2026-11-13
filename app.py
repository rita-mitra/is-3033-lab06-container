#!/usr/bin/env python3
"""IS 3033 Lab 06: a tiny status service.

It answers one question: "what does the process serving this page look like?"
Run it on your server, then inside a container, and compare the answers.
Standard library only. No packages to install.
"""
import http.server
import os
import platform
import pwd
import socket
import sys

PORT = int(os.environ.get("PORT", "8080"))


def read_uptime():
    try:
        with open("/proc/uptime") as f:
            return f"{float(f.read().split()[0]) / 3600:.2f} hours"
    except OSError:
        return "unknown"


def os_name():
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        pass
    return platform.system()


def status_text():
    uid = os.getuid()
    try:
        user = pwd.getpwuid(uid).pw_name
    except KeyError:
        user = "unknown"
    in_container = os.path.exists("/.dockerenv")
    secret_in_env = any(k in os.environ for k in ("API_KEY", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"))
    lines = [
        "IS 3033 Lab 06 status service",
        "",
        f"hostname          : {socket.gethostname()}",
        f"running as        : {user} (uid {uid})",
        f"os userland       : {os_name()}",
        f"kernel            : {platform.release()}",
        f"python            : {sys.version.split()[0]}",
        f"uptime            : {read_uptime()}",
        f"inside a container: {'yes' if in_container else 'no'}",
        f"secret in env     : {'yes' if secret_in_env else 'no'}",
        f"pid of this server: {os.getpid()}",
        "",
    ]
    return "\n".join(lines)


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = status_text().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        sys.stdout.write("%s - %s\n" % (self.address_string(), fmt % args))
        sys.stdout.flush()


if __name__ == "__main__":
    print(f"Serving on port {PORT}", flush=True)
    http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
