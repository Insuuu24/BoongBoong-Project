//
//  SignUpViewController.swift
//  BoongBoong-ProJect
//
//  Created by Insu on 2023/09/04.
//

import UIKit
import Foundation

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var plusPhotoButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var idValidationText: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationText: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    
  
    
    // MARK: - View Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        passwordTextField.isSecureTextEntry = true
        createDatePicker()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        
        //setupUI()
    }
    
    // MARK: - Helpers
    
    //    func setupUI() {
    //        // FIXME: 사진 버튼에 fill되게 수정하기
    //        plusPhotoButton.setImage(UIImage(systemName: "person.crop.circle.badge.plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
    //        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
    //        //plusPhotoButton.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
    //
    //        userNameTextField.autocorrectionType = .no
    //        userNameTextField.autocapitalizationType = .none
    //        userNameTextField.delegate = self
    //        userNameTextField.addTarget(self, action: #selector(handleTextInputChange(textField:)), for: .editingChanged)
    //
    //        passwordTextField.isSecureTextEntry = true
    //        passwordTextField.textContentType = .oneTimeCode
    //        passwordTextField.delegate = self
    //        passwordTextField.addTarget(self, action: #selector(handleTextInputChange(textField:)), for: .editingChanged)
    //
    //        signUpButton.layer.cornerRadius = 5
    //        //signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    //        signUpButton.isEnabled = false
    //        signUpButton.backgroundColor = .lightGray
    //
    //        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    //        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
    //        alreadyHaveAccountButton.setAttributedTitle(attributedTitle, for: .normal)
    //        alreadyHaveAccountButton.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
    //    }
    //
    //    private func resetInputFields() {
    //        userNameTextField.text = ""
    //        passwordTextField.text = ""
    //
    //        userNameTextField.isUserInteractionEnabled = true
    //        passwordTextField.isUserInteractionEnabled = true
    //
    //        signUpButton.isEnabled = false
    //        signUpButton.backgroundColor = .lightGray
    //    }
    //
    ////    func isUsernameTaken(_ username: String) -> Bool {
    ////        return users.contains { user in
    ////            return user.username == username
    ////        }
    ////    }
    //
    //        func validateUsername(_ username: String?) -> Bool {
    //            guard let username = username else { return false }
    //            userNameTextField.layer.borderWidth = 2.0
    //            userNameTextField.layer.cornerRadius = 7.0
    //            if username.isValidCredential {
    //                idValidationText.text = ""
    //                userNameTextField.layer.borderColor = UIColor(named: "green")?.cgColor
    //                return true
    //            } else {
    //                idValidationText.text = "영문/숫자를 포함하여 5자 이상 작성하세요."
    //                userNameTextField.layer.borderColor = UIColor(named: "red")?.cgColor
    //                return false
    //        }
    //    }
    //
    //    func validatePassword(_ password: String?) -> Bool {
    //        guard let password = password else { return false }
    //        passwordTextField.layer.borderWidth = 2.0
    //        passwordTextField.layer.cornerRadius = 7.0
    //        if password.isValidCredential {
    //            passwordValidationText.text = ""
    //            passwordTextField.layer.borderColor = UIColor(named: "green")?.cgColor
    //            return true
    //        } else {
    //            passwordValidationText.text = "영문/숫자를 포함하여 5자 이상 작성하세요."
    //            passwordTextField.layer.borderColor = UIColor(named: "red")?.cgColor
    //            return false
    //        }
    //    }
    //
    //    func validateUsernameWithoutChangingUI(_ username: String?) -> Bool {
    //        guard let username = username else { return false }
    //        if username.isValidCredential {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }
    //
    //    func validatePasswordWithoutChangingUI(_ password: String?) -> Bool {
    //        guard let password = password else { return false }
    //        if password.isValidCredential {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }
    //
    //    // MARK: - Actions
    //
    //
    
    @IBAction func plusPhotoButtonTapped(_ sender: UIButton) {
    
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            let imagePath = selectedURL.path
            print("선택한 이미지 파일의 경로: \(imagePath)")
            
        }
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let userEmail = userEmailTextField.text ?? ""
           let userPassword = passwordTextField.text ?? ""
           let userName = userNameTextField.text ?? ""
           let birthdateText = birthdateTextField.text ?? ""
        if !validateUserEmail(userEmail) {return}
        if !validatePassword(userPassword) {return}
        if !validateUserName(userName) {return}

        
      
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           
           if let birthdate = dateFormatter.date(from: birthdateText) {
               let newUser = User(email: userEmail, password: userPassword, name: userName, birthdate: birthdate, profileImage: "", isUsingKickboard: false, rideHistory: [], registeredKickboards: Kickboard(id: UUID(), registerDay: Date(), boongboongImage: "", boongboongName: "", latitude: 0.0, longitude: 0.0, isBeingUsed: false))
               
               UserDefaultsManager.shared.saveUser(newUser)
               UserDefaultsManager.shared.saveLoggedInState(true)
               
               
               print("\(newUser)")
               
               self.dismiss(animated: true, completion: nil)
           } else {
               print("회원가입이 실패하였습니다.")
           }
    }
    
    
    
    @IBAction func alreadyHaveAccountButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func showPasswordButton(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    
    func validateUserEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isEmailValid = predicate.evaluate(with: email)
        
        if !isEmailValid {
  
            idValidationText.text = "이메일 주소 형식이 올바르지 않습니다."
            userEmailTextField.layer.borderColor = UIColor(named: "red")?.cgColor
        } else {
            idValidationText.text = ""
            userEmailTextField.layer.borderColor = UIColor(named: "green")?.cgColor
        }
        
        return isEmailValid
    }
    
    
    func validatePassword(_ password: String?) -> Bool {
        guard let password = password else { return false }

        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{5,}$"

        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isPasswordValid = predicate.evaluate(with: password)

        if !isPasswordValid {
            passwordValidationText.text = "영문 대문자, 소문자, 숫자를 모두 포함하여 5자 이상 작성하세요."
            passwordTextField.layer.borderColor = UIColor(named: "red")?.cgColor
        } else {
            passwordValidationText.text = ""
            passwordTextField.layer.borderColor = UIColor(named: "green")?.cgColor
        }

        return isPasswordValid
    }
    
    
    func validateUserName(_ userName: String?) -> Bool {
        guard let userName = userName else { return false }

        let regex = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{2,5}$"

        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isUserNameValid = predicate.evaluate(with: userName)

        if !isUserNameValid {
            idValidationText.text = "한글 2~5자만 입력하세요."
            userNameTextField.layer.borderColor = UIColor(named: "red")?.cgColor
        } else {
            idValidationText.text = ""
            userNameTextField.layer.borderColor = UIColor(named: "green")?.cgColor
        }

        return isUserNameValid
    }
    
    
    //    @IBAction func userNameEditingDidBegin(_ sender: UITextField) {
    //        _ = validateUsername(sender.text)
    //        handleTextInputChange(textField: sender)
    //    }
    //
    //
    //    @IBAction func passwordEditingDidBegin(_ sender: UITextField) {
    //        _ = validateUsername(userNameTextField.text)
    //        _ = validatePassword(sender.text)
    //        handleTextInputChange(textField: sender)
    //    }
    //
    //
    //    @IBAction func showPasswordButtonTapped(_ sender: UIButton) {
    //        if passwordTextField.isSecureTextEntry {
    //            passwordTextField.isSecureTextEntry = false
    //            sender.setImage(UIImage(systemName: "eye"), for: .normal)
    //        } else {
    //            passwordTextField.isSecureTextEntry = true
    //            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    //        }
    //    }
    //
    //
    //
    //
    //    @objc private func handleTapOnView(_ sender: UITextField) {
    //        userNameTextField.resignFirstResponder()
    //        passwordTextField.resignFirstResponder()
    //    }
    //
    ////    @objc private func handlePlusPhoto() {
    ////        let imagePickerController = UIImagePickerController()
    ////        imagePickerController.delegate = self
    ////        imagePickerController.allowsEditing = true
    ////        present(imagePickerController, animated: true, completion: nil)
    ////    }
    //
    //    @objc private func handleTextInputChange(textField: UITextField) {
    //        if textField == userNameTextField {
    //            _ = validateUsername(textField.text)
    //        } else if textField == passwordTextField {
    //            _ = validatePassword(textField.text)
    //        }
    //
    //        let isUsernameValid = validateUsernameWithoutChangingUI(userNameTextField.text)
    //        let isPasswordValid = validatePasswordWithoutChangingUI(passwordTextField.text)
    //
    //        let isFormValid = isUsernameValid && isPasswordValid
    //        signUpButton.isEnabled = isFormValid
    //        signUpButton.backgroundColor = isFormValid ? .systemBlue : .lightGray
    //    }
    //
    //    @objc private func handleAlreadyHaveAccount() {
    //        self.dismiss(animated: true)
    //    }
    //
    ////    @objc private func handleSignUp() {
    ////        guard let username = userNameTextField.text else { return }
    ////        guard let password = passwordTextField.text else { return }
    ////
    ////        userNameTextField.isUserInteractionEnabled = false
    ////        passwordTextField.isUserInteractionEnabled = false
    ////
    ////        signUpButton.isEnabled = false
    ////        signUpButton.backgroundColor = UIColor.lightGray
    ////
    ////        let newUser = User(username: username, profilePhoto: profileImage ?? UIImage(systemName: "person.circle.fill")!, password: password)
    ////        if isUsernameTaken(username) {
    ////            self.resetInputFields()
    ////        } else {
    ////            users.append(newUser)
    ////            myInfo = newUser.username
    ////            print(users)
    ////            if let mainTabBarController = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
    ////                mainTabBarController.selectedIndex = 0
    ////                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
    ////                   let delegate = windowScene.delegate as? SceneDelegate,
    ////                   let window = delegate.window {
    ////                    window.rootViewController = mainTabBarController
    ////                    window.makeKeyAndVisible()
    ////                }
    ////            }
    ////        }
    ////    }
    //
    //
    //
    //
    //}
    //
    //
    ////MARK: - UIImagePickerControllerDelegate
    //
    ////extension SignUpViewController: UIImagePickerControllerDelegate {
    ////    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    ////        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    ////
    ////        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
    ////            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
    ////            profileImage = editedImage
    ////            plusPhotoButton.circleImage = true
    ////        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
    ////            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
    ////            profileImage = originalImage
    ////        }
    ////        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
    ////        dismiss(animated: true, completion: nil)
    ////    }
    ////}
    //
    //// MARK: - UITextFieldDelegate
    //
    //// TODO: username 입력완료 시 password로 위임하기
    //// TODO: usernameTextField, passwordTextField 실시간 유효성 검증 기능 추가 (아이디 중복 여부, 패스워드 유효성 여부)
    //extension SignUpViewController: UITextFieldDelegate {
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        textField.resignFirstResponder()
    //        return true
    //    }
    //}
    //
    //
    //fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    //    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    //}
    
    //    func loadImageFromPath(_ path: String) {
    //        if let image = UIImage(contentsOfFile: path) {
    //            yourProfileImageView.image = image
    //        } else {
    //            print("이미지를 불러올 수 없습니다.")
    //        }
    //    }
    //
    func createDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        
        let calendar = Calendar(identifier: .gregorian)
        var minDateComponents = DateComponents()
        minDateComponents.year = 1980
        minDateComponents.month = 1
        minDateComponents.day = 1
        datePicker.minimumDate = calendar.date(from: minDateComponents)
        
        datePicker.maximumDate = Date()

        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        birthdateTextField.inputView = datePicker
        birthdateTextField.text = dateFormat(date: Date())
        birthdateTextField.placeholder = "birthdate"
    }

    @objc func dateChange(_ sender: UIDatePicker) {
        // 값이 변하면 UIDatePicker에서 날자를 받아와 형식을 변형해서 textField에 넣어줍니다.
        birthdateTextField.text = dateFormat(date: sender.date)
    }

    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: date)
    }
}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func handleTapOnView() {
        self.view.endEditing(true)
    }
}
extension SignUpViewController: UIDocumentPickerDelegate {

}
