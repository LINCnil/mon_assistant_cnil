package com.cnil.assistant.utils.sslHelper;

import android.content.Context;

import com.cnil.assistant.utils.LogManager;
import com.google.common.base.Charsets;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.X509TrustManager;

import kotlin.Pair;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;


public class SSLConnectionManager {
    private static final byte[] secretKey = new byte[]{
            120, 66, 119, 120, 111, 99, 122, 119, 84, 99, 121, 74, 114, 119, 77, 81, 67, 100,
            116, 53, 43, 120, 101, 55, 85, 50, 116, 65, 61, 61, 10
    };

    private static final byte[] initVector = new byte[]{
            115, 111, 116, 89, 100, 77, 97, 76, 83, 47, 89, 115, 47, 97, 98, 27
    };

    private static final byte[] salt = new byte[]{
            122, 106, 109, 121, 89, 90, 76, 82, 68, 118, 71, 50, 119, 83, 99, 66, 51, 122, 116,
            108, 52, 119, 31, 16, 77
    };

    private static final byte[] encrypted = new byte[]{
            67, 104, 115, 83, 110, 104, 99, 43, 77, 88, 84, 87, 48, 67, 80, 49, 102, 78, 98, 71,
            87, 103, 61, 61, 10
    };

    private static final String CRT_CERTIFICATE_FILENAME = "server_encrypt.crt";
    private static final String P12_CERTIFICATE_FILENAME = "cnil_download_pass.p12";
    private static final long DEFAULT_REQUEST_TIMEOUT_MILLIS = 10000L;
    private static final String SSL_VERSION = "TLSv1.2";

    private static Pair<KeyManager[], X509TrustManager[]> authenticationManagers = null;


    public static void prepareRequest(Context context, String url, Callback responseCallback)
            throws NoSuchAlgorithmException, KeyManagementException, IOException {
        if (authenticationManagers == null) {
            InputStream pfxStream = context.getApplicationContext().getAssets().open(P12_CERTIFICATE_FILENAME);
            InputStream crtStream = context.getApplicationContext().getAssets().open(CRT_CERTIFICATE_FILENAME);
            authenticationManagers = SSLAuthenticationManagers.INSTANCE.trustManagerForCertificates(
                    crtStream, pfxStream, getPassphrase());
            crtStream.close();
            pfxStream.close();
        }

        // Create SSLSocketFactory
        SSLContext sslContext = SSLContext.getInstance(SSL_VERSION);
        sslContext.init(authenticationManagers.getFirst(), authenticationManagers.getSecond(), null);
        SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

        OkHttpClient client = new OkHttpClient.Builder()
                .sslSocketFactory(sslSocketFactory, authenticationManagers.getSecond()[0])
                .readTimeout(DEFAULT_REQUEST_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)
                .writeTimeout(DEFAULT_REQUEST_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)
                .connectTimeout(DEFAULT_REQUEST_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)
                .hostnameVerifier((hostname, session) -> {
                    LogManager.addLog("hostnameVerifier() - Trust Host:" + hostname);
                    return hostname.equals(session.getPeerHost());
                })
                .retryOnConnectionFailure(true)
                .build();

        Request getRequest = new Request.Builder()
                .url(url)
                .header("Connection", "close")
                .build();

        Call call = client.newCall(getRequest);
        call.enqueue(responseCallback);
    }

    private static char[] getPassphrase() {
        return Objects.requireNonNull(AESEncryption.INSTANCE.decrypt(
                new String(encrypted, Charsets.UTF_8),
                new String(secretKey, Charsets.UTF_8),
                new String(initVector, Charsets.UTF_8),
                new String(salt, Charsets.UTF_8))).toCharArray();
    }
}
