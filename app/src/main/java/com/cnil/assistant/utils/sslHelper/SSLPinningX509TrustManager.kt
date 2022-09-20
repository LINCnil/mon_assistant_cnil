package com.cnil.assistant.utils.sslHelper


import com.cnil.assistant.utils.LogManager
import java.security.cert.Certificate
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.X509TrustManager


class SSLPinningX509TrustManager(
    private val clientCertificates: MutableCollection<out Certificate>?
) : X509TrustManager {

    @Throws(CertificateException::class)
    override fun checkClientTrusted(
        chain: Array<X509Certificate>?,
        authType: String
    ) {
        LogManager.addLog("SSLPinningX509TrustManager - checkClientTrusted(): method called")

        if ((chain == null || chain.isEmpty())) {
            throw IllegalArgumentException("Empty server certificate chain")
        }
    }

    @Throws(CertificateException::class)
    override fun checkServerTrusted(
        chain: Array<X509Certificate>,
        authType: String
    ) {
        checkTrusted(chain)
    }

    override fun getAcceptedIssuers(): Array<X509Certificate> {
        return arrayOf()
    }

    @Throws(CertificateException::class)
    private fun checkTrusted(
        chain: Array<X509Certificate>?
    ) {
        if ((chain == null || chain.isEmpty())) {
            throw CertificateException("Empty server certificate chain")
        } else if (chain.size != 1) {
            throw CertificateException("Wrong server certificate chain size. Length: ${chain.size}")
        }

        if (clientCertificates?.size == 1) {
            val clientCert = clientCertificates.first()
            if (clientCert.publicKey != chain[0].publicKey) {
                throw CertificateException("Client and server certificates aren't identical")
            }
        } else {
            throw CertificateException(
                "Wrong client certificate chain size. Length:  ${clientCertificates?.size ?: 0}"
            )
        }
    }

}