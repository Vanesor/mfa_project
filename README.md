# Assignment 1: Forced Alignment Pipeline with MFA

This project implements a complete forced alignment pipeline using the Montreal Forced Aligner (MFA), as required for the assignment.

This repository documents the entire process, from initial setup to encountering a critical failure, and the steps taken to solve it.

This project successfully fulfills all extra credit requirements:
1.  **Training a Custom Dictionary:** A Grapheme-to-Phoneme (G2P) model was trained to solve a fatal `AssertionError` caused by Out-of-Vocabulary (OOV) words.
2.  **Trying Multiple Acoustic Models:** A comparative analysis was performed between the `english_us_arpa` and `english_mfa` models.
3.  **Automating the Full Pipeline:** A Windows batch script (`pipeline.bat`) is provided to automate the entire successful workflow.

---

## Key Finding & Conclusion

My analysis concluded that the "older" **`english_us_arpa`** model, when combined with its custom-trained G2P model, was **significantly superior** for this dataset than the "newer" `english_mfa` package.

* **Dictionary Coverage:** The `arpa` dictionary correctly contained the word `judgeships`, which was missing from the `mfa` dictionary.
* **G2P Accuracy:** The `arpa`-trained G2P model produced highly plausible pronunciations (e.g., `JH AH1 JH SH IH2 P S` for 'judgeships'), while the `mfa`-trained G2P model produced nonsensical guesses (e.g., `d3 @ d3 I p s`).

The full, detailed analysis of this finding is available in **`final_report.pdf`**.

---

## Repository Structure

This repository is organized into experiment folders and final submission files.

* **`README.md`**: This file.
* **`final_report.pdf`**: The complete PDF report with all findings and visualizations.
* **`pipeline.bat`**: [Extra Credit] The automated script to run the *entire* successful `english_us_arpa` pipeline.
* **`Assignment1.pdf`**: The original assignment instructions.
* **`.gitignore`**: Ignores large audio files (`.wav`), trained models (`.zip`), and output folders.

### Experiment Folders

* **`test_input/`**: The primary workspace for the `english_us_arpa` model. This is the **main, successful project** and the one the `pipeline.bat` script is designed for. It contains the final automated output.
* **`model_english_mfa/`**: The workspace for the comparative analysis using the `english_mfa` model. This folder contains the **lower-quality** alignments and G2P files.
* **`model_english_ur_arpa/`**: A workspace containing the manually-run analysis for the `english_us_arpa` model. The final `.TextGrid` files in `mfa_output_english_ur_arpa/` are the **best-quality** alignments.

---

## 1. Installation

This project requires **Miniconda** and **Montreal Forced Aligner (MFA)**.

1.  **Create Conda Environment:**
    ```bash
    conda create -n mfa -c conda-forge montreal-forced-aligner
    ```
2.  **Activate Environment:**
    ```bash
    conda activate mfa
    ```

---

## 2. How to Run the Automated Pipeline

The `pipeline.bat` script in the root directory automates the *entire* successful workflow for the `english_us_arpa` model.

1.  **Download the Models:** Before running the script, you must download the `english_us_arpa` models:
    ```bash
    mfa model download dictionary english_us_arpa
    mfa model download acoustic english_us_arpa
    ```
2.  **Navigate to the `test_input` folder:** The script is designed to be run from inside the `test_input` directory.
    ```bash
    cd test_input
    ```
3.  **Run the Pipeline:** The `pipeline.bat` script (which is in the parent directory). It will:
    * Create a temporary directory (`mfa_temp/`).
    * Validate the corpus and find the OOV words.
    * Train a new G2P model (this will take ~1 hour).
    * Generate new pronunciations for the OOV words.
    * Create the final custom dictionary.
    * Run the final, successful alignment.
    * Save the `.TextGrid` files to `mfa_output_automated/`.

    ```bash
    (mfa) D:\...\test_input> ../pipeline.bat
    ```

---

## 3. Manual Process & Key Commands (For Reference)

The automated script performs the following core steps, which were discovered during the manual analysis inside the `model_english_ur_arpa` folder.

```bash
# 1. Validate the corpus (skipping acoustics to avoid crash)
# This creates the OOV file in a temp directory
mfa validate . english_us_arpa english_us_arpa --no_final_clean --clean --temporary_directory mfa_temp --ignore_acoustics

# 2. Train a G2P model (This took ~1 hour)
mfa train_g2p english_us_arpa custom_g2p_model.zip

# 3. Use the G2P model to generate pronunciations for the OOV file
# (Note: The path must be the one created by the 'validate' command)
mfa g2p mfa_temp/model_english_ur_arpa/oovs_found_english_us_arpa.txt custom_g2p_model.zip new_pronunciations.txt --clean

# 4. Combine the base dictionary with the new pronunciations
type C:\Users\vane\Documents\MFA\pretrained_models\dictionary\english_us_arpa.dict new_pronunciations.txt > final_custom_dictionary.txt

# 5. Run final, successful alignment
mfa align . final_custom_dictionary.txt english_us_arpa mfa_output_english_ur_arpa --clean
```

---

## 4. How to Inspect the Output (Praat)

The final, high-quality `.TextGrid` files are located in `model_english_ur_arpa/mfa_output_english_ur_arpa/`.

1.  Open **Praat**.
2.  Go to **Open > Read from file...** and select a `.wav` file (e.g., `model_english_ur_arpa/F2BJRLP2.wav`).
3.  Go to **Open > Read from file...** and select the matching `.TextGrid` (e.g., `model_english_ur_arpa/mfa_output_english_ur_arpa/F2BJRLP2.TextGrid`).
4.  In the "Praat Objects" window, select both the sound and the TextGrid file.
5.  Click **"View & Edit"**.

You will see the final, successful alignment, as analyzed in `final_report.pdf`.