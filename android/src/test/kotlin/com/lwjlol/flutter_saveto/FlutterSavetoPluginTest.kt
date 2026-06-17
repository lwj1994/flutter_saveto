package com.lwjlol.flutter_saveto

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class FlutterSavetoPluginTest {
  @Test
  fun getValidDirPath_trimsBoundarySeparators() {
    assertEquals("Reports/2026", FileSaver.getValidDirPath("/Reports/2026/"))
  }

  @Test
  fun getValidDirPath_rejectsTraversal() {
    assertFailsWith<IllegalArgumentException> {
      FileSaver.getValidDirPath("../Reports")
    }
  }
}
