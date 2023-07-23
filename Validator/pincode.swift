class PincodeValidator {
    func checkNumInStraight(_ value: String) -> Bool {
        let numbers = value.compactMap { $0.wholeNumberValue }
        
        var preNumber: Int?
        var maxCount: Int = 0
        var tempCount: Int = 0
        for number in numbers {
            if let prevNumber = preNumber {
                if abs(prevNumber - number) == 1 {
                    tempCount += 1
                } else {
                    if tempCount > maxCount {
                        maxCount = tempCount
                    }
                    tempCount = 0
                }
            }
            preNumber = number
        }
        
        if maxCount >= 3 {
            return false
        }
        return true
    }
    
    func checkNumSame(_ value: String) -> Bool {
        let regex = ".*([0-9])\\1\\1.*"
        
        if value.isMatchRegex(regexString: regex) {
            return false
        }
        return true
    }
    
    func checkBirthday(_ value: String) -> Bool {
        if value == NameCheckStore.shared.getBirthDay().value {
            return false
        }
        return true
    }

    func checkPhoneNumber(_ value: String) -> Bool {
        let phoneNumber = NameCheckStore.shared.getPhoneNumber().value
        if !phoneNumber.contains("-") {
            var changeFormat: String
            if phoneNumber.count < 11 {
                changeFormat = "XXX-XXX-XXXX"
            } else {
                changeFormat = "XXX-XXXX-XXXX"
            }
            
            let changeValue = phoneNumber.format(changeFormat)
            
            let phoneNumberItems = changeValue.split(separator: "-")
            guard let firstItem = phoneNumberItems[safe: 1],
                  let secondItem = phoneNumberItems[safe: 2] else {
                return true
            }
            
            if value.contains(firstItem) || value.contains(secondItem) {
                return false
            }
        }
        
        return true
    }
}
