package com.cnil.assistant.utils.sslHelper

import java.io.InputStream
import java.security.KeyStore
import java.security.cert.CertificateFactory
import javax.net.ssl.KeyManager
import javax.net.ssl.KeyManagerFactory
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager

typealias AuthenticationManagers = Pair<Array<KeyManager>, Array<X509TrustManager>>


object SSLAuthenticationManagers {

    fun trustManagerForCertificates(
        certInputStream: InputStream,
        pfxInputStream: InputStream,
        password: CharArray
    ): AuthenticationManagers {
        val certificateFactory = CertificateFactory.getInstance("X.509")
        val clientCertificates = certificateFactory.generateCertificates(certInputStream)
        require(!clientCertificates.isEmpty()) { "expected non-empty set of trusted certificates" }

        // Put the certificates a key store.
        val trustManagerKeyStore = KeyStore.getInstance(KeyStore.getDefaultType())
        trustManagerKeyStore.load(null, password)
        for ((index, certificate) in clientCertificates.withIndex()) {
            val certificateAlias = index.toString()
            trustManagerKeyStore.setCertificateEntry(certificateAlias, certificate)
        }

        // Use it to build an X509 trust manager.
        val trustManagerFactory = TrustManagerFactory.getInstance(
            TrustManagerFactory.getDefaultAlgorithm()
        )
        trustManagerFactory.init(trustManagerKeyStore)

        val keyManagerKeyStore = KeyStore.getInstance("PKCS12")
        keyManagerKeyStore.load(pfxInputStream, password)

        val keyManagerFactory = KeyManagerFactory.getInstance(
            KeyManagerFactory.getDefaultAlgorithm()
        )
        keyManagerFactory.init(keyManagerKeyStore, password)

        val sslPinningX509TrustManagers = arrayOf<X509TrustManager>(
            SSLPinningX509TrustManager(clientCertificates)
        )

        return Pair(keyManagerFactory.keyManagers, sslPinningX509TrustManagers)
    }

}