# FindMe --- Lost and Found Management System

**Repository file:** `findme-pseudocode.md`\
**Purpose:** High-level pseudocode describing the main workflows of a
lost-and-found management system.

> **Important:** This is a proposed design document based on the
> system's intended functionality. It is not the website's original
> source code or a verified description of its internal implementation.
> Matching weights, thresholds, statuses, and workflows below are
> suggested defaults and should be adjusted to match the actual
> application.

## 1. System overview

FindMe allows users to:

-   Create an account and sign in.
-   Report items they have lost.
-   Report items they have found.
-   View possible matches between lost and found reports.
-   Submit a claim for an item.
-   Receive notifications about match and claim updates.

Administrators can:

-   Review users and item reports.
-   Review potential matches.
-   Approve or reject matches.
-   Review claims and update their status.
-   Generate system reports.

## 2. Main menu

``` text
ALGORITHM FindMe_Main

BEGIN
    DISPLAY "Welcome to FindMe"

    REPEAT
        DISPLAY "1. Register"
        DISPLAY "2. Login"
        DISPLAY "3. Exit"
        INPUT choice

        CASE choice OF
            1:
                CALL Register_User()
            2:
                CALL Login_User()
            3:
                DISPLAY "Thank you for using FindMe."
            OTHERWISE:
                DISPLAY "Invalid option. Try again."
        ENDCASE
    UNTIL choice = 3
END
```

## 3. User registration

``` text
ALGORITHM Register_User

BEGIN
    INPUT full_name
    INPUT email
    INPUT password
    INPUT confirm_password

    IF any required field is empty THEN
        DISPLAY "Complete all required fields."
        RETURN
    ENDIF

    IF email already exists THEN
        DISPLAY "An account with this email already exists."
        RETURN
    ENDIF

    IF password != confirm_password THEN
        DISPLAY "Passwords do not match."
        RETURN
    ENDIF

    IF password does not meet security requirements THEN
        DISPLAY "Choose a stronger password."
        RETURN
    ENDIF

    password_hash = HASH_PASSWORD(password)

    CREATE user record:
        name = full_name
        email = email
        password_hash = password_hash
        role = "USER"
        status = "ACTIVE"

    DISPLAY "Registration successful."
END
```

## 4. User login and access control

``` text
ALGORITHM Login_User

BEGIN
    INPUT email
    INPUT password

    user = FIND_USER_BY_EMAIL(email)

    IF user does not exist THEN
        DISPLAY "Invalid email or password."
        RETURN
    ENDIF

    IF VERIFY_PASSWORD(password, user.password_hash) = FALSE THEN
        DISPLAY "Invalid email or password."
        RETURN
    ENDIF

    IF user.status != "ACTIVE" THEN
        DISPLAY "This account is not active."
        RETURN
    ENDIF

    CREATE authenticated session for user

    IF user.role = "ADMIN" THEN
        CALL Admin_Dashboard()
    ELSE
        CALL User_Dashboard()
    ENDIF
END
```

## 5. User dashboard

``` text
ALGORITHM User_Dashboard

BEGIN
    WHILE user session is active DO
        DISPLAY "USER DASHBOARD"
        DISPLAY "1. Report a lost item"
        DISPLAY "2. Report a found item"
        DISPLAY "3. View my reports"
        DISPLAY "4. View possible matches"
        DISPLAY "5. Submit or view claims"
        DISPLAY "6. View notifications"
        DISPLAY "7. Logout"

        INPUT choice

        CASE choice OF
            1:
                CALL Report_Lost_Item()
            2:
                CALL Report_Found_Item()
            3:
                CALL View_My_Reports()
            4:
                CALL View_Matches()
            5:
                CALL Manage_My_Claims()
            6:
                CALL View_Notifications()
            7:
                CALL Logout_User()
            OTHERWISE:
                DISPLAY "Invalid option."
        ENDCASE
    ENDWHILE
END
```

## 6. Report a lost item

``` text
ALGORITHM Report_Lost_Item

BEGIN
    INPUT item_name
    INPUT category
    INPUT description
    INPUT date_lost
    INPUT location_lost
    INPUT image
    user_id = CURRENT_USER_ID()

    IF item_name, category, description, date_lost, or location_lost is empty THEN
        DISPLAY "Complete all required fields."
        RETURN
    ENDIF

    VALIDATE date_lost
    VALIDATE image, if supplied

    lost_item_id = GENERATE_UNIQUE_ID()

    SAVE lost item:
        id = lost_item_id
        owner_id = user_id
        name = item_name
        category = category
        description = description
        date_lost = date_lost
        location = location_lost
        image = image
        status = "LOST"

    DISPLAY "Lost item report submitted."

    CALL Find_Matching_Items(lost_item_id)
END
```

## 7. Report a found item

``` text
ALGORITHM Report_Found_Item

BEGIN
    INPUT item_name
    INPUT category
    INPUT description
    INPUT date_found
    INPUT location_found
    INPUT image
    finder_id = CURRENT_USER_ID()

    IF item_name, category, description, date_found, or location_found is empty THEN
        DISPLAY "Complete all required fields."
        RETURN
    ENDIF

    VALIDATE date_found
    VALIDATE image, if supplied

    found_item_id = GENERATE_UNIQUE_ID()

    SAVE found item:
        id = found_item_id
        finder_id = finder_id
        name = item_name
        category = category
        description = description
        date_found = date_found
        location = location_found
        image = image
        status = "FOUND"

    DISPLAY "Found item report submitted."

    CALL Find_Matching_Items(found_item_id)
END
```

## 8. Match lost items with found items

This is a suggested matching approach. A real implementation may use
text similarity, image recognition, geolocation, or a combination of
these techniques.

``` text
ALGORITHM Find_Matching_Items(new_item_id)

BEGIN
    new_item = FIND_ITEM_BY_ID(new_item_id)

    IF new_item is a LOST item THEN
        candidates = GET_FOUND_ITEMS_WITH_STATUS("FOUND")
    ELSE IF new_item is a FOUND item THEN
        candidates = GET_LOST_ITEMS_WITH_STATUS("LOST")
    ELSE
        RETURN
    ENDIF

    FOR EACH candidate IN candidates DO
        category_score = COMPARE_CATEGORY(new_item, candidate)
        name_score = COMPARE_NAME(new_item, candidate)
        description_score = COMPARE_DESCRIPTION(new_item, candidate)
        location_score = COMPARE_LOCATION(new_item, candidate)
        date_score = COMPARE_DATE(new_item, candidate)
        image_score = COMPARE_IMAGE_IF_AVAILABLE(new_item, candidate)

        match_score =
            (category_score * 0.20) +
            (name_score * 0.15) +
            (description_score * 0.25) +
            (location_score * 0.15) +
            (date_score * 0.10) +
            (image_score * 0.15)

        IF match_score >= 0.70 THEN
            IF MATCH_RECORD_DOES_NOT_EXIST(new_item.id, candidate.id) THEN
                CREATE match record:
                    lost_item_id = ID_OF_LOST_ITEM(new_item, candidate)
                    found_item_id = ID_OF_FOUND_ITEM(new_item, candidate)
                    score = match_score
                    status = "PENDING_REVIEW"

                CALL Notify_Potential_Match(match_id)
            ENDIF
        ENDIF
    ENDFOR

    DISPLAY "Matching process completed."
END
```

**Suggested scoring interpretation:**

  Score        Suggested interpretation
  ------------ -----------------------------------------
  0.85--1.00   Strong possible match
  0.70--0.84   Possible match; review required
  Below 0.70   Do not create an automatic match record

All scores should be normalized to a value between `0` and `1`. A score
is an indication of similarity, not proof that two reports concern the
same item.

## 9. View possible matches

``` text
ALGORITHM View_Matches

BEGIN
    user_id = CURRENT_USER_ID()

    matches = GET_MATCHES_RELATED_TO_USER_ITEMS(user_id)

    IF matches is empty THEN
        DISPLAY "No possible matches are available."
        RETURN
    ENDIF

    FOR EACH match IN matches DO
        DISPLAY lost item details
        DISPLAY found item details
        DISPLAY match score
        DISPLAY match status
    ENDFOR
END
```

## 10. Administrator dashboard

``` text
ALGORITHM Admin_Dashboard

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    WHILE admin session is active DO
        DISPLAY "ADMIN DASHBOARD"
        DISPLAY "1. Manage users"
        DISPLAY "2. View lost items"
        DISPLAY "3. View found items"
        DISPLAY "4. Manage matches"
        DISPLAY "5. Manage claims"
        DISPLAY "6. Generate reports"
        DISPLAY "7. Logout"

        INPUT choice

        CASE choice OF
            1:
                CALL Manage_Users()
            2:
                CALL View_All_Lost_Items()
            3:
                CALL View_All_Found_Items()
            4:
                CALL Admin_Manage_Matches()
            5:
                CALL Manage_Claims()
            6:
                CALL Generate_Reports()
            7:
                CALL Logout_User()
            OTHERWISE:
                DISPLAY "Invalid option."
        ENDCASE
    ENDWHILE
END
```

## 11. Administrator match management

This workflow represents the proposed logic for an administrator matches
page.

``` text
ALGORITHM Admin_Manage_Matches

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    matches = GET_ALL_MATCHES()

    FOR EACH match IN matches DO
        DISPLAY lost item details
        DISPLAY found item details
        DISPLAY match score
        DISPLAY match status

        DISPLAY "1. Approve"
        DISPLAY "2. Reject"
        DISPLAY "3. View details"
        DISPLAY "4. Skip"

        INPUT admin_choice

        CASE admin_choice OF
            1:
                CALL Approve_Match(match.id)
            2:
                CALL Reject_Match(match.id)
            3:
                DISPLAY COMPLETE_MATCH_DETAILS(match.id)
            4:
                CONTINUE
            OTHERWISE:
                DISPLAY "Invalid option."
        ENDCASE
    ENDFOR
END
```

### 11.1 Approve a match

``` text
ALGORITHM Approve_Match(match_id)

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    match = FIND_MATCH_BY_ID(match_id)

    IF match does not exist THEN
        DISPLAY "Match not found."
        RETURN
    ENDIF

    IF match.status != "PENDING_REVIEW" THEN
        DISPLAY "This match cannot be approved in its current state."
        RETURN
    ENDIF

    UPDATE match.status = "APPROVED"
    SAVE match

    RECORD_ADMIN_ACTION(CURRENT_USER_ID(), "APPROVE_MATCH", match_id)

    CALL Notify_Users_Of_Approved_Match(match_id)

    DISPLAY "Match approved successfully."
END
```

### 11.2 Reject a match

``` text
ALGORITHM Reject_Match(match_id)

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    match = FIND_MATCH_BY_ID(match_id)

    IF match does not exist THEN
        DISPLAY "Match not found."
        RETURN
    ENDIF

    IF match.status != "PENDING_REVIEW" THEN
        DISPLAY "This match cannot be rejected in its current state."
        RETURN
    ENDIF

    UPDATE match.status = "REJECTED"
    SAVE match

    RECORD_ADMIN_ACTION(CURRENT_USER_ID(), "REJECT_MATCH", match_id)

    DISPLAY "Match rejected."
END
```

## 12. Notifications

``` text
ALGORITHM Notify_Potential_Match(match_id)

BEGIN
    match = FIND_MATCH_BY_ID(match_id)

    IF match does not exist THEN
        RETURN
    ENDIF

    users = GET_USERS_CONNECTED_TO_MATCH(match_id)

    FOR EACH user IN users DO
        CREATE notification:
            recipient_id = user.id
            title = "Possible item match"
            message = "A report may match your lost or found item."
            related_match_id = match_id
            read_status = FALSE

        SEND_EMAIL_OR_IN_APP_NOTIFICATION_IF_ENABLED(user, notification)
    ENDFOR
END
```

``` text
ALGORITHM Notify_Users_Of_Approved_Match(match_id)

BEGIN
    match = FIND_MATCH_BY_ID(match_id)
    users = GET_USERS_CONNECTED_TO_MATCH(match_id)

    FOR EACH user IN users DO
        CREATE notification:
            recipient_id = user.id
            title = "Match approved"
            message = "An administrator has approved a possible item match."
            related_match_id = match_id
            read_status = FALSE

        SEND_EMAIL_OR_IN_APP_NOTIFICATION_IF_ENABLED(user, notification)
    ENDFOR
END
```

## 13. Submit an item claim

``` text
ALGORITHM Submit_Item_Claim(match_id)

BEGIN
    user_id = CURRENT_USER_ID()
    match = FIND_MATCH_BY_ID(match_id)

    IF match does not exist OR match.status != "APPROVED" THEN
        DISPLAY "An approved match is required before submitting a claim."
        RETURN
    ENDIF

    IF user_id is not authorized to claim the item THEN
        DISPLAY "You are not authorized to submit this claim."
        RETURN
    ENDIF

    INPUT claim_description
    INPUT supporting_evidence

    IF claim_description is empty THEN
        DISPLAY "Provide information to support your claim."
        RETURN
    ENDIF

    claim_id = GENERATE_UNIQUE_ID()

    SAVE claim:
        id = claim_id
        match_id = match_id
        claimant_id = user_id
        description = claim_description
        evidence = supporting_evidence
        status = "PENDING_VERIFICATION"

    NOTIFY_ADMINISTRATORS(claim_id)

    DISPLAY "Claim submitted for verification."
END
```

## 14. Manage claims

``` text
ALGORITHM Manage_Claims

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    claims = GET_CLAIMS_WITH_STATUS("PENDING_VERIFICATION")

    FOR EACH claim IN claims DO
        DISPLAY claim details
        DISPLAY claimant details
        DISPLAY supporting evidence

        DISPLAY "1. Verify claim"
        DISPLAY "2. Reject claim"
        DISPLAY "3. Skip"

        INPUT choice

        IF choice = 1 THEN
            UPDATE claim.status = "VERIFIED"
            SAVE claim
            NOTIFY_CLAIMANT(claim.id)

        ELSE IF choice = 2 THEN
            UPDATE claim.status = "REJECTED"
            SAVE claim
            NOTIFY_CLAIMANT(claim.id)
        ENDIF
    ENDFOR
END
```

## 15. Mark an item as returned

``` text
ALGORITHM Mark_Item_Returned(claim_id)

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    claim = FIND_CLAIM_BY_ID(claim_id)

    IF claim does not exist OR claim.status != "VERIFIED" THEN
        DISPLAY "Claim must be verified first."
        RETURN
    ENDIF

    UPDATE claim.status = "COMPLETED"

    UPDATE related lost item status = "RETURNED"
    UPDATE related found item status = "RETURNED"

    SAVE all changes

    NOTIFY_RELEVANT_USERS(claim_id)

    DISPLAY "Item recovery recorded successfully."
END
```

## 16. View notifications

``` text
ALGORITHM View_Notifications

BEGIN
    user_id = CURRENT_USER_ID()
    notifications = GET_NOTIFICATIONS(user_id)

    IF notifications is empty THEN
        DISPLAY "You have no notifications."
        RETURN
    ENDIF

    FOR EACH notification IN notifications DO
        DISPLAY notification.title
        DISPLAY notification.message
        DISPLAY notification.created_at

        IF notification.read_status = FALSE THEN
            UPDATE notification.read_status = TRUE
        ENDIF
    ENDFOR
END
```

## 17. Generate system reports

``` text
ALGORITHM Generate_Reports

BEGIN
    VERIFY_CURRENT_USER_ROLE("ADMIN")

    total_users = COUNT_ALL_USERS()
    total_lost_items = COUNT_ALL_LOST_ITEMS()
    total_found_items = COUNT_ALL_FOUND_ITEMS()
    total_matches = COUNT_ALL_MATCHES()
    approved_matches = COUNT_MATCHES_BY_STATUS("APPROVED")
    completed_claims = COUNT_CLAIMS_BY_STATUS("COMPLETED")
    pending_claims = COUNT_CLAIMS_BY_STATUS("PENDING_VERIFICATION")

    DISPLAY "SYSTEM REPORT"
    DISPLAY total_users
    DISPLAY total_lost_items
    DISPLAY total_found_items
    DISPLAY total_matches
    DISPLAY approved_matches
    DISPLAY completed_claims
    DISPLAY pending_claims

    EXPORT_REPORT_IF_REQUESTED()
END
```

## 18. Logout

``` text
ALGORITHM Logout_User

BEGIN
    INVALIDATE_CURRENT_SESSION()
    CLEAR_AUTHENTICATED_USER_CONTEXT()
    DISPLAY "You have logged out successfully."
    REDIRECT_TO_LOGIN_PAGE()
END
```

## 19. Suggested database structure

  -----------------------------------------------------------------------
  Table                               Important fields
  ----------------------------------- -----------------------------------
  `users`                             `id`, `name`, `email`,
                                      `password_hash`, `role`, `status`

  `lost_items`                        `id`, `owner_id`, `name`,
                                      `category`, `description`,
                                      `date_lost`, `location`, `image`,
                                      `status`

  `found_items`                       `id`, `finder_id`, `name`,
                                      `category`, `description`,
                                      `date_found`, `location`, `image`,
                                      `status`

  `matches`                           `id`, `lost_item_id`,
                                      `found_item_id`, `score`, `status`,
                                      `created_at`

  `claims`                            `id`, `match_id`, `claimant_id`,
                                      `description`, `evidence`, `status`

  `notifications`                     `id`, `recipient_id`, `title`,
                                      `message`, `related_match_id`,
                                      `read_status`, `created_at`

  `admin_actions`                     `id`, `admin_id`, `action`,
                                      `record_id`, `created_at`
  -----------------------------------------------------------------------

## 20. Suggested status values

-   **Item status:** `LOST`, `FOUND`, `RETURNED`, `CLOSED`
-   **Match status:** `PENDING_REVIEW`, `APPROVED`, `REJECTED`
-   **Claim status:** `PENDING_VERIFICATION`, `VERIFIED`, `REJECTED`,
    `COMPLETED`
-   **User status:** `ACTIVE`, `SUSPENDED`

Use consistent status values throughout the application. Validate every
status transition on the server.

## 21. Security and validation requirements

1.  Store passwords using a secure password-hashing algorithm. Never
    store plain-text passwords.
2.  Enforce authentication and administrator authorization on the server
    for protected operations.
3.  Validate and sanitize all user-submitted data.
4.  Restrict uploaded file types and sizes; store uploads safely.
5.  Prevent users from viewing or claiming items they are not authorized
    to access.
6.  Keep an audit record of important administrator actions.
7.  Avoid exposing private contact details in public item listings.
8.  Use secure sessions and protect state-changing requests against CSRF
    where applicable.
9.  Prevent duplicate match records for the same lost-item and
    found-item pair.
10. Require administrator or authorized human verification before an
    item is marked as returned.

## 22. End-to-end workflow summary

``` text
START
  |
  v
Register or Login
  |
  v
Identify User Role
  |
  +------------------------------+
  |                              |
  v                              v
USER DASHBOARD               ADMIN DASHBOARD
  |                              |
  v                              v
Report Lost/Found Item       Manage Users and Reports
  |                              |
  v                              |
Save Item Record                 |
  |                              |
  v                              |
Compare Lost and Found Items     |
  |                              |
  v                              |
Create Possible Match            |
  |                              |
  v                              |
Notify Relevant Users            |
  |                              |
  +---------------+--------------+
                  |
                  v
           Admin Reviews Match
                  |
           +------+------+
           |             |
           v             v
        Approve        Reject
           |             |
           v             v
      Notify Users    Update Status
           |
           v
      Submit Claim
           |
           v
     Verify Claim
           |
           v
     Return Item
           |
           v
          END
```

## 23. Implementation note

This document is language-independent pseudocode. It can be committed to
GitHub as project documentation. It does not run as an application. To
make the live FindMe system behave this way, the pseudocode must be
implemented in the project's actual programming language, framework, and
database.
