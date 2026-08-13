package com.dianduji.dian_du_ji

/**
 * Suppresses repeated delivery of the *same* share intent while allowing a
 * user to intentionally share the same document again later.
 *
 * Android may deliver one intent twice (for example a cold-start intent that
 * is also reported through onNewIntent), so an identical fingerprint arriving
 * inside [SUPPRESS_WINDOW_MILLIS] is treated as one delivery. A fingerprint
 * that is distinct, or the same fingerprint shared again after the window,
 * is accepted.
 */
class SharedFileDeduplicator {

    companion object {
        val SUPPORTED_MIMES = setOf(
            "text/plain",
            "application/pdf",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        )

        const val SUPPRESS_WINDOW_MILLIS = 2_000L
    }

    private var lastFingerprint: String? = null
    private var lastSeenAtMillis: Long = 0L

    fun accept(fingerprint: String, nowMillis: Long = System.currentTimeMillis()): Boolean {
        val suppressed = fingerprint == lastFingerprint &&
            nowMillis - lastSeenAtMillis < SUPPRESS_WINDOW_MILLIS
        if (suppressed) return false
        lastFingerprint = fingerprint
        lastSeenAtMillis = nowMillis
        return true
    }
}
