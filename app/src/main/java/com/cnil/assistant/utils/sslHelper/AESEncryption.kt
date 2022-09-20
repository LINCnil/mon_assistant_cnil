package com.cnil.assistant.utils.sslHelper

import android.util.Base64
import android.util.Log
import javax.crypto.Cipher
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec


object AESEncryption {

//    fun encrypt(strToEncrypt: String, sKey: String, iv: String, salt: String): String? {
//        return crypt(
//            strToEncrypt,
//            sKey,
//            iv,
//            salt,
//            Cipher.ENCRYPT_MODE
//        )
//    }

    fun decrypt(strToEncrypt: String, sKey: String, iv: String, salt: String): String? {
        return crypt(
            strToEncrypt,
            sKey,
            iv,
            salt,
            Cipher.DECRYPT_MODE
        )
    }

    private fun crypt(strToCrypt: String, sKey: String, iv: String, salt: String, mode: Int)
            : String? {
        try {
            val ivParameterSpec = IvParameterSpec(iv.toByteArray())

            val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1")

            val spec =
                PBEKeySpec(
                    sKey.toCharArray(),
                    salt.toByteArray(),
                    10000,
                    256
                )
            val tmp = factory.generateSecret(spec)
            val secretKey = SecretKeySpec(tmp.encoded, "AES")

            val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
            cipher.init(mode, secretKey, ivParameterSpec)

            return if (mode == Cipher.ENCRYPT_MODE) {
                Base64.encodeToString(
                    cipher.doFinal(strToCrypt.toByteArray(Charsets.UTF_8)),
                    Base64.DEFAULT
                )
            } else {
                String(cipher.doFinal(Base64.decode(strToCrypt, Base64.DEFAULT)))
            }
        } catch (e: Exception) {
            Log.e("AESEncryption", e.toString())
        }
        return null
    }

}