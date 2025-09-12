#!/usr/bin/env python3

import re
import pandas as pd

def _is_blank(x):
    """Treat NaN or empty/whitespace-only strings as blank."""
    if pd.isna(x):
        return True
    if isinstance(x, str) and x.strip() == "":
        return True
    return False

def _detect_bounds(df, start_row=2, start_col=2, row_label_col=1, col_label_row=1):
    """
    Find the bottom-right boundary of the matrix by scanning:
    - Down column `row_label_col` starting at `start_row` until first blank => last data row
    - Right along row `col_label_row` starting at `start_col` until first blank => last data col
    Returns (end_row_exclusive, end_col_exclusive).
    """
    # Rows: scan down column B (row labels)
    end_row_excl = start_row
    for r in range(start_row, df.shape[0]):
        if _is_blank(df.iat[r, row_label_col]):
            break
        end_row_excl = r + 1  # exclusive

    # Cols: scan right along row 2 (column labels)
    end_col_excl = start_col
    for c in range(start_col, df.shape[1]):
        if _is_blank(df.iat[col_label_row, c]):
            break
        end_col_excl = c + 1  # exclusive

    return end_row_excl, end_col_excl

def _parse_sheet_groups(sheet_name):
    """
    Parse a sheet name like 'Matrix 1.0' -> ('1', '0').
    If parsing fails, returns (None, None).
    """
    m = re.match(r"^\s*Matrix\s+(\d+)\.(\d+)\s*$", str(sheet_name))
    if m:
        return m.group(1), m.group(2)
    return None, None

def process_matrix_file(excel_path, output_csv):
    """
    Process sheets 2..16 (1-based), each containing a matrix:
      - ISCO occupation group labels in column B (index 1)
      - ESCO skill group labels in row 2 (index 1)
      - Values start at cell (3,3) (index [2,2]) and extend until the
        first blank label in B (rows) and the first blank header in row 2 (cols).
    Output long-format CSV with:
      ISCO_Occupation, ESCO_Skill, Value, ESCO_Group, ISCO_Group, Name
    """
    all_long = []
    xls = pd.ExcelFile(excel_path)

    # Sheets 2..16 inclusive (1-based) => indices 1..15
    for sheet_idx in range(1, 16):
        sheet_name = xls.sheet_names[sheet_idx]
        df = pd.read_excel(excel_path, sheet_name=sheet_idx, header=None)

        # Determine bounds dynamically
        end_row_excl, end_col_excl = _detect_bounds(
            df, start_row=2, start_col=2, row_label_col=1, col_label_row=1
        )

        # If nothing detected beyond headers, skip
        if end_row_excl <= 2 or end_col_excl <= 2:
            # No data area found; continue safely
            continue

        # Labels
        isco_labels = df.iloc[2:end_row_excl, 1].astype(str).str.strip()
        esco_labels = df.iloc[1, 2:end_col_excl].astype(str).str.strip().tolist()

        # Values area
        values = df.iloc[2:end_row_excl, 2:end_col_excl].copy()
        values.columns = esco_labels
        values.index = isco_labels

        # Long format
        long_df = values.reset_index().melt(
            id_vars=[values.index.name or "index"],
            var_name="ESCO_Skill",
            value_name="Value"
        )

        # Ensure the ISCO column name is correct
        long_df = long_df.rename(columns={long_df.columns[0]: "ISCO_Occupation"})

        # Parse sheet-level ESCO/ISCO identifiers from the sheet name
        sheet_esco, sheet_isco = _parse_sheet_groups(sheet_name)
        long_df["ESCO_Group"] = sheet_esco
        long_df["ESCO-ISCO_Group"] = sheet_isco
        long_df["Matrix"] = sheet_name

        all_long.append(long_df)

    # Combine and save
    if all_long:
        final_df = pd.concat(all_long, ignore_index=True)
    else:
        final_df = pd.DataFrame(columns=[
            "ISCO_Occupation", "ESCO_Skill", "Value",
            "ESCO_Group", "ESCO-ISCO_Group", "Matrix"
        ])

    final_df.to_csv(output_csv, index=False)

process_matrix_file("data_original/SS21.xlsx", "data_csv/SS21.csv")

