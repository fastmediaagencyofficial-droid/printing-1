import { OAuth2Client } from 'google-auth-library';
import { logger } from '../utils/logger';

// One shared client instance
const oauthClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export interface GoogleTokenPayload {
  googleId: string;
  email: string;
  displayName: string;
  photoUrl?: string;
  emailVerified: boolean;
}

/**
 * Verifies a Google ID token sent from the Flutter app.
 * Uses google-auth-library — completely free, no Firebase needed.
 *
 * Flutter side: google_sign_in gives us the idToken
 * Backend: we verify it here and extract user info
 */
export const verifyGoogleToken = async (
  idToken: string
): Promise<GoogleTokenPayload> => {
  try {
    const ticket = await oauthClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload || !payload.sub) {
      throw new Error('Empty token payload');
    }

    return {
      googleId: payload.sub,
      email: payload.email ?? '',
      displayName: payload.name ?? payload.email ?? 'User',
      photoUrl: payload.picture,
      emailVerified: payload.email_verified ?? false,
    };
  } catch (err) {
    logger.error('Google token verification failed:', err);
    throw new Error('Invalid or expired Google token');
  }
};

/**
 * Verifies a Google access token (used by Flutter Web).
 * Calls Google's userinfo endpoint to get user details.
 */
export const verifyGoogleAccessToken = async (
  accessToken: string
): Promise<GoogleTokenPayload> => {
  try {
    const response = await fetch(
      `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`
    );
    if (!response.ok) {
      throw new Error(`Userinfo request failed: ${response.status}`);
    }
    const info = (await response.json()) as any;
    if (!info.sub) {
      throw new Error('Empty userinfo response');
    }
    return {
      googleId: info.sub,
      email: info.email ?? '',
      displayName: info.name ?? info.email ?? 'User',
      photoUrl: info.picture,
      emailVerified: info.email_verified ?? false,
    };
  } catch (err) {
    logger.error('Google access token verification failed:', err);
    throw new Error('Invalid or expired Google access token');
  }
};
