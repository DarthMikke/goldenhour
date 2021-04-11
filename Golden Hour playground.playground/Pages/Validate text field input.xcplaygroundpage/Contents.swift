import Foundation

func validate(number no: String, min: Double? = nil, max: Double? = nil) -> Bool {
    if no == "" { return false }
    
    let legal = "-+0123456789,."
    let number = no.replacingOccurrences(of: ",", with: ".")
    var stack = number
    var separatorCount = 0
    
    while stack.count > 0 {
        let char = stack.popLast()
        if !legal.contains(char!) {
            return false
        }
        if char == "." {
            separatorCount += 1
            if separatorCount > 1 {
                return false
            }
        }
    }
    
    if min != nil {
        if Double(number)! < min! {
            return false
        }
    }
    if max != nil {
        if Double(number)! > max! {
            return false
        }
    }
    
    return true
}


print("Likestilling av . og ,")
for i in ["63.69", "63,69", "3,51", "2.17", "-24.11", "-13,75"] {
    print("\(validate(number: i, min: -180, max: 180) ? "OK" : "Feil")  \t <- \(i)")
}

print("Heile tal")
for i in ["63.0", "63,", "12"] {
    print("\(validate(number: i, min: -180, max: 180) ? "OK" : "Feil")  \t <- \(i)")
}

print("Brøkar med absoluttverdi < 1")
for i in [",74", ".13", "0,762"] {
    print("\(validate(number: i, min: -180, max: 180) ? "OK" : "Feil")  \t <- \(i)")
}

print("Fleire komma/punktum")
for i in ["52,17.2", ".,74", "0,762."] {
    // Antar false som verdi
    print("\(validate(number: i, min: -180, max: 180) ? "Feil" : "OK")  \t <- \(i)")
}

print("Bokstavar i feltet")
for i in ["fdsa,74", "%&fsdjalø.13", "0,76fdsjal2"] {
    // Antar false som verdi
    print("\(validate(number: i, min: -180, max: 180) ? "Feil" : "OK")  \t <- \(i)")
}
