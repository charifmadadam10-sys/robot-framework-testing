*** Settings ***
Library    SeleniumLibrary
Library    Dialogs
*** Test Cases ***
Login With Valid Credentials
    Open Browser    https://www.saucedemo.com/    chrome
    Input Text    id:user-name    standard_user
    Input Password    id:password    secret_sauce
    Click Button    id:login-button
    Page Should Contain    Products
    Pause Execution    Click OK to continue testing
    # CLose Browser    
    Sleep    10s
    CLose Browser 