/**
 * Helper function to format date strings into human-readable Indonesian format.
 * E.g., "2026-10-08T00:00:00.000000Z" -> "8 Oktober 2026"
 */
export function formatDateIndo(dateStr?: string | null): string {
  if (!dateStr) return '-'
  try {
    const match = String(dateStr).match(/^(\d{4})-(\d{2})-(\d{2})/)
    if (match) {
      const year = match[1]
      const monthIdx = parseInt(match[2], 10) - 1
      const day = parseInt(match[3], 10)
      const monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ]
      if (monthIdx >= 0 && monthIdx < 12) {
        return `${day} ${monthNames[monthIdx]} ${year}`
      }
    }

    const d = new Date(dateStr)
    if (!isNaN(d.getTime())) {
      return new Intl.DateTimeFormat('id-ID', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(d)
    }
  } catch (e) {
    // fallback
  }
  return String(dateStr).substring(0, 10)
}

/**
 * Helper function to format date range into human-readable Indonesian string.
 * E.g. "8 Oktober 2026 s.d. 20 Oktober 2026" or "8 Oktober 2026" if start == end.
 */
export function formatDateRange(startDate?: string | null, endDate?: string | null): string {
  if (!startDate) return '-'
  const formattedStart = formatDateIndo(startDate)
  if (!endDate || startDate === endDate) return formattedStart
  const formattedEnd = formatDateIndo(endDate)
  return `${formattedStart} s.d. ${formattedEnd}`
}
