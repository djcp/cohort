Feature: Contact Cart
  In order to be able to send bulk mailings
  Users will need to be able to collect contacts they wish to mail to

  Scenario: Creating a cart
    Given I am logged in
    And I am on the contact dashboard page
    When I check the contact with name "Ron Deibert"
    And I follow "Create a mailing cart"
    Then I should be on the contact cart page
    And I should see "Ron Deibert"
        
  Scenario: Emptying a cart
    Given I have already created a cart
    When I follow "Empty Contact Cart"
    And I go to the contact cart page
    Then I should see "You have no contacts in your mailer cart"
    
  Scenario: Adding to an existing cart

    
  
  
  
  
