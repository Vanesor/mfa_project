@echo off
echo [----- STARTING AUTOMATED ALIGNMENT PIPELINE -----]

:: Get the name of the current directory (e.g., "test_input")
for %%i in (.) do set CORPUS_NAME=%%~ni
echo Automatically detected corpus name: %CORPUS_NAME%

:: Define a dedicated, clean temporary directory
set TEMP_DIR=mfa_temp
set CORPUS_DIR=.
set BASE_DICT_NAME=english_us_arpa
set ACOUSTIC_MODEL=english_us_arpa
set BASE_DICT_PATH=%USERPROFILE%\Documents\MFA\pretrained_models\dictionary\%BASE_DICT_NAME%.dict

:: Update OOV_FILE to point to the correct, nested path
set OOV_FILE=%TEMP_DIR%\%CORPUS_NAME%\oovs_found_%BASE_DICT_NAME%.txt

set G2P_MODEL=custom_g2p_model.zip
set NEW_PRONS=new_pronunciations.txt
set FINAL_DICT=final_custom_dictionary.txt
set OUTPUT_DIR=mfa_output_automated

:: --- START SCRIPT ---
echo.
echo [0/6] Cleaning up old temporary files...
if exist %TEMP_DIR% ( rd /S /Q %TEMP_DIR% )
mkdir %TEMP_DIR%
echo Clean temporary directory created at .\%TEMP_DIR%

echo.
echo [1/6] Validating corpus to find OOV words (skipping acoustics)...
mfa validate %CORPUS_DIR% %BASE_DICT_NAME% %ACOUSTIC_MODEL% --no_final_clean --clean --temporary_directory %TEMP_DIR% --ignore_acoustics

echo.
echo Checking for OOV file at: %OOV_FILE%
:: Check if OOV file was created
if not exist %OOV_FILE% (
    echo ERROR: OOV file was not found. mfa validate may have failed. Exiting.
    goto :eof
)
echo OOV file found successfully.

echo.
echo [2/6] Training G2P model...
mfa train_g2p %BASE_DICT_NAME% %G2P_MODEL% --temporary_directory %TEMP_DIR%

echo.
echo [3/6] Generating pronunciations for OOV words...
mfa g2p %OOV_FILE% %G2P_MODEL% %NEW_PRONS% --clean --temporary_directory %TEMP_DIR%

echo.
echo [4/6] Combining dictionaries...
:: Check if the base dictionary exists before trying to combine
if not exist "%BASE_DICT_PATH%" (
    echo ERROR: Base dictionary not found at "%BASE_DICT_PATH%"
    echo Please ensure MFA models were downloaded to the default location.
    goto :eof
)
type "%BASE_DICT_PATH%" %NEW_PRONS% > %FINAL_DICT%
echo New dictionary '%FINAL_DICT%' created.

echo.
echo [5/6] Running final alignment with custom dictionary...
mfa align %CORPUS_DIR% %FINAL_DICT% %ACOUSTIC_MODEL% %OUTPUT_DIR% --clean --temporary_directory %TEMP_DIR%

echo.
echo [6/6] ----- AUTOMATED PIPELINE COMPLETE -----
echo Final TextGrids are in the '%OUTPUT_DIR%' folder.