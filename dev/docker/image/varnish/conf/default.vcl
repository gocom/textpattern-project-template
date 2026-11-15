vcl 4.0;

import std;

backend default {
    .host = "nginx";
    .port = "80";
    .first_byte_timeout = 600s;
}

acl purge {
    "php";
    "localhost";
}

sub vcl_recv {
    if (req.restarts > 0) {
        set req.hash_always_miss = true;
    }

    # Sort query string parameters.
    if (req.url ~ "\?.+&.+") {
        set req.url = std.querysort(req.url);
    }

    # Remove marketing and tracking query string parameters.
    if (req.url ~ "(\?|&)(gclid|cx|ie|cof|siteurl|zanpid|origin|fbclid|mc_[a-z]+|utm_[a-z]+|_bta_[a-z]+)=") {
        set req.url = regsuball(req.url, "(gclid|cx|ie|cof|siteurl|zanpid|origin|fbclid|mc_[a-z]+|utm_[a-z]+|_bta_[a-z]+)=[-_A-z0-9+()%.]+&?", "");
        set req.url = regsub(req.url, "[?|&]+$", "");
    }

    # Purge everything from the cache.
    if (req.method == "PURGEALL") {
        if (client.ip !~ purge) {
            return (synth(405, "Method not allowed"));
        }

        ban("obj.http.X-Pool ~ Textpattern");
        return (synth(200, "Flushed"));
    }

    # Purge page based on request URL, or X-Pool header.
    if (req.method == "PURGE") {
        if (client.ip !~ purge) {
            return (synth(405, "Method not allowed"));
        }

        if (!req.http.X-Pool) {
            return (purge);
        }

        ban("obj.http.X-Pool ~ " + req.http.X-Pool);
        return (synth(200, "Purged"));
    }

    # Pipe CONNECT and custom HTTP methods directly to backend.
    if (req.method != "GET"
        && req.method != "HEAD"
        && req.method != "PUT"
        && req.method != "POST"
        && req.method != "PATCH"
        && req.method != "TRACE"
        && req.method != "OPTIONS"
        && req.method != "DELETE"
    ) {
        return (pipe);
    }

    # Avoid caching non-GET and HEAD request.
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Avoid caching Textpattern CMS admin panel.
    if (req.url ~ "^/textpattern(/.+|$)") {
        return (pass);
    }

    # Avoid caching XML-RPC.
    if (req.url ~ "^/rpc(/.+|$)") {
        return (pass);
    }

    # Avoid caching requests that contain Authorization Bearer header.
    if (req.http.Authorization ~ "^Bearer") {
        return (pass);
    }

    # Avoid caching static files, instead serve them directly from HTTP server or CDN.
    if (req.url ~ "^/(images|files)/") {
        return (pass);
    }

    # Set initial grace period usage status
    set req.http.grace = "none";

    # Collect all cookies.
    std.collect(req.http.Cookie);

    return (hash);
}

sub vcl_hash {
    # Include Textpattern CMS public login cookie in the cache hash.
    if (req.http.cookie ~ "txp_login_public=") {
        hash_data(regsub(req.http.cookie, "^.*?txp_login_public=([^;]+);*.*$", "\1"));
    }

    # Include bearer token in the cache hash.
    if (req.http.Authorization ~ "^Bearer") {
        hash_data(req.http.Authorization);
    }
}

sub vcl_backend_response {
    if (!beresp.http.X-Pool) {
        set beresp.http.X-Pool = "Textpattern";
    }

    set beresp.grace = 0s;

    if (beresp.http.Content-Type ~ "text") {
        set beresp.do_esi = true;
    }

    if (bereq.url ~ "\.js$" || beresp.http.Content-Type ~ "text") {
        set beresp.do_gzip = true;
    }

    # Avoid caching non-OK responses.
    if (beresp.status != 200
        && beresp.status != 404
    ) {
        set beresp.uncacheable = true;
        set beresp.ttl = 0s;
        return (deliver);
    }

    # Avoid caching backend responses with either:
    # - Cache-Control header containing "private", "no-cache" or "no-store".
    # - Surrogate-Control header containing "no-store".
    # - Set-Cookie header set.
    # - X-Pool header containing "ignore".
    if (beresp.http.Cache-Control ~ "private|no-cache|no-store"
        || beresp.http.Surrogate-Control ~ "no-store"
        || beresp.http.Set-Cookie
        || beresp.http.X-Pool ~ "ignore"
    ) {
        set beresp.uncacheable = true;
        set beresp.ttl = 0s;
        return (deliver);
    }

    set beresp.ttl = 365d;
    return (deliver);
}

sub vcl_deliver {
    unset resp.http.X-Powered-By;
    unset resp.http.Server;
    unset resp.http.X-Varnish;
    unset resp.http.Via;
    unset resp.http.Link;
    unset resp.http.X-Pool;
}
