# Accepter
App created as an exercise when learning Swift. It uses MVVMC pattern.

App is in progress and currently works with mocked data contained in separate project. It is injected via URLProtocol from json files.

App can be used to manage expenses. Functionality:
- Add new expense: title, category, amount, attachments
- Edit expense draft
- Send draft to approval
- Delete draft
- Accept/reject expense (manager user only)
- Create new expense from photo (camera)
- On camera view it can:
  - Recognize numbers from the invoice and select one as most possible total value (with possibility to select any other)
  - Recognize text from which we can select title/category
- Attachment is analized and we can select number/text from it as amount/title/category
- Dashboard with most important data

# Used libraries/technologies
- Bond
- IQKeyboardManagerSwift
- RealmSwift
- Swinject
- SwiftMessages
- Alamofire
- Cuckoo
- UIKit (storyboards, xibs)
- Vision framework
- XCTest (unit and UI tests)

# Screenshots
<p>
<img src="/Screenshots/dashboard_manager.jpeg" tag="Dashboard for manager" title="Dashboard for manager" width="220" />
<img src="/Screenshots/dashboard_normal_user.jpeg" tag="Dashboard for normal user" title="Dashboard for normal user" width="220" />
<img src="/Screenshots/expense_list.jpeg" tag="Expense list" title="Expense list" width="220" />
<img src="/Screenshots/newly_approved.jpeg" tag="Newly approved expense" title="Newly approved expense" width="220" />
<img src="/Screenshots/swipe_send_to_approve.jpeg" tag="Send to approve with swipe" title="Send to approve with swipe" width="220" />
<img src="/Screenshots/swipe_delete_draft.jpeg" tag="Delete draft with swipe" title="Delete draft with swipe" width="220" />
<img src="/Screenshots/swipe_approve.jpeg" tag="Approve with swipe" title="Approve with swipe" width="220" />
<img src="/Screenshots/swipe_reject.jpeg" tag="Reject with swipe" title="Reject with swipe" width="220" />
<img src="/Screenshots/snackbar_undo.jpeg" tag="Snackbar with undo after operation" title="Snackbar with undo after operation" width="220" />
<img src="/Screenshots/edit_expense.jpeg" tag="Edit expense" title="Edit expense" width="220" />
<img src="/Screenshots/new_expense.jpeg" tag="New expense" title="New expense" width="220" />
<img src="/Screenshots/photo_analysis.jpeg" tag="Analysis of a photo" title="Analysis of a photo" width="220" />
<img src="/Screenshots/photo_amount_detection.jpeg" tag="Amount detection from a photo" title="Amount detection from a photo" width="220" />
<img src="/Screenshots/camera_recognize_amount.jpeg" tag="Recognize amount from camera feed" title="Recognize amount from camera feed" width="220" />
</p>
