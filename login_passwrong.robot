*** Settings ***
Library    SeleniumLibrary
Library    Dialogs
*** Test Cases ***
Login With Invalid Password

    Open Browser    https://www.saucedemo.com/    chrome

    Input Text    id:user-name    standard_user

    Input Password    id:password    wrong_password

    Click Button    id:login-button

    Page Should Contain    Username and password do not match
    Pause Execution    Click OK to continue testing
    #Close Browser
    #Sleep    60s
