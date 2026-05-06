class CsvParsing {
  /// Converts a List of Lists into a valid CSV String,
  /// handling commas inside text.
  static String listToCsv(List<List<dynamic>> rows) {
    StringBuffer sb = StringBuffer();
    for (var row in rows) {
      List<String> formattedCells = [];
      for (var cell in row) {
        String str = cell.toString();
        // If the user's note contains a comma, newline, or quote, we must wrap it in quotes
        if (str.contains(',') || str.contains('\n') || str.contains('"')) {
          str = '"${str.replaceAll('"', '""')}"';
        }
        formattedCells.add(str);
      }
      sb.writeln(formattedCells.join(','));
    }
    return sb.toString();
  }

  /// Parses a CSV string into a List of Lists,
  /// correctly ignoring commas inside quotes.
  static List<List<String>> parseCsv(String csvString) {
    List<List<String>> rows = [];
    List<String> currentRow = [];
    StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csvString.length; i++) {
      String char = csvString[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < csvString.length && csvString[i + 1] == '"') {
            currentCell.write('"'); // Escaped quote inside text
            i++;
          } else {
            inQuotes = false; // End of quoted text
          }
        } else {
          currentCell.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
        } else if (char == '\n' || char == '\r') {
          if (char == '\r' &&
              i + 1 < csvString.length &&
              csvString[i + 1] == '\n') {
            i++; // Skip standard Windows \r\n
          }
          currentRow.add(currentCell.toString());
          rows.add(currentRow);
          currentRow = [];
          currentCell.clear();
        } else {
          currentCell.write(char);
        }
      }
    }

    // Add the final cell/row if the file doesn't end with a newline
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      rows.add(currentRow);
    }

    return rows;
  }
}
