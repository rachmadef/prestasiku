/**
 * Export table data to genuine Microsoft Excel (.xls) spreadsheet format
 * with custom styling, borders, and column separation.
 */
export function exportToExcel(filename: string, headers: string[], rows: (string | number | null | undefined)[][]) {
  let html = `<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">`
  html += `<head><meta charset="utf-8"><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Rekap Data</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head>`
  html += `<body style="font-family: Arial, sans-serif;"><table border="1" style="border-collapse:collapse;">`
  
  // Title / Header Row
  html += `<tr style="background-color:#001D60; color:#FFFFFF; font-weight:bold; font-size:12px; text-align:center;">`
  headers.forEach((h) => {
    const cleanH = h === null || h === undefined ? '' : String(h).replace(/</g, '&lt;').replace(/>/g, '&gt;')
    html += `<th style="padding:10px 12px; border:1px solid #94A3B8; background-color:#001D60; color:#FFFFFF;">${cleanH}</th>`
  })
  html += `</tr>`

  // Data Rows
  rows.forEach((row, idx) => {
    const bgColor = idx % 2 === 0 ? '#FFFFFF' : '#F8FAFC'
    html += `<tr style="background-color:${bgColor}; font-size:11px;">`
    row.forEach((cell) => {
      let val = cell === null || cell === undefined ? '' : String(cell)
      // Clean ISO date strings if present
      if (val.includes('T') && val.includes('Z') && val.length >= 10) {
        val = val.split('T')[0]
      }
      const cleanVal = val.replace(/</g, '&lt;').replace(/>/g, '&gt;')
      html += `<td style="padding:8px 10px; border:1px solid #CBD5E1; mso-number-format:'\\@';">${cleanVal}</td>`
    })
    html += `</tr>`
  })

  html += `</table></body></html>`

  const blob = new Blob([html], { type: 'application/vnd.ms-excel;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', `${filename}_${new Date().toISOString().split('T')[0]}.xls`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}
