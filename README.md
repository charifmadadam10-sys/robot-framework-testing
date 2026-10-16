# Robot Framework Testing (SeleniumLibrary)

เอกสารสรุปสำหรับอ่านทบทวน: เขียนเทสเว็บด้วย [Robot Framework](https://robotframework.org) + SeleniumLibrary ทดสอบเว็บ [SauceDemo](https://www.saucedemo.com)

ครอบคลุมโค้ด 6 ไฟล์ เรียงจากง่ายไปยาก:

| # | ชื่อเทส | หัวข้อที่เรียนรู้ |
|---|---|---|
| 1 | Login With Valid Credentials | เทสพื้นฐาน, `Pause Execution`, `Sleep`, `Close Browser` |
| 2 | Login Success | ตัวแปรใน `*** Variables ***` |
| 3 | Buy One Product Successfully | flow ซื้อสินค้าครบวงจร |
| 4 | Login Success / Login Failed | `Test Setup`, `Test Teardown`, Keyword แรก |
| 5 | Login With Invalid Password | เทส negative (รหัสผ่านผิด) |
| 6 | Login With Valid User | Keyword ที่รับ argument, แยกขั้นตอนเป็น Keyword |

---

## สารบัญ

1. [Robot Framework คืออะไร](#1-robot-framework-คืออะไร)
2. [การติดตั้ง](#2-การติดตั้ง)
3. [โครงสร้างโปรเจกต์](#3-โครงสร้างโปรเจกต์)
4. [สิ่งที่ต้องจำ](#4-สิ่งที่ต้องจำ)
5. [Locator และข้อมูลทดสอบ](#5-locator-และข้อมูลทดสอบ)
6. [โค้ดทั้ง 6 ไฟล์พร้อมอธิบาย](#6-โค้ดทั้ง-6-ไฟล์พร้อมอธิบาย)
7. [คำสั่งรันเทสใน Terminal](#7-คำสั่งรันเทสใน-terminal)
8. [จุดที่ควรปรับปรุง](#8-จุดที่ควรปรับปรุง)
9. [โค้ดเวอร์ชันปรับปรุงแล้ว](#9-โค้ดเวอร์ชันปรับปรุงแล้ว)
10. [เทียบกับ Cypress และ Playwright](#10-เทียบกับ-cypress-และ-playwright)

---

## 1. Robot Framework คืออะไร

เฟรมเวิร์กทดสอบที่เขียนเป็น **ภาษาคีย์เวิร์ด** (keyword-driven) อ่านเหมือนประโยค ไม่ต้องเขียนโค้ดโปรแกรมมิ่ง

- ตัวเฟรมเวิร์กเขียนด้วย Python แต่ไฟล์เทสเป็น `.robot`
- **SeleniumLibrary** คือไลบรารีที่เพิ่มคีย์เวิร์ดควบคุมเบราว์เซอร์ (เช่น `Open Browser`, `Click Button`) ผ่าน Selenium WebDriver
- ได้รายงาน `log.html` และ `report.html` ให้อัตโนมัติ

ตัวอย่างหน้าตาของเทส:

```robotframework
Login Success
    Input Text        id:user-name    standard_user
    Click Button      id:login-button
    Page Should Contain    Products
```

อ่านได้ทันทีว่า: พิมพ์ username, กดปุ่ม login, ตรวจว่าหน้ามีคำว่า Products

---

## 2. การติดตั้ง

ต้องมี **Python 3** และ **Google Chrome** ติดตั้งไว้ก่อน

```bash
# ตรวจ Python
python --version

# สร้าง virtual environment (แนะนำ)
python -m venv .venv

# เปิดใช้งาน
.venv\Scripts\activate          # Windows
source .venv/bin/activate       # macOS / Linux

# ติดตั้ง Robot Framework และ SeleniumLibrary
pip install robotframework robotframework-seleniumlibrary

# ตรวจว่าติดตั้งสำเร็จ
robot --version
pip list
```

- Selenium เวอร์ชันใหม่จัดการไดรเวอร์ของเบราว์เซอร์ (chromedriver) ให้เองอัตโนมัติ ไม่ต้องโหลดมาวางเอง
- ถ้าพิมพ์ `robot` ไม่เจอคำสั่ง ให้ใช้ `python -m robot` แทน
- แนะนำ VS Code + extension Robot Framework (เช่น RobotCode) ช่วยเติมคำและไฮไลต์โค้ด

เก็บรายการแพ็กเกจไว้ใน `requirements.txt`:

```
robotframework
robotframework-seleniumlibrary
```

```bash
pip install -r requirements.txt
```

---

## 3. โครงสร้างโปรเจกต์

ตัวอย่างการจัดโฟลเดอร์ (ชื่อไฟล์ตั้งเองได้):

```
robot/
├── tests/
│   ├── 01_login_basic.robot
│   ├── 02_login_variables.robot
│   ├── 03_buy_product.robot
│   ├── 04_setup_teardown.robot
│   ├── 05_login_invalid.robot
│   └── 06_custom_keywords.robot
├── resources/
│   └── common.resource        <- Keyword และตัวแปรที่ใช้ร่วมกัน
├── results/                   <- ผลรัน (log.html, report.html, output.xml)
├── requirements.txt
└── README.md
```

---

## 4. สิ่งที่ต้องจำ

### 4.1 กฎสำคัญที่สุด: ช่องว่าง

**คั่นแต่ละช่อง (cell) ด้วยช่องว่างอย่างน้อย 2 ตัว (แนะนำ 4)** ถ้าเว้นแค่ 1 ตัว Robot จะอ่านเป็นข้อความเดียวกัน

```robotframework
Input Text    id:user-name    standard_user      <- ถูก (เว้น 4 ช่อง)
Input Text id:user-name standard_user            <- ผิด (เว้นแค่ 1 ช่อง จะหา keyword ไม่เจอ)
```

และย่อหน้า (indent) ของบรรทัดภายในเทส/คีย์เวิร์ดต้องเยื้องเข้ามา

### 4.2 สี่ส่วนหลักของไฟล์ (Sections)

| ส่วน | หน้าที่ |
|---|---|
| `*** Settings ***` | นำเข้าไลบรารี/ไฟล์, ตั้ง Setup/Teardown |
| `*** Variables ***` | ประกาศตัวแปร |
| `*** Test Cases ***` | เขียนเทสเคส |
| `*** Keywords ***` | สร้างคีย์เวิร์ดของเราเอง |

> ชื่อ section ต้องมี `***` ครบ และไม่จำเป็นต้องมีครบทั้ง 4 ส่วน

### 4.3 ไลบรารีที่ใช้ในโค้ดนี้

| ไลบรารี | ให้อะไร |
|---|---|
| `SeleniumLibrary` | คีย์เวิร์ดควบคุมเบราว์เซอร์ |
| `Dialogs` | คีย์เวิร์ดแสดง popup เช่น `Pause Execution` |
| `BuiltIn` | มีให้อยู่แล้วไม่ต้อง import เช่น `Sleep`, `Log` |

### 4.4 ตัวแปร (Variables)

```robotframework
*** Variables ***
${URL}         https://www.saucedemo.com/
${USERNAME}    standard_user
${PASSWORD}    secret_sauce
```

| รูปแบบ | ชนิด | ตัวอย่าง |
|---|---|---|
| `${ชื่อ}` | ค่าเดี่ยว (scalar) | `${URL}` |
| `@{ชื่อ}` | รายการ (list) | `@{USERS}` |
| `&{ชื่อ}` | พจนานุกรม (dictionary) | `&{USER}` |
| `%{ชื่อ}` | ตัวแปรสภาพแวดล้อมของเครื่อง | `%{HOME}` |

- ใช้ตัวแปรโดยเขียน `${URL}` ในที่ที่ต้องการค่า
- ตัวแปรที่ประกาศใน `*** Variables ***` **ถูกเขียนทับจาก terminal ได้** ด้วย `-v` (ดูหัวข้อ 7)
- ตัวแปรในตัว: `${EMPTY}` (ข้อความว่าง), `${SPACE}` (ช่องว่าง)

> **ระวัง:** ชื่อตัวแปรใน Robot **ไม่แยกตัวพิมพ์เล็ก/ใหญ่** `${USERNAME}` กับ `${username}` คือตัวเดียวกัน ในไฟล์ที่ 6 argument `${username}` ของ Keyword `Login` จึงบังตัวแปร `${USERNAME}` ไว้ภายใน Keyword (ใช้ได้ แต่ควรตั้งชื่อต่างกัน เช่น `${login_user}` เพื่อไม่ให้สับสน)

### 4.5 คีย์เวิร์ดที่ใช้ในโค้ด

**ควบคุมเบราว์เซอร์ (SeleniumLibrary)**

| คีย์เวิร์ด | หน้าที่ |
|---|---|
| `Open Browser    URL    chrome` | เปิดเบราว์เซอร์และเข้าเว็บ |
| `Input Text    locator    ข้อความ` | พิมพ์ข้อความในช่อง |
| `Input Password    locator    รหัส` | พิมพ์รหัสผ่าน (ไม่แสดงใน log ระดับ INFO) |
| `Click Button    locator` | คลิกปุ่ม |
| `Click Element    locator` | คลิก element อะไรก็ได้ |
| `Close Browser` | ปิดเบราว์เซอร์ปัจจุบัน |

**ตรวจผล (Assertion)**

| คีย์เวิร์ด | ตรวจว่า |
|---|---|
| `Page Should Contain    ข้อความ` | หน้านี้มีข้อความนี้ |
| `Element Should Contain    locator    ข้อความ` | element นี้มีข้อความนี้เป็นส่วนหนึ่ง |

**อื่นๆ**

| คีย์เวิร์ด | หน้าที่ |
|---|---|
| `Sleep    10s` | หยุดรอ (hard wait ไม่แนะนำ) |
| `Pause Execution    ข้อความ` | หยุดแล้วเด้ง popup รอให้เรากด OK (จากไลบรารี Dialogs) |

> ชื่อคีย์เวิร์ดไม่แยกตัวพิมพ์เล็ก/ใหญ่ `CLose Browser` ในโค้ดจึงทำงานได้ แต่ควรสะกดให้ถูก

### 4.6 Setup / Teardown

| คำสั่ง | ทำงานเมื่อ |
|---|---|
| `Suite Setup` / `Suite Teardown` | ก่อน / หลัง **ทั้งไฟล์** (1 ครั้ง) |
| `Test Setup` / `Test Teardown` | ก่อน / หลัง **ทุกเทสเคส** |

ลำดับ: Suite Setup -> (Test Setup -> เทส -> Test Teardown) ซ้ำทุกเทส -> Suite Teardown

**Test Teardown จะทำงานเสมอ แม้เทส fail** จึงเหมาะกับการปิดเบราว์เซอร์

### 4.7 Keyword ที่เราสร้างเอง

```robotframework
*** Keywords ***
Login
    [Arguments]    ${username}    ${password}
    Input Text      id:user-name    ${username}
    Input Password  id:password     ${password}
    Click Button    id:login-button
```

| ส่วน | ความหมาย |
|---|---|
| ชื่อบรรทัดแรก (`Login`) | ชื่อ Keyword ชิดซ้าย |
| `[Arguments]` | ประกาศพารามิเตอร์ที่รับ |
| บรรทัดที่เหลือ | ขั้นตอนข้างใน (ต้องย่อหน้า) |

เรียกใช้ด้วย `Login    ${USERNAME}    ${PASSWORD}` เหมือนเรียกฟังก์ชัน

### 4.8 อื่นๆ

| สัญลักษณ์ | ความหมาย |
|---|---|
| `# ข้อความ` | คอมเมนต์ |
| `...` | ต่อบรรทัดของคำสั่งเดียวกัน |
| `[Tags]    smoke` | ติดแท็ก ใช้เลือกรันด้วย `-i` |
| `[Documentation]` | คำอธิบายเทส/Keyword |

---

## 5. Locator และข้อมูลทดสอบ

### รูปแบบ Locator ของ SeleniumLibrary

เขียนเป็น `ประเภท:ค่า`

| ประเภท | ตัวอย่าง | หาจาก |
|---|---|---|
| `id:` | `id:login-button` | attribute id |
| `name:` | `name:user-name` | attribute name |
| `class:` | `class:shopping_cart_badge` | class |
| `css:` | `css:[data-test="error"]` | CSS selector |
| `xpath:` | `xpath://button[text()="Login"]` | XPath |
| `link:` | `link:Sauce Labs Backpack` | ข้อความลิงก์ |
| `tag:` | `tag:h1` | ชื่อแท็ก |

### Locator ที่ใช้ในโค้ดนี้

```
id:user-name                             ช่อง username
id:password                              ช่อง password
id:login-button                          ปุ่ม Login
id:add-to-cart-sauce-labs-backpack       ปุ่มเพิ่ม Backpack ลงตะกร้า
class:shopping_cart_badge                ตัวเลขบนไอคอนตะกร้า
class:shopping_cart_link                 ไอคอนตะกร้า
id:checkout                              ปุ่ม Checkout
id:first-name                            ช่องชื่อ
id:last-name                             ช่องนามสกุล
id:postal-code                           ช่องรหัสไปรษณีย์
id:continue                              ปุ่ม Continue
id:finish                                ปุ่ม Finish
```

> เว็บ SauceDemo มีทั้ง `id` และ `data-test` ให้ใช้ ในโค้ด Cypress/Playwright ใช้ `data-test="firstName"` ส่วนโค้ด Robot นี้ใช้ id `first-name` ตัวเลือกอื่นของ Robot ที่ใช้ได้คือ `css:[data-test="firstName"]`

### ข้อมูลทดสอบ

| รายการ | ค่า |
|---|---|
| URL | `https://www.saucedemo.com/` |
| Username ถูก | `standard_user` |
| Password ถูก | `secret_sauce` |
| Password ผิด | `wrong_password` |
| ข้อมูล checkout | `Testname` / `Testsurname` / `90110` |

### ข้อความที่ใช้ตรวจ

| ข้อความ | ตรวจที่ไหน |
|---|---|
| `Products` | หน้าหลังล็อกอินสำเร็จ |
| `Username and password do not match` | error เมื่อล็อกอินผิด |
| `Sauce Labs Backpack` | สินค้าในตะกร้า/Overview |
| `Checkout: Overview` | หน้าสรุปก่อนยืนยันสั่งซื้อ |
| `Thank you for your order!` | สั่งซื้อสำเร็จ |

---

## 6. โค้ดทั้ง 6 ไฟล์พร้อมอธิบาย

### ไฟล์ 1: เทสพื้นฐาน

```robotframework
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
```

| บรรทัด | ความหมาย |
|---|---|
| `Library    SeleniumLibrary` | นำเข้าคีย์เวิร์ดควบคุมเบราว์เซอร์ |
| `Library    Dialogs` | นำเข้าคีย์เวิร์ด popup (ใช้ `Pause Execution`) |
| `Open Browser ... chrome` | เปิด Chrome เข้าเว็บ SauceDemo |
| `Input Text id:user-name ...` | พิมพ์ username |
| `Input Password id:password ...` | พิมพ์ password |
| `Click Button id:login-button` | กด Login |
| `Page Should Contain Products` | **ตรวจผล** หน้าใหม่มีคำว่า Products = login สำเร็จ |
| `Pause Execution` | เด้ง popup ให้หยุดดูหน้าเว็บ กด OK ถึงจะไปต่อ |
| `Sleep 10s` | รอ 10 วินาที |
| `CLose Browser` | ปิดเบราว์เซอร์ (สะกดผิดแต่ทำงานได้ เพราะไม่แยกตัวพิมพ์) |

บรรทัด `# CLose Browser` ที่ขึ้นต้นด้วย `#` คือคอมเมนต์ ไม่ทำงาน

### ไฟล์ 2: ใช้ตัวแปร

```robotframework
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
```

ต่างจากไฟล์ 1 ตรงที่ย้ายค่า URL, username, password ไปไว้ใน `*** Variables ***` แล้วเรียกใช้ด้วย `${...}` ข้อดีคือแก้ค่าที่เดียว และสั่งเปลี่ยนจาก terminal ได้ เช่น `robot -v USERNAME:problem_user file.robot`

### ไฟล์ 3: ซื้อสินค้า 1 ชิ้นครบวงจร

```robotframework
*** Settings ***
Library          SeleniumLibrary

*** Variables ***
${URL}           https://www.saucedemo.com/
${BROWSER}       chrome
${USERNAME}      standard_user
${PASSWORD}      secret_sauce

*** Test Cases ***
Buy One Product Successfully
    Open Browser    ${URL}    ${BROWSER}

    # Login
    Input Text        id:user-name    ${USERNAME}
    Input Password    id:password     ${PASSWORD}
    Click Button      id:login-button

    # Verify login success
    Page Should Contain    Products

    # Add 1 product to cart
    Click Button    id:add-to-cart-sauce-labs-backpack

    # Verify cart badge
    Element Should Contain    class:shopping_cart_badge    1

    # Open cart
    Click Element    class:shopping_cart_link

    # Verify product in cart
    Page Should Contain    Sauce Labs Backpack

    # Checkout
    Click Button    id:checkout

    # Enter customer information
    Input Text    id:first-name    Testname
    Input Text    id:last-name     Testsurname
    Input Text    id:postal-code   90110

    Click Button    id:continue

    # Verify checkout overview
    Page Should Contain    Checkout: Overview
    Page Should Contain    Sauce Labs Backpack

    # Complete order
    Click Button    id:finish

    # Verify order success
    Page Should Contain    Thank you for your order!

    Sleep    5s
    Close Browser
```

Flow ทั้งหมด (สังเกตว่ามี **จุดตรวจผลกำกับทุกขั้น**):

```
เปิดเว็บ -> Login -> ตรวจ Products
   -> เพิ่ม Backpack -> ตรวจ badge = 1
   -> เข้าตะกร้า -> ตรวจมี Backpack
   -> Checkout -> กรอกข้อมูล -> Continue
   -> ตรวจ Checkout: Overview + Backpack
   -> Finish -> ตรวจ Thank you for your order!
   -> Sleep 5s -> ปิดเบราว์เซอร์
```

| จุดสำคัญ | อธิบาย |
|---|---|
| `${BROWSER}` | ตัวแปรชื่อเบราว์เซอร์ เปลี่ยนได้ด้วย `-v BROWSER:firefox` |
| `# Login`, `# Checkout` ฯลฯ | คอมเมนต์แบ่งช่วง ทำให้อ่านง่าย |
| `Element Should Contain class:shopping_cart_badge 1` | ตรวจตัวเลขบนไอคอนตะกร้า (`class:` คือ locator แบบ class) |
| `Click Element` | ใช้กับไอคอนตะกร้าซึ่งไม่ใช่ปุ่ม `<button>` จึงใช้ `Click Button` ไม่ได้ |
| เส้นสุดท้าย `Close Browser` | **ถ้าเทสพังกลางทางจะไม่ถูกเรียก** เบราว์เซอร์จะค้างเปิดอยู่ (แก้ด้วย Test Teardown) |

### ไฟล์ 4: Setup / Teardown และ Keyword แรก

```robotframework
*** Settings ***
Library          SeleniumLibrary
Library          Dialogs
Test Setup       Open SauceDemo
Test Teardown    Pause Execution    Click OK to continue testing

*** Test Cases ***
Login Success
#Keyword       Locator         Value
    Input Text    id:user-name    standard_user
    Input Password    id:password    secret_sauce
    Click Button    id:login-button
    Page Should Contain   Products

Login Failed
    Input Text    id:user-name    standard_user
    Input Password    id:password    wrong_password
    Click Button    id:login-button
    Page Should Contain    Username and password do not match

*** Keywords ***
Open SauceDemo
    Open Browser    https://www.saucedemo.com/    chrome
```

| ส่วน | ความหมาย |
|---|---|
| `Test Setup    Open SauceDemo` | **ก่อนทุกเทส** ให้รัน Keyword `Open SauceDemo` (เปิดเว็บ) จึงไม่ต้องเขียน `Open Browser` ซ้ำในแต่ละเทส (คล้าย `beforeEach`) |
| `Test Teardown    Pause Execution ...` | **หลังทุกเทส** ให้เด้ง popup หยุดรอ (ใช้ตอนเดโมเพื่อดูหน้าเว็บก่อนไปเทสต่อ) |
| `*** Keywords ***` / `Open SauceDemo` | สร้าง Keyword ของเราเอง ชื่อ `Open SauceDemo` ข้างในมีคำสั่ง `Open Browser` |
| `# Keyword  Locator  Value` | คอมเมนต์บอกว่าแต่ละคอลัมน์คืออะไร |
| เทส `Login Success` | login ถูก ตรวจ `Products` |
| เทส `Login Failed` | password ผิด ตรวจข้อความ `Username and password do not match` (**เทส negative**) |

เทสนี้ผ่าน Setup/Teardown 2 รอบ (ทุกเทสละ 1 รอบ) จะเปิดเบราว์เซอร์ 2 ครั้งและเด้ง popup 2 ครั้ง เพราะไม่มีคำสั่งปิดเบราว์เซอร์ ควรเพิ่ม `Close Browser` ใน Teardown (ดูหัวข้อ 9)

### ไฟล์ 5: เทส negative (รหัสผ่านผิด)

```robotframework
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
```

เหมือน Login Failed ในไฟล์ 4 แต่เขียนเป็นเทสเดี่ยวแบบไม่ใช้ Setup บรรทัดว่างระหว่างคำสั่งทำได้ (Robot ไม่สนใจ) บรรทัด `#Close Browser` และ `#Sleep 60s` ถูกคอมเมนต์ปิดไว้

### ไฟล์ 6: Keyword ที่รับ argument

```robotframework
*** Settings ***
Library    SeleniumLibrary
Library    Dialogs

*** Variables ***
${URL}         https://www.saucedemo.com/
${USERNAME}    standard_user
${PASSWORD}    secret_sauce

*** Test Cases ***
Login With Valid User
    Open SauceDemo
    Login    ${USERNAME}    ${PASSWORD}
    Verify Login Success
    Pause Execution    Click OK to continue testing

*** Keywords ***
Open SauceDemo
    Open Browser    ${URL}    chrome

Login
    [Arguments]    ${username}    ${password}
    Input Text      id:user-name    ${username}
    Input Password  id:password     ${password}
    Click Button    id:login-button

Verify Login Success
    Page Should Contain    Products
```

**นี่คือรูปแบบที่ดีที่สุดในทั้ง 6 ไฟล์** เพราะตัวเทสเหลือแค่ 4 บรรทัดอ่านเหมือนภาษาคน:

```robotframework
Open SauceDemo
Login    ${USERNAME}    ${PASSWORD}
Verify Login Success
```

| Keyword | หน้าที่ |
|---|---|
| `Open SauceDemo` | เปิดเว็บ (ใช้ `${URL}`) |
| `Login    user    pass` | พิมพ์ username/password แล้วกด Login รับค่าผ่าน `[Arguments]` |
| `Verify Login Success` | ตรวจว่าเห็นคำว่า Products |

ข้อดี: ใช้ `Login` ซ้ำได้ด้วยข้อมูลต่างกัน (เช่นเทส negative) และถ้า locator เปลี่ยนก็แก้ที่เดียว

---

## 7. คำสั่งรันเทสใน Terminal

### พื้นฐาน

```bash
# รันไฟล์เดียว
robot tests/01_login_basic.robot

# รันทั้งโฟลเดอร์
robot tests/

# ถ้าไม่เจอคำสั่ง robot
python -m robot tests/
```

### เลือกว่าจะรันอะไร

```bash
# รันเฉพาะเทสที่ชื่อตรง (--test หรือ -t)
robot -t "Login Failed" tests/04_setup_teardown.robot

# รันเฉพาะเทสที่ชื่อมีคำว่า Login (ใช้ * เป็นตัวแทนอะไรก็ได้)
robot -t "Login*" tests/

# รันตามแท็ก (ต้องเขียน [Tags] ในเทส)
robot -i smoke tests/
robot -e negative tests/          # ยกเว้นแท็กนี้

# รันเฉพาะ suite (ไฟล์) ที่ชื่อตรง
robot -s "01_login_basic" tests/
```

### ส่งค่าตัวแปรจาก terminal

```bash
robot -v BROWSER:firefox tests/03_buy_product.robot
robot -v USERNAME:problem_user -v PASSWORD:secret_sauce tests/
```

`-v ชื่อ:ค่า` จะ **เขียนทับ** ตัวแปรในส่วน `*** Variables ***` โดยไม่ต้องแก้ไฟล์

### กำหนดที่เก็บผลลัพธ์

```bash
robot -d results tests/
```

| ไฟล์ที่ได้ | คืออะไร |
|---|---|
| `log.html` | บันทึกละเอียดทุกคำสั่ง (เปิดดูตอนเทส fail) |
| `report.html` | สรุปผลผ่าน/ไม่ผ่าน |
| `output.xml` | ผลดิบแบบ XML (ใช้กับเครื่องมืออื่น/รวมผล) |

เปิด `results/log.html` ด้วยเบราว์เซอร์เพื่อดูรายงาน

### ควบคุมการรัน

```bash
robot --exitonfailure tests/              # หยุดทันทีเมื่อเทสแรกที่ fail
robot --rerunfailed results/output.xml --output rerun.xml tests/   # รันซ้ำเฉพาะที่ fail
robot --dryrun tests/                     # ตรวจ syntax/คีย์เวิร์ด โดยไม่เปิดเบราว์เซอร์จริง
robot --loglevel DEBUG tests/             # log ละเอียดขึ้น
robot --name "SauceDemo" tests/           # ตั้งชื่อ suite ในรายงาน
```

### เบราว์เซอร์แบบไม่แสดงหน้าต่าง (headless)

แก้ที่ `Open Browser` ให้ใช้ `headlesschrome`:

```bash
robot -v BROWSER:headlesschrome tests/03_buy_product.robot
```

ชื่อเบราว์เซอร์ที่ใช้ได้: `chrome`, `firefox`, `edge`, `safari`, `headlesschrome`, `headlessfirefox`

> ไฟล์ที่ใช้ `Pause Execution` จะ **ค้างรอคนกด OK** ใช้กับ headless/CI ไม่ได้ ต้องเอาออกก่อน

### สรุปคำสั่ง

| คำสั่ง | ใช้ทำอะไร |
|---|---|
| `robot ไฟล์.robot` | รันไฟล์ |
| `robot โฟลเดอร์/` | รันทั้งโฟลเดอร์ |
| `robot -t "ชื่อเทส" ไฟล์` | รันเฉพาะเทส |
| `robot -i แท็ก` / `-e แท็ก` | รันเฉพาะ / ยกเว้นแท็ก |
| `robot -v ชื่อ:ค่า` | ส่งค่าตัวแปร |
| `robot -d โฟลเดอร์` | เก็บผลไว้ในโฟลเดอร์ |
| `robot --dryrun` | ตรวจ syntax ไม่รันจริง |
| `robot --rerunfailed output.xml` | รันซ้ำเฉพาะที่ fail |
| `robot --version` | ดูเวอร์ชัน |
| `robot --help` | ดูตัวเลือกทั้งหมด |

### ตัวอย่างผลลัพธ์ใน terminal

```
==============================================================================
04 Setup Teardown
==============================================================================
Login Success                                                         | PASS |
------------------------------------------------------------------------------
Login Failed                                                          | PASS |
------------------------------------------------------------------------------
04 Setup Teardown                                                     | PASS |
2 tests, 2 passed, 0 failed
==============================================================================
Output:  /.../output.xml
Log:     /.../log.html
Report:  /.../report.html
```

---

## 8. จุดที่ควรปรับปรุง

| ปัญหาในโค้ดเดิม | วิธีแก้ |
|---|---|
| `Sleep    10s` / `Sleep    5s` เป็น hard wait ทำให้ช้า และบางทีไม่พอ | ใช้ `Wait Until Page Contains` / `Wait Until Element Is Visible` แทน |
| `Pause Execution` ทำให้ค้างรอคนกด OK รันบน CI/headless ไม่ได้ | ใช้เฉพาะตอน debug ตอนรันจริงเอาออก |
| `Close Browser` อยู่บรรทัดสุดท้ายของเทส ถ้าเทสพังก่อนถึงจะไม่ปิด เบราว์เซอร์ค้าง | ย้ายไป `Test Teardown    Close All Browsers` (ทำงานเสมอ แม้ fail) |
| ไฟล์ 4: Setup เปิดเบราว์เซอร์ทุกเทสแต่ไม่มีการปิด | เพิ่ม `Close All Browsers` ใน Teardown |
| `CLose Browser` สะกดผิด (ทำงานได้เพราะไม่แยกตัวพิมพ์) | แก้เป็น `Close Browser` |
| ขั้นตอน Login ซ้ำในหลายไฟล์ | ใช้ Keyword `Login` ไว้ในไฟล์ `.resource` ใช้ร่วมกัน |
| `Page Should Contain    Products` ตรวจแค่ว่า "ที่ไหนสักแห่งในหน้ามีคำนี้" หลวม | เสริมด้วย `Location Should Contain    inventory.html` |
| argument `${username}` ซ้ำชื่อกับตัวแปร `${USERNAME}` (ไม่แยกตัวพิมพ์) | ตั้งชื่อ argument ให้ต่างกัน เช่น `${login_user}` |
| เทส negative เขียนแยกไฟล์/เขียนซ้ำ | ใช้ `[Template]` หรือ Keyword `Login` ส่งข้อมูลหลายชุด |
| ข้อมูลทดสอบฝังในโค้ด (ไฟล์ 1, 4, 5) | ย้ายไป `*** Variables ***` |
| ไม่ได้ใส่ `[Tags]` | ติดแท็ก (`smoke`, `negative`) เพื่อเลือกรันกลุ่มเทสได้ |
| ไฟล์ 3 ตรวจแค่ราคาไม่ได้ตรวจยอดรวม | เพิ่ม `Element Should Contain` กับ locator ของ Item total |
| `Input Password` ใช้ค่าตรงๆ ใน log ระดับ DEBUG อาจเห็นรหัสผ่าน | ใช้ตัวแปร (`${PASSWORD}`) และอย่าใช้รหัสผ่านจริงของระบบจริง |

---

## 9. โค้ดเวอร์ชันปรับปรุงแล้ว

### `resources/common.resource` (ไฟล์กลางที่ใช้ร่วมกัน)

```robotframework
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}         https://www.saucedemo.com/
${BROWSER}     chrome
${USERNAME}    standard_user
${PASSWORD}    secret_sauce

*** Keywords ***
Open SauceDemo
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:login-button    timeout=10s

Login
    [Arguments]    ${login_user}    ${login_pass}
    Input Text        id:user-name    ${login_user}
    Input Password    id:password     ${login_pass}
    Click Button      id:login-button

Verify Login Success
    Wait Until Page Contains    Products    timeout=10s
    Location Should Contain     inventory.html

Verify Login Error
    [Arguments]    ${expected_message}
    Element Should Contain    css:[data-test="error"]    ${expected_message}

Login With Default User
    Login    ${USERNAME}    ${PASSWORD}
    Verify Login Success
```

### `tests/login.robot`

```robotframework
*** Settings ***
Resource          ../resources/common.resource
Test Setup        Open SauceDemo
Test Teardown     Close All Browsers

*** Test Cases ***
Login Success
    [Tags]    login    smoke
    Login    ${USERNAME}    ${PASSWORD}
    Verify Login Success

Login With Invalid Password
    [Tags]    login    negative
    Login    ${USERNAME}    wrong_password
    Verify Login Error    Username and password do not match
```

### `tests/buy_product.robot`

```robotframework
*** Settings ***
Resource          ../resources/common.resource
Test Setup        Open SauceDemo
Test Teardown     Close All Browsers

*** Test Cases ***
Buy One Product Successfully
    [Tags]    shopping    smoke
    Login With Default User

    Click Button    id:add-to-cart-sauce-labs-backpack
    Element Should Contain    class:shopping_cart_badge    1

    Click Element    class:shopping_cart_link
    Page Should Contain    Sauce Labs Backpack

    Click Button    id:checkout
    Input Text      id:first-name     Testname
    Input Text      id:last-name      Testsurname
    Input Text      id:postal-code    90110
    Click Button    id:continue

    Page Should Contain    Checkout: Overview
    Page Should Contain    Sauce Labs Backpack

    Click Button    id:finish
    Wait Until Page Contains    Thank you for your order!    timeout=10s
```

### เทสแบบ Data-driven (ข้อมูลหลายชุด) `tests/login_invalid.robot`

ใช้ `Test Template` ให้แต่ละบรรทัดเป็นเทสแยกกัน (แต่ละแถวผ่าน Setup/Teardown ของตัวเอง)

```robotframework
*** Settings ***
Resource          ../resources/common.resource
Test Setup        Open SauceDemo
Test Teardown     Close All Browsers
Test Template     Login Should Fail

*** Test Cases ***                  USER             PASSWORD          MESSAGE
Wrong password                      standard_user    wrong_password    Username and password do not match
No username                         ${EMPTY}         secret_sauce      Username is required
No password                         standard_user    ${EMPTY}          Password is required

*** Keywords ***
Login Should Fail
    [Arguments]    ${login_user}    ${login_pass}    ${expected_message}
    Login    ${login_user}    ${login_pass}
    Verify Login Error    ${expected_message}
```

### สิ่งที่เปลี่ยน

| ที่เปลี่ยน | เหตุผล |
|---|---|
| รวม Keyword/ตัวแปรไว้ใน `common.resource` | ใช้ร่วมกันทุกไฟล์ แก้ที่เดียว |
| `Test Teardown    Close All Browsers` | ปิดเบราว์เซอร์เสมอแม้ fail ไม่ค้าง |
| `Wait Until ...` แทน `Sleep` | รอเท่าที่จำเป็น เร็วและเสถียรกว่า |
| เอา `Pause Execution` ออก | รันอัตโนมัติ/บน CI ได้ |
| ตั้งชื่อ argument ว่า `${login_user}` / `${login_pass}` | ไม่ชนกับ `${USERNAME}` / `${PASSWORD}` |
| ใส่ `[Tags]` | เลือกรันกลุ่มเทสด้วย `-i smoke` |
| `Test Template` | เพิ่มเคส negative ได้ง่าย แค่เติมบรรทัดเดียว |

รันเวอร์ชันปรับปรุง:

```bash
robot -d results tests/
robot -d results -i smoke tests/
robot -d results -v BROWSER:headlesschrome tests/
```

---

## 10. เทียบกับ Cypress และ Playwright

| งาน | Cypress | Playwright | Robot Framework |
|---|---|---|---|
| ภาษา | JavaScript | JavaScript | ภาษาคีย์เวิร์ด (`.robot`) |
| เปิดเว็บ | `cy.visit(url)` | `await page.goto(url)` | `Open Browser    ${URL}    chrome` |
| พิมพ์ | `.type('x')` | `.fill('x')` | `Input Text    locator    x` |
| คลิก | `.click()` | `.click()` | `Click Button    locator` |
| ตรวจมีข้อความ | `.should('contain', 'x')` | `toContainText('x')` | `Page Should Contain    x` |
| ก่อนทุกเทส | `beforeEach` | `test.beforeEach` | `Test Setup` |
| หลังทุกเทส | `afterEach` | `test.afterEach` | `Test Teardown` |
| ฟังก์ชันที่ใช้ซ้ำ | custom command | ฟังก์ชัน JS | `*** Keywords ***` |
| ตัวแปร | `const x` | `const x` | `${x}` |
| รันทั้งหมด | `npx cypress run` | `npx playwright test` | `robot tests/` |
| รายงาน | mochawesome / video | HTML report | `log.html` + `report.html` ในตัว |
| การรอ element | auto-retry | auto-wait | **ต้องรอเอง** (`Wait Until ...`) |

---

## ทิปเวลาเทส Fail

1. เปิด `log.html` กดดูแต่ละ keyword จะเห็นว่าพังบรรทัดไหน (สีแดง) และเห็นข้อความ error
2. SeleniumLibrary แคปภาพหน้าจอให้อัตโนมัติเมื่อเทส fail (ดูได้ใน `log.html`)
3. ตรวจ locator ด้วย DevTools (กด F12) ว่า id / class ตรงกับหน้าเว็บจริง
4. error `No keyword with name '...' found` มักเกิดจากเว้นวรรคไม่ครบ 2 ช่อง หรือยังไม่ได้ `Library` / `Resource`
5. error `Element ... not found` มักเกิดเพราะหน้ายังโหลดไม่เสร็จ ใส่ `Wait Until Element Is Visible` ก่อน
6. ใช้ `robot --dryrun` ตรวจ syntax และชื่อ keyword ก่อนรันจริง
7. ถ้าเทสค้างไม่ไปต่อ เช็คว่ามี `Pause Execution` อยู่ใน Teardown หรือไม่
