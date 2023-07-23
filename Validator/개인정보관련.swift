struct PrivateInfoValidation {
  let specialRegexString = "!_@$%^&+=\\.\\,\\-\\_()"
  let korName = "^[가-힣]+$"
  let engName = "^[a-zA-Z]+$"
  let driveSecurity = "^[a-zA-Z0-9_.-]"
  let address = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9-\\s]+$"
  let number = "^[0-9]"
  let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
  let phoneNumber = "^([0-9]{3})-(([0-9]{3})|([0-9]{4}))-([0-9]{4})$"
  let checkDOB = "^\\d{4}-\\d{2}-\\d{2}$"
  let hasSamePattern = ".*([a-z|A-Z|0-9])\\1\\1.*"
}

// regex에 부합하는지 확인하는 함수
extension String {
    func isMatchRegex(regexString: String) -> Bool {
        var returnValue = true
        
        do {
            let string = self
            let regex = try NSRegularExpression(pattern: regexString)
            let results = regex.matches(in: string, range: NSRange(location: 0, length: string.utf16.count))
            
            if results.count == 0 {
                returnValue = false
            }
            
        } catch _ as NSError {
            returnValue = false
        }
        
        return returnValue
    }
}
