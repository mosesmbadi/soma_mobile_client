   * Flutter App (Android): Uses its package name and SHA-1
     fingerprint (configured in the Google Cloud Console under an
     "Android" OAuth client ID) to identify itself to Google for the
     sign-in flow. --> https://console.cloud.google.com/apis/credentials?inv=1&invt=Ab4mEg&project=soma-468016

     
   * Express.js Backend: Uses a "Web application" OAuth client ID
     (configured as GOOGLE_CLIENT_ID in your .env) to verify the
     authenticity of the ID token received from the Flutter app.


## Mobile Client
Fonts: https://pub.dev/packages/google_fonts
Icons: https://fonts.google.com/icons?icon.size=24&icon.color=%23e3e3e3