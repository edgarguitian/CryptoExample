//
//  Utils.swift
//  test
//
//  Created by Edgar Guitian Rey on 10/9/24.
//

import Foundation
import CommonCrypto
import UIKit


// Guardar en la cartera de certificados (Keychain)
@discardableResult func saveKeychain(key: String, data: Data) -> OSStatus {
    let query = [
        kSecClass as String: kSecClassGenericPassword as String,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ] as [String: Any]
    SecItemDelete(query as CFDictionary)
    return SecItemAdd(query as CFDictionary, nil)
}

func loadKeychain(key: String) -> Data? {
    let query = [
        kSecClass as String: kSecClassGenericPassword as String,
        kSecAttrAccount as String: key,
        kSecReturnData as String: kCFBooleanTrue,
        kSecMatchLimit as String: kSecMatchLimitOne
    ] as [String: Any]
    var dataTypeRef: AnyObject?
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    if status == noErr {
        return dataTypeRef as! Data?
    }
    return nil
}

/* EXAMPLE loadKeychain
let cadena = "DataToSave".data(using: .utf8)!
 saveKeyChain(key: "test", data: cadena)

 let cadenaRecuperada = loadKeychain(key: "test")
 print(String(data: cadenaRecuperada, encoding: .utf8)!)
*/

// Crea un numero aleatorio cryptográfico seguro
func randomKeyGenerator(bits: Int) -> Data? {
    var randomBytes = [UInt8](repeating: 0, count: bits/8)
    let result = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if result == errSecSuccess {
        return Data(randomBytes)
    }
    return nil
}

// hash sha256
func sha256(cadena: String) -> Data? {
    guard let data = cadena.data(using: .utf8) else {
        return nil
    }
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    let _ = CC_SHA256(Array(data), UInt32(data.count), &digest)
    return Data(digest)
}

// hash hmac256
func hmac_sha256(cadena: String, key: String) -> Data? {
    guard let data = cadena.data(using: .utf8), let keyData = key.data(using: .utf8) else {
        return nil
    }
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    let _ = CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), Array(keyData), keyData.count, Array(data), data.count, &digest)
    return Data(digest)
}

/* EXAMPLE hmac_sha256
let cadena = "ClaveSuerSecreta"
let key1 = "5555"

if let hash1 = hmac_sha256(cadena: cadena, key: key1) {
    print(Array(hash1))
}

*/

// Cifrado AES256
func aes256_cbc(data: Data, key: String, /* Vector de inicialización */ inicializationVectorData: Data, operation: Int) -> Data? {
    guard var keyData = key.padding(toLength: 32, withPad: "x", startingAt: 0).data(using: .utf8) else {
        return nil
    }
    
    var cryptData = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
    let options = CCOptions(kCCOptionPKCS7Padding)
    var numBytesEncrypted = 0
    
    let cryptStatus = CCCrypt(CCOperation(operation), CCAlgorithm(kCCAlgorithmAES), options, Array(keyData), keyData.count, Array(inicializationVectorData), Array(data), data.count, &cryptData, cryptData.count, &numBytesEncrypted)
    
    if cryptStatus == kCCSuccess {
        let outputBytes = cryptData.prefix(numBytesEncrypted)
        return Data(outputBytes)
    }
    return nil
}

/* EXAMPLE aes256_cbc
 
 let dataCifrar = "ContenidoSuperSecretoMilitar"
 let key = "ClaveSuperSecreta"
 
 let inicializationVectorData = randomKeyGenerator(bits: 1024)
 saveKeyChain(key: "iv", data: inicializationVectorData) // Guardar este valor para futuros descifrados
 let datoCifrarData = datoCifrar.data(using: .utf8)!
 
 let cifrado = aes256_cbc(data: datoCifrarData, key: key, inicializationVectorData: inicializationVectorData!, operation: kCCEncrypt)
 let cifradob64 = cifrado!.base64EncodedString()
 
 let datoDescrifar = Data(base64Encoded: cifradob64)!
 
 let descifrado = aes256_cbc(data: datoDescrifrar, key: key, inicializationVectorData: inicializationVectorData!, operation: kCCDecrypt)
 print(cadenaDescifrada!)

*/

// Excluir fichero del backup
func ficheroNoCopia() {
    let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fileURL1 = docDirectory.appendingPathComponent("ficheroPrueba1.txt")
    var fileURL2 = docDirectory.appendingPathComponent("ficheroPrueba2.txt")
    
    let testString = "ejemplo"
    
    try! testString.write(to: fileURL1, atomically: true, encoding: .utf8)
    try! testString.write(to: fileURL2, atomically: true, encoding: .utf8)
    
    var config = URLResourceValues()

    config.isExcludedFromBackup = true
    do {
        try fileURL1.setResourceValues(config)
    } catch {
        print(error)
    }
}

// Copiado a portapapeles temporal de 20 segundos
func copySecure(text: String) {
    let labelProvider = text as NSItemProviderWriting
    UIPasteboard.general.setObjects([labelProvider], localOnly: true, expirationDate: Date().addingTimeInterval(20))
}

// Detectar cambios en portapapeles
/*
 NotificationCenter.default.addObserver(self, selector: #selector(clipboard(sender:)), name: NSNotification.Name.UIPasteboardChanged, object: nil)
 
 @objc func clipboard(sender: NSNotification) {
 if UIPasteboard.genera.hasStrings {
     NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIPasteboardChanged, object: nil)
     UIPasteboard.general.string = ""
     NotificationCenter.default.addObserver(self, selector: #selector(clipboard(sender:)), name: NSNotification.Name.UIPasteboardChanged, object: nil)
 }
 }
*/
 
