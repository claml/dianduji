#!/usr/bin/env python3
"""API tests for the account & sync endpoints of gateway_tencent.py.

Runs the real Handler on an ephemeral port with a temp SQLite database.
No network calls are made (TENCENT / DEEPSEEK keys are not needed).

Run:  python -m unittest discover -s tests -v
"""

import json
import os
import sys
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ["DIANDUJI_SYNC_SECRET"] = "test-secret"
os.environ["DIANDUJI_SYNC_DB"] = tempfile.mktemp(suffix=".db")

import gateway_tencent as gw  # noqa: E402


class _ServerThread(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), gw.Handler)
        self.server.signer = None  # /translate not exercised here
        self.base = f"http://127.0.0.1:{self.server.server_port}"

    def run(self):
        self.server.serve_forever()


def _call(base, method, path, body=None, token=None):
    data = None
    headers = {"Content-Type": "application/json; charset=utf-8"}
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        headers["Content-Length"] = str(len(data))
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        f"{base}{path}", data=data, method=method, headers=headers
    )
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return response.status, json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as error:
        return error.code, json.loads(error.read().decode("utf-8"))


class SyncApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if os.path.exists(os.environ["DIANDUJI_SYNC_DB"]):
            os.remove(os.environ["DIANDUJI_SYNC_DB"])
        gw.init_sync_db()
        cls.thread = _ServerThread()
        cls.thread.start()
        cls.base = cls.thread.base

    def test_register_login_and_reject_duplicate(self):
        status, body = _call(
            self.base, "POST", "/auth/register",
            {"username": "alice", "password": "secret1"},
        )
        self.assertEqual(status, 201, body)
        self.assertIn("token", body)
        self.assertEqual(body["user"]["username"], "alice")

        status, _ = _call(
            self.base, "POST", "/auth/register",
            {"username": "alice", "password": "secret1"},
        )
        self.assertEqual(status, 409)

        status, body = _call(
            self.base, "POST", "/auth/login",
            {"username": "alice", "password": "secret1"},
        )
        self.assertEqual(status, 200, body)
        self.assertIn("token", body)

        status, _ = _call(
            self.base, "POST", "/auth/login",
            {"username": "alice", "password": "wrong"},
        )
        self.assertEqual(status, 401)

    def test_validation_rules(self):
        status, _ = _call(
            self.base, "POST", "/auth/register",
            {"username": "bob", "password": "123"},
        )
        self.assertEqual(status, 400)  # password too short

        status, _ = _call(self.base, "POST", "/auth/login", {})
        self.assertEqual(status, 400)

    def test_sync_roundtrip_and_last_write_wins(self):
        _, reg = _call(
            self.base, "POST", "/auth/register",
            {"username": "carol", "password": "secret1"},
        )
        token = reg["token"]

        # empty state first
        status, body = _call(self.base, "GET", "/sync/get", token=token)
        self.assertEqual(status, 200)
        self.assertIsNone(body["data"])

        # put v1
        status, body = _call(
            self.base, "POST", "/sync/put",
            {"data": {"vocabulary": ["cell"], "v": 1}, "updatedAt": 1000},
            token=token,
        )
        self.assertEqual(status, 200)
        self.assertTrue(body["accepted"])

        # put an older snapshot -> rejected, server keeps newer
        status, body = _call(
            self.base, "POST", "/sync/put",
            {"data": {"vocabulary": [], "v": 0}, "updatedAt": 500},
            token=token,
        )
        self.assertEqual(status, 200)
        self.assertFalse(body["accepted"])
        self.assertEqual(body["data"]["vocabulary"], ["cell"])

        # put v2 wins
        status, body = _call(
            self.base, "POST", "/sync/put",
            {"data": {"vocabulary": ["cell", "gene"], "v": 2}, "updatedAt": 2000},
            token=token,
        )
        self.assertEqual(status, 200)
        self.assertTrue(body["accepted"])

        status, body = _call(self.base, "GET", "/sync/get", token=token)
        self.assertEqual(status, 200)
        self.assertEqual(body["data"]["vocabulary"], ["cell", "gene"])
        self.assertEqual(body["updatedAt"], 2000)

    def test_token_is_required_and_users_are_isolated(self):
        _, alice = _call(
            self.base, "POST", "/auth/register",
            {"username": "dave", "password": "secret1"},
        )
        _, eve = _call(
            self.base, "POST", "/auth/register",
            {"username": "erin", "password": "secret1"},
        )
        _call(
            self.base, "POST", "/sync/put",
            {"data": {"mine": True}, "updatedAt": 10},
            token=alice["token"],
        )
        status, body = _call(self.base, "GET", "/sync/get", token=eve["token"])
        self.assertEqual(status, 200)
        self.assertIsNone(body["data"])

        status, _ = _call(self.base, "GET", "/sync/get")
        self.assertEqual(status, 401)

        status, _ = _call(
            self.base, "POST", "/sync/put",
            {"data": {}, "updatedAt": 1}, token="garbage.token",
        )
        self.assertEqual(status, 401)

    def test_tampered_token_is_rejected(self):
        _, reg = _call(
            self.base, "POST", "/auth/register",
            {"username": "frank", "password": "secret1"},
        )
        tampered = reg["token"][:-2] + "xx"
        status, _ = _call(self.base, "GET", "/sync/get", token=tampered)
        self.assertEqual(status, 401)

    def test_candidates_flow(self):
        # Candidates uploaded with the sync payload land in the cloud pool.
        _, reg = _call(
            self.base, "POST", "/auth/register",
            {"username": "grace", "password": "secret1"},
        )
        token = reg["token"]
        status, body = _call(
            self.base, "POST", "/sync/put",
            {
                "data": {"candidates": ["wayfinding", "navigability", "wayfinding"]},
                "updatedAt": 2000,
            },
            token=token,
        )
        self.assertEqual(status, 200)
        self.assertTrue(body["accepted"])

        # The admin lists pending candidates (deduplicated, newest first).
        status, body = _call(
            self.base, "GET", "/candidates?status=pending", token=token,
        )
        self.assertEqual(status, 200)
        surfaces = [c["surface"] for c in body["candidates"]]
        self.assertIn("wayfinding", surfaces)
        self.assertIn("navigability", surfaces)
        self.assertEqual(len(surfaces), 2)

        # Resolve one as confirmed, one dropped.
        status, _ = _call(
            self.base, "POST", "/candidates/resolve",
            {"surface": "wayfinding", "action": "confirm"}, token=token,
        )
        self.assertEqual(status, 200)
        status, _ = _call(
            self.base, "POST", "/candidates/resolve",
            {"surface": "navigability", "action": "drop"}, token=token,
        )
        self.assertEqual(status, 200)

        # Confirmed candidates come back on the next sync fetch.
        status, body = _call(self.base, "GET", "/sync/get", token=token)
        self.assertEqual(status, 200)
        confirmed = body["data"]["confirmedCandidates"]
        self.assertEqual([c["surface"] for c in confirmed], ["wayfinding"])

        # Unauthenticated management calls are rejected.
        status, _ = _call(self.base, "GET", "/candidates?status=pending")
        self.assertEqual(status, 401)


if __name__ == "__main__":
    unittest.main()
