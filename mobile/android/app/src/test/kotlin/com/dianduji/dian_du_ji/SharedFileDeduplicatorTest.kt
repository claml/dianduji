package com.dianduji.dian_du_ji

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SharedFileDeduplicatorTest {

    private val deduplicator = SharedFileDeduplicator()

    @Test
    fun `distinct intents are all accepted`() {
        assertTrue(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_000))
        assertTrue(deduplicator.accept("send|b.txt|text/plain|20|2", nowMillis = 1_100))
    }

    @Test
    fun `identical intent inside the window is suppressed once`() {
        assertTrue(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_000))
        assertFalse(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_500))
        // A third identical delivery inside the window stays suppressed.
        assertFalse(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_900))
    }

    @Test
    fun `same document shared again after the window is accepted`() {
        assertTrue(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_000))
        assertTrue(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 10_000))
    }

    @Test
    fun `identical content under a different action is a new delivery`() {
        assertTrue(deduplicator.accept("send|a.txt|text/plain|10|1", nowMillis = 1_000))
        assertTrue(deduplicator.accept("view|a.txt|text/plain|10|1", nowMillis = 1_100))
    }

    @Test
    fun `supported mimes cover txt pdf and docx only`() {
        assertEquals(
            setOf(
                "text/plain",
                "application/pdf",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ),
            SharedFileDeduplicator.SUPPORTED_MIMES,
        )
    }
}
