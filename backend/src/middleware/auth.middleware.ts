import { Request, Response, NextFunction } from 'express';
import { verifyToken, JwtPayload } from '../utils/jwt';
import { sendError } from '../utils/response';

export interface AuthRequest extends Request {
  user?: JwtPayload;
}

/** Verifies our own JWT (issued after Google OAuth). */
export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      sendError(res, 401, 'Authorization token required', 'UNAUTHORIZED');
      return;
    }
    const token = header.split('Bearer ')[1];
    req.user = verifyToken(token);
    next();
  } catch {
    sendError(res, 401, 'Invalid or expired token', 'TOKEN_INVALID');
  }
};

/** Requires ADMIN role on top of valid JWT. */
export const adminMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  if (req.user?.role !== 'ADMIN') {
    sendError(res, 403, 'Admin access required', 'FORBIDDEN');
    return;
  }
  next();
};
