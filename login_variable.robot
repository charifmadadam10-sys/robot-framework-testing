*** Settings ***
Library    SeleniumLibrary
Library    Dialogs

*** Variables ***
${URL}         https://www.saucedemo.com/
${USERNAME}    standard_user
${PASSWORD}    secret_sauce

*** Test Cases ***
Login Success
    Open Browser    ${URL}    chrome
    Input Text      id:user-name    ${USERNAME}
    Input Password  id:password     ${PASSWORD}
    Click Button    id:login-button
    Page Should Contain    Products
    Pause Execution    Click OK to continue testing
