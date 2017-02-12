require 'selenium-webdriver'

# should be adjusted according to the environment if Firefox is not available in PATH
Selenium::WebDriver::Firefox::Binary.path = "/Applications/Firefox-45.app/Contents/MacOS/firefox"

# -------------------------------------------- #
# ------------ Global Variables -------------- #
# -------------------------------------------- #

$driver = Selenium::WebDriver.for :firefox
$driver.manage.window.maximize
# 15 seconds timeout variable for waiting elements during ajax calls
$wait = Selenium::WebDriver::Wait.new(:timeout => 15) 
# 25 seconds timeout variable for waiting elements during ajax calls
$waitlong = Selenium::WebDriver::Wait.new(:timeout => 25) 
# Phone number combinations to be tested
$phoneNoConditions = Array["9999999999999999999", "000000000000000","asdfasdfasdfasdfa", "+610212341234","021234567891234","0243214321"]

# -------------------------------------------- #
# ------------ METHOD DEFINITIONS ------------ #
# -------------------------------------------- #

# retrieve an html element from the path using xpath argument
#
# @param xpathArt - String
#
def findElementByXpath(xpathArg)
	
end

# clicks Edit Call Forwarding options and then 
# responds to popup modal dialog by the input argument
#
# @param decision - String
#
def clickEditnRespond (decision)
	sleep 5
	callfw = $wait.until { 
		$driver.find_element(:id, 'edit_settings_call_forwarding') 
	}
	sleep 5
	callfw.click
	sleep 5
	button = $waitlong.until {
		#$driver.find_element(:link_text, decision)
		$driver.find_element(:xpath, "//a[starts-with(@class, 'confirm_popup_#{decision}')]")
	}
	sleep 3
	button.click
	puts "---> #{decision} selected."
	sleep 5
end


# checks weather Call Forwarding options are enabled by checking the radioboxes display option
#
# @return boolean
#
def isCallFwEnabled ()
	theValue = $driver.find_element(:xpath, "//div[@class='small-1 medium-2 large-1 columns bold text-right setting-option-value-text']")
	if theValue.text().eql? "Yes" then
		puts "---> Call forwarding displayed as Yes"
		return true
	else 
		puts "---> Call forwarding displayed as No"
		return false
	end
end

# finds and returns the input element of Phone Number are in Call Forwarding Options <div> element
#
# @return html_element
#
def getPhoneTextfield ()
	sleep 3
	return $driver.find_element(:id, "my_amaysim2_setting_call_divert_number")
end

# finds and returns the radio buttons in Call Forwarding options div
#
# return radioButtons - array
def getRadioButtons()
	sleep 5 # sleep for ajax load
	radioButtons = $driver.find_elements(:xpath, "//label[@class='radio small-6 columns']")
	return radioButtons
end

# checks weather the infoPopup displayed. The Success message
#
# @returns boolean
def checkInfoPopup()
	sleep 5
	infopopup = $wait.until {
	$driver.find_elements(:xpath, "//div[@class='form_info_popup reveal-modal padding-none open']")
	}
	if infopopup.empty? == false then
		return true
	else
		return false
	end
end


# finds and returns the desired radio button in Call Forwrding Options <div> element
#
# @param choice - string
# @return radio button element
#
def selectRadioButton(choice)
	sleep 5 # sleep for ajax load
	buttons = getRadioButtons()
	if buttons[0].text == choice then
		return buttons[0]
	else
		return buttons[1]
	end
end

# checks the result of the validity that has been determined by the system
# by checking the displayed error message.
#
# @return boolean
#
def isConditionValid()
	sleep 5
	textmsg = "Please enter your phone number in the following format: 0412 345 678 or 02 1234 5678"
	spans = $wait.until {$driver.find_elements(:tag_name, 'span')}
	for i in 0..spans.size-1
		if spans[i].text()==textmsg then
			return false
		else
			if i == spans.size-1 then
				return true
			end
		end
	end
end

# inserts the phone number combination to the input text field
# and clicks on Save
#
# @param phoneNumber string
def tryCondition(phoneNumber)
	getPhoneTextfield().clear
	getPhoneTextfield().send_keys(phoneNumber)
	element = $wait.until { $driver.find_element(:name, 'commit') }
	sleep 3
	element.submit
end


# -------------------------------------------- #
# ---------------- TEST CASES ---------------- #
# -------------------------------------------- #

$driver.get('https://www.amaysim.com.au/')
loginLink = $driver.find_element(:xpath, "//a[@href='https://www.amaysim.com.au/my-account/my-amaysim/login']")
loginLink.click
$driver.find_element(:name, 'mobile_number').send_keys('0468827174')
$driver.find_element(:name, 'password').send_keys('theHoff34')
$driver.find_element(:name, 'commit').click
#---------check if login success HERE
element = $wait.until { $driver.find_element(:id, 'body-content')}
logout = $wait.until {$driver.find_element(:link_text, "Logout")}
if logout.displayed? == true then
	puts "---> login success" 
else
	puts "===> login failure! Please stop the test"
end
element.send_keys :escape # To close the first dialog
puts "---> Go to My Settings..."
element = $driver.find_elements(:xpath, "//li[@class='ama-off-canvas-section-link']") 
for item in element 
	if item.text() == "My Settings" then 
		item.click 
	end 
end
#-------check if Settings opened HERE

#element = wait.until { $driver.find_element(:id, 'edit_settings_phone_label') }
#element.click
#puts "Editing nickname"
#element = wait.until { $driver.find_element(:id, 'my_amaysim2_setting_phone_label') }
# delete the content and enter new text code here
#element.send_keys('Jesus')
#puts "Nickname changed"
#element = wait2.until { $driver.find_element(:name, 'commit') }
#element.submit
#puts "Nickname saved"


puts "---> Editing Call Forwarding..."
clickEditnRespond("confirm")
puts "---> Disabling Call Forwarding..."
selectRadioButton("No").click
puts "---> Saving..."
element = $wait.until { $driver.find_element(:name, 'commit') }
element.submit
sleep 5

puts "---> Cecking if Save was a success..."
if checkInfoPopup() == true then
	success = $driver.find_element(:xpath, "//h1[@class='ama-hero-heading popup-success white']")
	if success.displayed? then
		puts "---> Success message confirmed"
		success.send_keys :escape
		puts "---> Checking call forwarding status..."
		if isCallFwEnabled() == false then
			puts "---> DISABLED. Proceeding next test"
		else
			puts " ==> ISSUE FOUND: Even its updated as No call forwarding, it still displays Yes"
		end
	else
		puts "==> ISSUE FOUND: Success message not displayed"
	end
else
	"==> TEST BUG: Cannot find infoPopup!"
end

puts "---> Editing Call Forwarding..."
clickEditnRespond("confirm")
puts "---> Cancel editing..."
cancel = $waitlong.until{$driver.find_element(:id, "cancel_settings_call_forwarding")}
sleep 3
cancel.click
sleep 5
puts "---> Check if condition is still the same..."
if isCallFwEnabled() == false then
	puts "---> Call forwarding still disabled. Proceed next test"
else
	puts "==> ISSUE FOUND: option changed without user manipulation"
end
puts "---> Editing Call Forwarding..."
clickEditnRespond("cancel")
puts "---> Cancel option selected in popup dialog..."
if getRadioButtons().empty? == true then
	puts "---> Call forwarding options are not enabled. Proceed next test"
else
	puts "===>  ISSUE FOUND: call forwarding options shouldn't be enabled"
	#break
end

puts "---> Editing Call Forwarding..."
clickEditnRespond("confirm")
puts "---> Setting up phone numbers..."
selectRadioButton("Yes")
i = 0
while i<$phoneNoConditions.size-1 do
#for i in 0..$phoneNoConditions.size-1
	while checkInfoPopup() == false do
		tryCondition($phoneNoConditions[i].to_s)
		if isConditionValid()==false then
			value = $phoneNoConditions[i].to_s
			puts "---> Errorneus condition handled by system (#{value}). Next condition..."
			i = i+1
		else
			if isConditionValid()==true then
				puts " ---> Valid Condition saved"
				element = $wait.until { $driver.find_element(:id, 'body-content')}
				element.send_keys :escape
				return
			end
		end
	end
end
puts "--> End of Test <--"
